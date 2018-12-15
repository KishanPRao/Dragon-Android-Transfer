package com.kishanprao.datHelper.base

/**
 * Created by Kishan P Rao on 14/12/18.
 */
class DeviceInfo {
	companion object {
		val name: String = android.os.Build.MODEL?.let {
			android.os.Build.MODEL
		} ?: "Unknown"
	}
}