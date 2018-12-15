package com.kishanprao.datHelper.base

class Constants {
    companion object {
        const val CONNECTION_REQUEST = "DragonAT_ConnectionRequest"
        const val CONNECTION_RESPONSE_SUCCESS = "DragonAT_ConnectionResponseSuccess"
        const val BCAST_ADDR = "255.255.255.255"
        const val HOST_ADDR = "0.0.0.0"
        //        const val CONNECTION_RESPONSE_SUCCESS_ACK = "DragonAT_ConnectionResponseSuccessAck"
        const val CONNECTION_RESPONSE_ERR = "DragonAT_ConnectionResponseError"
        const val BCAST_PORT = 8888
        const val BCAST_LISTEN_PORT = 8889
        const val BCAST_TIMEOUT: Long = 2500
        const val LOW_TIMEOUT: Long = 1000
        const val HIGH_TIMEOUT: Long = 3000

        const val CONN_SERVER_PORT: Long = 7777

        const val RequestMessage = "request"
        const val ResponseMessage = "response"

        const val ControlPacketLengthSize = 13
        const val BlockSize = 1024 * 512

        const val PacketStatusSize = 1
        const val PacketStatusOk = 0
        const val PacketStatusCancel = 1

        const val ConnectionTermOk = 0
        const val ConnectionTermErr = -1
    }
}