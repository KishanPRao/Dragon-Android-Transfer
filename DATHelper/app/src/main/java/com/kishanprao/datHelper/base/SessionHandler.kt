package com.kishanprao.datHelper.base

import android.util.Log
import com.google.gson.JsonObject
import com.kishanprao.datHelper.base.stateMachine.Action
import java.io.File
import java.net.Socket
import java.util.*
import java.util.concurrent.locks.ReentrantLock

class SessionHandler(private val serverAddress: String, private val session: SessionProtocol?) : SessionResponseProtocol {
    override fun connectionTerminated(code: Int) {
        session?.connectionTerminated(code)
    }

    //    TODO: Use PacketStatusCancel, closing activity, etc.
    override fun receivedPing() {
        sender?.sendPong()
    }

    override fun handleList(packet: SessionPacket) {
        session?.performAction(Action.OnOperation())
        try {
            sendList(packet)
            session?.performAction(Action.OnOperationCompleted())
        } catch (e: Exception) {
            e.printStackTrace()
            session?.performAction(Action.OnFailure(Constants.ConnectionTermErr))
        }
    }

    override fun handlePull(packet: SessionPacket) {
        session?.performAction(Action.OnOperation())
        try {
            startPull(packet)
            session?.performAction(Action.OnOperationCompleted())
        } catch (e: Exception) {
            e.printStackTrace()
            session?.performAction(Action.OnFailure(Constants.ConnectionTermErr))
        }
    }

    override fun handlePush(packet: SessionPacket) {
        session?.performAction(Action.OnOperation())
        try {
            startPush(packet)
            session?.performAction(Action.OnOperationCompleted())
        } catch (e: Exception) {
            e.printStackTrace()
            session?.performAction(Action.OnFailure(Constants.ConnectionTermErr))
        }
    }

    private var socket: Socket? = null
    private var receiver: SessionReceiver? = null
    private var sender: SessionSender? = null
    private val lock = ReentrantLock()

    fun start() {
        lock.lock()
        var socket: Socket? = null
        var retryCount = 0
        do {
            try {
                socket = Socket(serverAddress, Constants.CONN_SERVER_PORT.toInt())
            } catch (e: Exception) {
                e.printStackTrace()
                Log.e(TAG, "setup: failed to connect!")
                Thread.sleep(500)
                retryCount++
                if (retryCount == CONN_RETRY_COUNT) {
                    Log.e(TAG, "start: couldn't connect. TODO: Handle")
//                    TODO: Handle state.
                    lock.unlock()
                    return
                }
            }
        } while (socket == null)
        this.socket = socket
        sender = SessionSender(socket)
        receiver = SessionReceiver(socket, this)
        sender!!.start()
        receiver!!.start()

        lock.unlock()
    }

    fun stop() {
        lock.lock()
        Log.i(TAG, "stop: ")
        try {
            sender?.quit()
            sender?.join()
            Log.d(TAG, "stop: closed sender")
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
        try {
            receiver?.quit()
//            receiver?.join()//same thread
            Log.d(TAG, "stop: closed recv")
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
        try {
            socket?.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        Log.i(TAG, "stop: done")
        lock.unlock()
    }

    private fun sendList(packet: SessionPacket) {
        val path = packet.args["path"].asString
        val args = JsonObject()
//        Environment.getExternalStorageDirectory().
        val output = Arrays.toString(File(path).list())
        args.addProperty("length", output.length)
        args.addProperty("status", "OK")
        val respPacket = SessionPacket(SessionCommand.ListResponse, args, Constants.ResponseMessage)
//            Log.v(TAG, "handleRequest: sending message: $message")
        sender?.apply {
            //            lock()
            queueMessage(respPacket, false)
//            sendData(output.toByteArray())
            queueByteArray(output.toByteArray())
//            unlock()
        }
    }

    private fun startPull(packet: SessionPacket) {
        val fileWithPath = packet.args["file"].asString
        val fileObj = File(fileWithPath)
        val respPacket = SessionPacket(SessionCommand.PullResponse,
                JsonObject(), Constants.ResponseMessage)
        val args = respPacket.args
        var files = ArrayList<String>()
        var parentPath = ""
        var totalLength: Long = 0
        if (fileObj.exists()) {
            val isDirectory = fileObj.isDirectory
            args.addProperty("isDirectory", isDirectory)
            if (isDirectory) {
                val (f, size) = Utils.getFilesInDirectory(fileWithPath)
                files = f
                totalLength = size
                val filesJson = JsonObject()
                for (i in 0 until files.count()) {
                    filesJson.addProperty("$i", files[i])
                }
                args.add("files", filesJson)
                args.addProperty("numFiles", files.count())
                args.addProperty("directory", fileObj.name)
                parentPath = fileObj.path
            } else {
                val fileArg = fileObj.name
                args.addProperty("file", fileArg)
                files.add(fileArg)
                parentPath = fileObj.parentFile.path
                totalLength = fileObj.length()
            }
        }
        Log.i(TAG, "startPull: total length: $totalLength")
        args.addProperty("status", "OK")
        args.addProperty("totalSize", totalLength)
        Log.i(TAG, "pullResponse: $respPacket")
//        val gson = GsonBuilder().create()
//        val jsonData = gson.toJson(remoteMessage)
//        Log.i(TAG, "pullResponse: $jsonData")
//        TODO: Handle error scenarios. dcs.
        receiver?.apply {
//            lock()
            sender?.apply {
                lock()
                queueMessage(respPacket, false)
                flush(false)
                for (file in files) {
                    sendSingleFile("$parentPath/$file")
                }
                unlock()
            }
//            unlock()
        }
    }

    private fun startPush(packet: SessionPacket) {
        val directoryName = packet.args["directory"].asString
        val isDirectory = packet.args["isDirectory"].asBoolean
        val files = ArrayList<String>()
        if (isDirectory) {
            val numFiles = packet.args["numFiles"].asInt
            val jsonFiles = packet.args["files"].asJsonObject
            for (i in 0 until numFiles) {
                val file = jsonFiles["$i"].asString
                files.add(file)
            }
        } else {
            val file = packet.args["file"].asString
            files.add(file)
        }
        Log.i(TAG, "pushResponse: isDir $isDirectory")
        Log.i(TAG, "pushResponse: files $files")
        Log.i(TAG, "pushResponse: dirName $directoryName")
        val args = JsonObject()
        args.addProperty("status", "OK")
        val respPacket = SessionPacket(SessionCommand.PushResponse, args, Constants.ResponseMessage)
        Log.v(TAG, "pushResponse: sending message: $packet")

        receiver?.apply {
//            lock()
            sender?.apply {
                lock()
                queueMessage(respPacket, false)
                flush(false)
                for (file in files) {
                    val fileWithPath = "$directoryName/$file"
                    val status = receiver?.readSingleFile(fileWithPath)
                    if (status != Constants.PacketStatusOk) {
                        Log.w(TAG, "pushResponse: status not OK: $status")
                        break
                    }
                }
                unlock()
            }
//            unlock()
        }
//        writer.close()
//        Log.w(TAG, "pushResponse: size: $currentLength")
        Log.i(TAG, "pushResponse: done")
    }

    companion object {
        private val TAG = SessionHandler::class.java.simpleName
        private const val CONN_RETRY_COUNT = 10
    }
}
