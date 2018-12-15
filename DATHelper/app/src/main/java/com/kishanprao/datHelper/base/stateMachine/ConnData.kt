package com.kishanprao.datHelper.base.stateMachine

import com.kishanprao.datHelper.base.Constants

data class ConnData(val serverAddress: String, var code: Int = Constants.ConnectionTermOk)