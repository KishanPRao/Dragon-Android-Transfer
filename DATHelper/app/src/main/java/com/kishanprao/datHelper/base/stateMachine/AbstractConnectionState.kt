package com.kishanprao.datHelper.base.stateMachine

import android.util.Log

abstract class AbstractConnectionState : ConnectionState {
    companion object {
        private val TAG = AbstractConnectionState::class.java.simpleName
    }

    override fun performAction(action: Action): ConnectionState {
        Log.e(TAG, "performAction: bad state, $this => $action")
        return this
    }

    override fun toString(): String {
        return "[STATE:${this::class.java.simpleName}]"
    }
}