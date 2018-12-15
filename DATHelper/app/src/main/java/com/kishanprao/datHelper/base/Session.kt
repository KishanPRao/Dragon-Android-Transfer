package com.kishanprao.datHelper.base

import android.util.Log
import com.kishanprao.datHelper.base.stateMachine.*
import java.util.concurrent.atomic.AtomicReference

class Session : SessionProtocol {
	override fun connectionTerminated(code: Int) {
		if (code != Constants.ConnectionTermOk) {
			performAction(Action.OnFailure(code))
		} else {
			performAction(Action.OnDisconnect())
		}
	}
	
	//    TODO: Move to Service?
	override fun getCurrentState(): ConnectionState {
		return state
	}
	
	private val state: ConnectionState
		get() = stateRef.get()
	var callback: UiCallback? = null
	
	private val stateRef = AtomicReference<ConnectionState>(Disconnected())
	private var handler: SessionHandler? = null
	private val discovery: SessionDiscovery = SessionDiscovery(this)
	
	fun begin() {
		discovery.start()
	}
	
	//    TODO: Move private methods to a abstract class.
	private fun onNewConnection(connData: ConnData) {
		val serverAddress = connData.serverAddress
		Log.v(TAG, "onNewConnection: $serverAddress")
		handler = SessionHandler(serverAddress, this)
		handler?.start()
	}

//    private fun onDisconnection() {
//        Log.v(TAG, "onDisconnection: $handler")
//        handler?.stop()
////        TODO: Restart Discovery.
//        Log.v(TAG, "onDisconnection: done")
//    }
	
	//    TODO: Move state change methods to a interface.
	private fun onConnected() {
		Log.v(TAG, "onConnected: ")
		callback?.onConnected()
	}
	
	private fun onDisconnected() {
		Log.v(TAG, "onDisconnected: ")
		handler?.stop()
		callback?.onDisconnected()
		discovery.reset()
	}
	
	/**
	 * The data within conn obj will determine if dc or plain failure.
	 */
	private fun onFailure(code: Int) {
		Log.v(TAG, "onFailure: $code")
		callback?.onFailure()
		performAction(Action.OnFailureHandled())
	}
	
	private fun onOperation() {
		Log.v(TAG, "onOperation: ")
		callback?.onTransferBegin()
	}
	
	private fun onChangeState(oldState: ConnectionState, newState: ConnectionState) {
		Log.v(TAG, "onChangeState: change = $oldState -> $newState")
		if (oldState is Disconnected && newState is Connected) {
			onNewConnection(newState.connData)
		}/* else if (oldState is Connected && newState is Disconnected) {
            onDisconnection()
        }*/
//        else {
		when (newState) {
			is Connected -> onConnected()
			is Disconnected -> onDisconnected()
			is Failed -> onFailure(newState.connData.code)
			is Operation -> onOperation()
		}
//        }
	}
	
	override fun performAction(action: Action) {
		Log.v(TAG, "performAction: $action")
		val oldState = state
		val newState = synchronized(this) {
			val newState = oldState.performAction(action)
			stateRef.set(newState)
			newState
		}
		Log.v(TAG, "new State: $oldState ($action) => $newState")
		if (oldState != newState) {
			onChangeState(oldState, newState)
		}
	}
	
	//    TODO: Can add New and Terminated states wrt Session.
	fun end() {
		Log.i(TAG, "end: ")
		
		if (stateRef.get() !is Disconnected) {
			try {
				performAction(Action.OnDisconnect())
			} catch (e: Exception) {
				e.printStackTrace()
			}
		}
		discovery.release()
	}
	
	companion object {
		private val TAG = Session::class.java.simpleName
		private const val BUFFER_SIZE = 1024
		val global = Session()
	}
}