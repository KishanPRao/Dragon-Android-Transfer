package com.kishanprao.datHelper.base

import com.kishanprao.datHelper.base.SessionPacket

interface SessionResponseProtocol {
    fun receivedPing()
    fun handleList(packet: SessionPacket)
    fun handlePull(packet: SessionPacket)
    fun handlePush(packet: SessionPacket)
    fun connectionTerminated(code: Int)
}