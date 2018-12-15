package com.kishanprao.datHelper.base

import android.util.Log
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileInputStream
import java.net.Socket
import java.util.*
import java.util.concurrent.Semaphore
import kotlin.concurrent.withLock

class SessionSender(var socket: Socket) : SessionTransceiver("SessionSender") {
    companion object {
        private val TAG = SessionSender::class.java.simpleName
    }

    private val writer = BufferedOutputStream(socket.getOutputStream())
    private val queue = ArrayDeque<Any>()
    private val gson = GsonBuilder().create()
    private val semaphore = Semaphore(0)

    fun lock() {
        lock.lock()
    }

    fun unlock() {
        lock.unlock()
    }


    private fun receiveForced(byteArray: ByteArray, size: Int): Int {
        var readSize: Int
        var totalReadSize = 0
        do {
            readSize = socket.getInputStream().read(byteArray, totalReadSize, size - totalReadSize)
            if (readSize > 0) {
                totalReadSize += readSize
            } else if (readSize < 0) {
                Log.w(TAG, "receiveForced: bad read size!")
                return -1
            }
        } while (readSize > 0)
        return totalReadSize
    }

    fun sendSingleFile(file: String) {
        val fileObj = File(file)
        val sendData = String.format(Locale.getDefault(),
                "%0${Constants.ControlPacketLengthSize}d",
                fileObj.length().toInt())
        sendData(sendData.toByteArray())
        Log.i(TAG, "sendSingleFile: $file, length: $sendData")

        var amt = 0
        val reader = FileInputStream(file)
        val size = Constants.BlockSize //TODO: Comm to other side, buf size
        val buf = ByteArray(size)
        var length = reader.read(buf, 0, size)
//        Log.e(TAG, "sendSingleFile: first buff: ${Arrays.toString(dispBuf)}")
        val recvStatusBuf = ByteArray(Constants.PacketStatusSize)
        while (length != -1) {
//            try catch, never freeze!
            amt += length
//            TODO: Check self status to send and break
//            length = receiveForced(buf, Constants.PacketStatusSize)
            val statusSize = receiveForced(recvStatusBuf, recvStatusBuf.size)
            if (statusSize == -1) {
                Log.w(TAG, "sendSingleFile: didn't receive status byte")
                break
            } else {
                val status = String(recvStatusBuf, 0, statusSize).toInt()
                if (status != Constants.PacketStatusOk) {
                    Log.w(TAG, "sendSingleFile: bad status => $status")
                    break
                }
            }
            val statusBuf = String.format(Locale.getDefault(),
                    "%0${Constants.PacketStatusSize}d", status).toByteArray()
            sendData(statusBuf, statusBuf.size)
            sendData(buf, length)
            length = reader.read(buf, 0, size)
        }
        Log.v(TAG, "sendSingleFile: done! amt: $amt")
        reader.close()
    }

    private fun sendMessage(packet: SessionPacket) {
        val jsonData = gson.toJson(packet)
        val sendData = "${String.format(Locale.getDefault(),
                "%0${Constants.ControlPacketLengthSize}d", jsonData.length)}$jsonData"
//        Log.v(TAG, "sendMessage: data => $sendData")
        sendData(sendData.toByteArray())
    }

    private fun sendOneQueuedMessage() {
        val queueEle = queue.removeFirst()
        if (queueEle is SessionPacket) {
            sendMessage(queueEle)
        } else if (queueEle is ByteArray) {
            sendData(queueEle)
        } else if (queueEle is Int) {
            sendSingleByte(queueEle)
        } else {
            Log.w(TAG, "transmit: unrecognized data in queue! $queueEle")
        }
    }

    fun queueMessage(packet: SessionPacket, useLock: Boolean = true) {
        if (useLock) {
            lock.withLock {
                queue.addLast(packet)
            }
        } else {
            queue.addLast(packet)
        }
    }

    fun queueByteArray(byteArray: ByteArray, useLock: Boolean = true) {
        if (useLock) {
            lock.withLock {
                queue.addLast(byteArray)
            }
        } else {
            queue.addLast(byteArray)
        }
    }

    private fun sendSingleByte(byte: Int) {
//        Log.v(TAG, "sendSingleByte: $byte")
        writer.write(byte)
        writer.flush()
    }

    private fun sendData(data: ByteArray, length: Int) {
//        Log.v(TAG, "sendData: ${String(data)}")
        writer.write(data, 0, length)
        writer.flush()
    }

    private fun sendData(data: ByteArray) {
//        Log.v(TAG, "sendData: ${String(data)}")
        sendData(data, data.size)
    }

    fun flush(useLock: Boolean = true) {
        val flushClosure = {
            while (!queue.isEmpty()) {
                sendOneQueuedMessage()
            }
        }
        if (useLock) {
            lock.withLock {
                flushClosure()
            }
        } else {
            flushClosure()
        }
    }

    fun sendPong() {
        lock.withLock {
            queue.addLast(SessionPacket(SessionCommand.Pong, JsonObject(), Constants.ResponseMessage))
        }
    }

    override fun begin() {
        Log.i(TAG, "begin")
    }

    override fun end() {
        Log.i(TAG, "end")
        sendMessage(SessionPacket(SessionCommand.Quit, JsonObject(), Constants.RequestMessage))
//        semaphore.release()
    }

    override fun quit() {
        Log.d(TAG, "quit: ")
        interrupt()
        Log.d(TAG, "quit: inpt done")
//        semaphore.acquire()
//        Log.d(TAG, "quit: acq done")
    }

    override fun loop() {
//        Thread.sleep(3000)

        val isEmpty = lock.withLock {
            queue.isEmpty()
        }
        if (!isEmpty) {
            lock.withLock {
                sendOneQueuedMessage()
            }
        } else {
            Thread.sleep(500)
        }
    }
}