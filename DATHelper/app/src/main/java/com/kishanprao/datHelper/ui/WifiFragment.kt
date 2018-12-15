package com.kishanprao.datHelper.ui

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.os.Bundle
import android.provider.Settings
import android.support.v4.app.Fragment
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.kishanprao.datHelper.R
import com.kishanprao.datHelper.base.DeviceInfo
import kotlinx.android.synthetic.main.fragment_wifi.*
import java.util.*

/**
 * Created by Kishan P Rao on 13/12/18.
 */
class WifiFragment : Fragment() {
	private var prevWifiEnabled = false
	override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
		return inflater.inflate(R.layout.fragment_wifi, null)
	}
	
	private fun isConnected(): Boolean {
		val connManager = this.context!!.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
		val current = connManager.activeNetworkInfo
		val isWifi = current != null && current.type == ConnectivityManager.TYPE_WIFI
		return isWifi
	}
	
	private fun showWifiDetails() {
		val wifiManager = this.context!!.getSystemService(Context.WIFI_SERVICE) as WifiManager
		var ssid = wifiManager.connectionInfo.ssid
		ssid = if (ssid == null) {
			"<Unknown>"
		} else {
			ssid.drop(1).dropLast(1)
		}
//		bold/italics ssid
//		wifiDetails.text = "Connect to $ssid on your Mac"
		var text = ""
		text += "WIFI CONNECTED\n\n"
		text += "Connect to $ssid network on your Mac\n"
		text += "Select the device ${DeviceInfo.name} on your Mac"
		wifiDetails.text = text
		wifiProgress.visibility = View.VISIBLE
	}
	
	private fun startCheckingConnection() {
		val timer = Timer()
		val task = object : TimerTask() {
			override fun run() {
				if (isConnected()) {
//					timer.purge()
					Log.i(TAG, "run, connected")
					timer.cancel()
					wifiProgress.post {
						wifiProgress.visibility = View.GONE
						showWifiDetails()
					}
				}
			}
		}
		timer.scheduleAtFixedRate(task, 0, 500)
	}
	
	override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
		super.onViewCreated(view, savedInstanceState)
		val wifiManager = this.context!!.getSystemService(Context.WIFI_SERVICE) as WifiManager
		prevWifiEnabled = wifiManager.isWifiEnabled
		if (prevWifiEnabled) {
			turnOnWifi.visibility = View.GONE
			showWifiDetails()
		}
		turnOnWifi.setOnClickListener {
			Log.d(TAG, "enableWifi, ")
			if (!prevWifiEnabled) {
				Log.d(TAG, "onViewCreated, enabling wifi")
				wifiManager.isWifiEnabled = true
				startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
				turnOnWifi.visibility = View.GONE
				wifiDetails.text = "Waiting for a WiFi connection.."
				startCheckingConnection()
			}
		}
	}
	
	override fun onResume() {
		super.onResume()
		Log.d(TAG, "onResume, connected: ${isConnected()}")
	}
	
	override fun onDestroyView() {
//		if (!prevWifiEnabled) {
//			Log.d(TAG, "onDestroyView, disable wifi")
//			val wifiManager = this.context!!.getSystemService(Context.WIFI_SERVICE) as WifiManager
//			wifiManager.isWifiEnabled = false
//		}
		super.onDestroyView()
	}
	
	companion object {
		private val TAG = WifiFragment::class.java.simpleName
	}
}