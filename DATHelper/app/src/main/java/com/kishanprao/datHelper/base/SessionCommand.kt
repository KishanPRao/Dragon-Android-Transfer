package com.kishanprao.datHelper.base

class SessionCommand {
    companion object {
        private const val Prefix = "DAT_COMMAND:"
        private const val RequestSuffix = "_REQUEST"
        private const val ResponseSuffix = "_RESPONSE"
        const val Ping = "${Prefix}PING"
        const val Pong = "${Prefix}PONG"
        const val Quit = "${Prefix}QUIT"

        const val ListRequest = "${Prefix}LIST${RequestSuffix}"
        const val ListResponse = "${Prefix}LIST${ResponseSuffix}"

        const val PullRequest = "${Prefix}PULL${RequestSuffix}"
        const val PullResponse = "${Prefix}PULL${ResponseSuffix}"
        const val PushRequest = "${Prefix}PUSH${RequestSuffix}"
        const val PushResponse = "${Prefix}PUSH${ResponseSuffix}"
    }
}