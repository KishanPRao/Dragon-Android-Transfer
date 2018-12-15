package com.kishanprao.datHelper.base

import com.google.gson.JsonObject
import com.kishanprao.datHelper.base.Constants

open class SessionPacket(val name: String, val args: JsonObject = JsonObject(), val type: String = Constants.RequestMessage) {
    override fun toString(): String {
        return "name: $name, type: $type, args: $args"
    }
}