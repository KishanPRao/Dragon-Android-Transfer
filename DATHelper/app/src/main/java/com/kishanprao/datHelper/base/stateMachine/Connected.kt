package com.kishanprao.datHelper.base.stateMachine

class Connected(val connData: ConnData) : AbstractConnectionState() {
    companion object {
        private val TAG = Connected::class.java.simpleName
    }

    override fun performAction(action: Action): ConnectionState {
        return when (action) {
            is Action.OnFailure -> {
                connData.code = action.code
                Failed(connData)
            }
            is Action.OnDisconnect -> {
                Disconnected()
            }
            is Action.OnOperation -> {
                Operation(connData)
            }
            else -> {
                return super.performAction(action)
            }
        }
    }

}