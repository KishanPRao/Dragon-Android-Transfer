package com.kishanprao.datHelper.base.stateMachine

import android.util.Log

class Disconnected() : AbstractConnectionState() {
    companion object {
        private val TAG = Disconnected::class.java.simpleName
    }

    override fun performAction(action: Action): ConnectionState {
        return when (action) {
            is Action.OnConnect -> {
                Log.v(TAG, "performAction: $action")
                Connected(ConnData(action.serverAddress))
            }
            else -> {
                return super.performAction(action)
            }
        }
    }
}