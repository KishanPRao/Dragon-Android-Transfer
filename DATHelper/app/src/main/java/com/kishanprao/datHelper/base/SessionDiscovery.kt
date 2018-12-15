package com.kishanprao.datHelper.base

import android.util.Log
import com.kishanprao.datHelper.base.stateMachine.Action
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.SocketTimeoutException
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

class SessionDiscovery(val session: SessionProtocol) : Thread() {
    companion object {
        private val TAG = SessionDiscovery::class.java.simpleName
        private const val BUFFER_SIZE = 1024
    }

    private val socket: DatagramSocket
    private val lock = ReentrantLock()
    private val condition = lock.newCondition()
    private var repeat = true
    private var sleepTimeout: Long = 0


    init {
        socket = DatagramSocket(Constants.BCAST_LISTEN_PORT, InetAddress.getByName(Constants.HOST_ADDR))
        socket.soTimeout = Constants.BCAST_TIMEOUT.toInt()
    }

    private fun tryReceive() {
        val buffer = ByteArray(BUFFER_SIZE)
        val packet = DatagramPacket(buffer, buffer.size)
        Log.d(TAG, "tryReceive: waiting to rec")
        try {
            socket.receive(packet)
            val receivedData = String(packet.data, 0, packet.length)
            Log.d(TAG, "tryReceive: Resp, $receivedData")
            if (receivedData == Constants.CONNECTION_RESPONSE_SUCCESS) {
                val address = packet.address
                address?.apply {
                    session.performAction(Action.OnConnect(address.hostAddress))
                    lock.withLock {
                        Log.d(TAG, "loop: waiting")
                        condition.await()
                        Log.d(TAG, "loop: wait done")
                    }
                }
            } else if (receivedData == Constants.CONNECTION_RESPONSE_ERR) {
                sleepTimeout = Constants.HIGH_TIMEOUT
            }
        } catch (e: SocketTimeoutException) {
            Log.v(TAG, "tryReceive: rec timeout")
            sleepTimeout = Constants.BCAST_TIMEOUT
        }
    }

    private fun loop() {
        sleepTimeout = Constants.LOW_TIMEOUT
        val dp = DatagramPacket(Constants.CONNECTION_REQUEST.toByteArray(), Constants.CONNECTION_REQUEST.length,
                InetAddress.getByName(Constants.BCAST_ADDR), Constants.BCAST_PORT)
        Log.d(TAG, "loop: sending bcast")
        socket.send(dp)
        tryReceive()
        Thread.sleep(sleepTimeout)
    }

    override fun run() {
        while (repeat) {
            try {
                loop()
            } catch (e: Exception) {
//                TODO: No connection, etc scenarios. Or precheck on UI. Wifi related. Either Hotspot or Wifi?
//                e.printStackTrace()
                Thread.sleep(sleepTimeout)
            }
        }
        socket.close()
    }

    override fun start() {
        super.start()
        Log.i(TAG, "start: ")
    }

    fun reset() {
        Log.d(TAG, "reset: ")
        try {
            lock.withLock {
                condition.signalAll()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        Log.d(TAG, "reset: done")
    }

    //    TODO: Can add New and Terminated states wrt Session.
    fun release() {
        Log.i(TAG, "end: ")
        repeat = false
        try {
            lock.withLock {
                condition.signalAll()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
//        TODO: Wait until handler exits
        //        Wait until end (maybe in onDisconnection? followed by onDisconnected.)
        socket.close()
    }
}