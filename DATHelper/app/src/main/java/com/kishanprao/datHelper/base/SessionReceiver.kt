package com.kishanprao.datHelper.base

import android.util.Log
import com.google.gson.Gson
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.Socket
import java.net.SocketException
import java.util.*
import kotlin.concurrent.withLock

class SessionReceiver(var socket: Socket, var callback: SessionResponseProtocol? = null) :
        SessionTransceiver("SessionReceiver") {
    private val reader = BufferedInputStream(socket.getInputStream())

    companion object {
        private val TAG = SessionReceiver::class.java.simpleName
    }

//    fun lock() {
//        lock.lock()
//    }
//
//    fun unlock() {
//        lock.unlock()
//    }

    private fun sendStatus() {
//        Log.v(TAG, "sendData: ${String(data)}")
        val statusBuf = String.format(Locale.getDefault(),
                "%0${Constants.PacketStatusSize}d", status).toByteArray()
        val writer = socket.getOutputStream()
        writer.write(statusBuf, 0, statusBuf.size)
        writer.flush()
    }


    fun readSingleFile(fileWithPath: String): Int {
        var status = 0
        Log.i(TAG, "readSingleFile: path $fileWithPath")
//        return
        val file = File(fileWithPath)
        file.parentFile.mkdirs()
        file.createNewFile()
        val lenBuf = ByteArray(Constants.ControlPacketLengthSize)
        val readSize = receive(lenBuf, lenBuf.size)
        val fileLength = String(lenBuf, 0, readSize).toInt()
        Log.i(TAG, "readSingleFile: file length: $fileLength")

        val writer = FileOutputStream(fileWithPath)
        if (fileLength == 0) {
            Log.i(TAG, "readSingleFile: got 0 length file!")
            writer.close()
        }
        val blockSize = Constants.BlockSize  //TODO: Comm to other side, buf size, during response
        val buf = ByteArray(blockSize)
        val tmpSize = 30
        val dispBuf = ByteArray(tmpSize)
        var i = 0
        for (b in 0 until tmpSize) {
            dispBuf[i++] = buf[b]
        }
        Log.e(TAG, "readSingleFile: first buff: ${Arrays.toString(dispBuf)}")
        var currentLength = 0
        var nextReadLength = blockSize
        if (nextReadLength > fileLength) {
            nextReadLength = fileLength
        }
        while (currentLength < fileLength) {
            var length: Int
//            length = receiver!!.receiveDirect(buf, Constants.PacketStatusSize)
//            TODO: Check self status to send and break
            sendStatus()
            length = receiveForced(buf, Constants.PacketStatusSize)
            if (length == -1) {
                Log.w(TAG, "readSingleFile: didn't receive status byte")
                break
            } else {
                status = String(buf, 0, length).toInt()
                if (status != Constants.PacketStatusOk) {
                    Log.w(TAG, "readSingleFile: bad status => $status")
                    break
                }
            }
//            length = receiver!!.receiveDirect(buf, nextReadLength)
            length = receiveForced(buf, nextReadLength)
            if (length == -1) {
                break
            }
//            Log.v(TAG, "readSingleFile: read: $length, $nextReadLength")
            writer.write(buf, 0, length)
            currentLength += length
            if (fileLength - currentLength < nextReadLength) {
                nextReadLength = fileLength - currentLength
            }
        }
        if (currentLength == fileLength) {
            Log.i(TAG, "readSingleFile: success!")
        } else {
            Log.i(TAG, "readSingleFile: didn't complete! $currentLength $fileLength")
        }
        Log.w(TAG, "readSingleFile: current len: $currentLength => $fileLength")
        writer.close()
        Log.w(TAG, "readSingleFile: size: $currentLength")
        return status
    }

    private fun receive(byteArray: ByteArray, size: Int): Int {
        return reader.read(byteArray, 0, size)
    }

    private fun receiveForced(byteArray: ByteArray, size: Int): Int {
        var readSize: Int
        var totalReadSize = 0
        do {
            readSize = reader.read(byteArray, totalReadSize, size - totalReadSize)
            if (readSize > 0) {
                totalReadSize += readSize
            } else if (readSize < 0) {
                Log.w(TAG, "receiveForced: bad read size!")
                return -1
            }
        } while (readSize > 0)
        return totalReadSize
    }

    override fun quit() {
        Log.d(TAG, "quit: ")
        interrupt()
        Log.d(TAG, "quit: inpt done")
    }

    override fun begin() {
        Log.i(TAG, "begin")
    }

    override fun end() {
        Log.i(TAG, "end")
    }

    private var sendFailure = true
    fun reset() {
        sendFailure = true
    }

    private fun loopInternal() {
//        lock()
        val size = 1024
        val buf = ByteArray(size)
//        while (!isInterrupted) {
        var readSize = lock.withLock {
            reader.read(buf, 0, Constants.ControlPacketLengthSize)
        }
        if (readSize > 0) {
            Log.v(TAG, "receive: readSize: $readSize")
            var data = String(buf, 0, readSize)
            val totalSize = data.toInt()
            readSize = 0
            data = ""
            Log.v(TAG, "receive, length: $totalSize")
            var nextReadSize = 1024
            while (readSize < totalSize) {
                if (totalSize - readSize < nextReadSize) {
                    nextReadSize = totalSize - readSize
                }
                val currentReadSize = lock.withLock {
                    reader.read(buf, 0, nextReadSize)
                }
                readSize += currentReadSize
                data += String(buf, 0, currentReadSize)
            }
            Log.v(TAG, "receive: $data")
            val gson = Gson()
            val request = gson.fromJson<SessionPacket>(data, SessionPacket::class.java)
            Log.v(TAG, "receive: Request -> $request")
            if (request.name == SessionCommand.Ping) {
                callback?.receivedPing()
            }/* else if (request.type == Constants.RequestMessage) {
                    callback?.handleRequest(request)
                }*/
            else if (request.name == SessionCommand.ListRequest) {
                callback?.handleList(request)
            } else if (request.name == SessionCommand.PullRequest) {
                callback?.handlePull(request)
            } else if (request.name == SessionCommand.PushRequest) {
                callback?.handlePush(request)
            } else {
                Log.w(TAG, "receive: not handled!")
            }
        } else {
            Log.e(TAG, "Negative Return value!")
            if (sendFailure) {
                callback?.connectionTerminated(Constants.ConnectionTermErr)
                sendFailure = false
            }
        }
//        unlock()
//        }
    }
    
    
    override fun loop() {
        try {
            loopInternal()
        } catch (se: SocketException) {
            se.printStackTrace()
            if (sendFailure) {
                callback?.connectionTerminated(Constants.ConnectionTermErr)
                sendFailure = false
            }
            throw se
        }
    }
}
