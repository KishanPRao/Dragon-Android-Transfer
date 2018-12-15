package com.kishanprao.datHelper.base.stateMachine

sealed class Action {
    class OnConnect(val serverAddress: String) : Action()
    class OnDisconnect : Action()
    class OnOperation : Action()
    class OnOperationCompleted : Action()
    class OnFailure(val code: Int) : Action()
    class OnFailureHandled : Action()

    override fun toString(): String {
        return "[ACTION:${this::class.java.simpleName}]"
    }
}