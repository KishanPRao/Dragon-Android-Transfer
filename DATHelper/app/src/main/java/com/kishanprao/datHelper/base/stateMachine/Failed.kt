package com.kishanprao.datHelper.base.stateMachine

import com.kishanprao.datHelper.base.Constants

class Failed(val connData: ConnData) : AbstractConnectionState() {
    companion object {
        private val TAG = Failed::class.java.simpleName
    }

    override fun performAction(action: Action): ConnectionState {
        return when (action) {
            is Action.OnFailureHandled -> {
                if (connData.code == Constants.ConnectionTermOk) {
                    Connected(connData)
                } else {
                    Disconnected()
                }
            }
            else -> {
                return super.performAction(action)
            }
        }
    }
}