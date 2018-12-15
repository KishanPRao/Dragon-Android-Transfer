package com.kishanprao.datHelper.base.stateMachine

class Operation(val connData: ConnData) : AbstractConnectionState() {
    companion object {
        private val TAG = Operation::class.java.simpleName
    }

    override fun performAction(action: Action): ConnectionState {
        return when (action) {
            is Action.OnOperationCompleted -> {
                Connected(connData)
            }
            is Action.OnFailure -> {
                connData.code = action.code
                Failed(connData)
            }
            is Action.OnDisconnect -> {
                Failed(connData)
            }
            else -> {
                return super.performAction(action)
            }
        }
    }
}