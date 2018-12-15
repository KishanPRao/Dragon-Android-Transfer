package com.kishanprao.datHelper.base

import android.util.Log
import java.util.concurrent.locks.ReentrantLock

abstract class SessionTransceiver(name: String) : Thread(name) {
    val lock = ReentrantLock()
    var status = Constants.PacketStatusOk

    companion object {
        private val TAG = SessionTransceiver::class.java.simpleName
    }

    abstract fun begin()
    abstract fun end()
    abstract fun loop()
    abstract fun quit()

    override fun run() {
        begin()
        while (!isInterrupted) {
            try {
                loop()
//            } catch (e : InterruptedException) {  //TODO: Handle other types of exc.
//            } catch (se: SocketException) {
//                se.printStackTrace()
            } catch (e: Exception) {
                Log.e(TAG, "run: loop failed.")
                e.printStackTrace()
                break
            }
        }
//        Log.w(TAG, "run: loop end")
        try {
            end()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
