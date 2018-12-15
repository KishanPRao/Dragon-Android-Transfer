package com.kishanprao.datHelper.base

interface UiCallback {
    fun onConnected()
    fun onDisconnected()
    fun onTransferBegin()
    fun onTransferEnd()
    fun onFailure()
}