package com.kishanprao.datHelper.base.stateMachine

interface ConnectionState {
    fun performAction(action: Action): ConnectionState
}