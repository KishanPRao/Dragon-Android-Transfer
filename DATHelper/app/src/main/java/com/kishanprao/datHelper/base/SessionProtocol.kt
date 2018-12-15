package com.kishanprao.datHelper.base

import com.kishanprao.datHelper.base.stateMachine.Action
import com.kishanprao.datHelper.base.stateMachine.ConnectionState

interface SessionProtocol {
    fun getCurrentState(): ConnectionState

    fun performAction(action: Action)

    fun connectionTerminated(code: Int)
}