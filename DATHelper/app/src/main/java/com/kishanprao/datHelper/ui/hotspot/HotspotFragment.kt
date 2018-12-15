package com.kishanprao.datHelper.ui.hotspot

import android.content.IntentSender
import android.net.wifi.WifiConfiguration
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v7.app.AlertDialog
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.common.api.ResultCallback
import com.google.android.gms.location.*
import com.kishanprao.datHelper.R
import com.kishanprao.datHelper.base.DeviceInfo
import com.tml.sharethem.utils.HotspotControl
import com.tml.sharethem.utils.Utils
import kotlinx.android.synthetic.main.fragment_hotspot.*


/**
 * Created by Kishan P Rao on 11/12/18.
 */
class HotspotFragment : Fragment(), HotspotControl.Callback {
	override fun onStarted(config: WifiConfiguration?) {
		if (config != null) {
			Log.d(TAG, "startHotspot, ${config.SSID} ${config.preSharedKey}")
			var text = ""
			text += "HOTSPOT ESTABLISHED\n\n"
			text += "Connect to ${config.SSID} network using ${config.preSharedKey}\n"
			text += "Select the device ${DeviceInfo.name} on your Mac"
			hotspotDetails.text = text
			hotspotProgress.visibility = View.VISIBLE
		}
	}
	
	override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
		return inflater.inflate(R.layout.fragment_hotspot, null)
	}
	
	private lateinit var hotspotControl: HotspotControl
	private val port = 1330
	private val name = "TestHotspot"
	
	fun startHotspot() {
		if (hotspotControl.isEnabled) {
			Log.w(TAG, "startHotspot, already enabled!")
			return
		}
		hotspotDetails.text = "Connecting.."
		try {
			if (Utils.isOreoOrAbove()) {
				hotspotControl.turnOnOreoHotspot(port)
				hotspotControl.setCallback(this)
			} else {
				/*
             * We need create a Open Hotspot with an SSID which can be intercepted by Receiver.
             * Here is the combination logic followed to create SSID for open Hotspot and same is followed by Receiver while decoding SSID, Sender HostName & port to connect
             * Reason for doing this is to keep SSID unique, constant(unless port is assigned by system) and interpretable by Receiver
             * {last 4 digits of android id} + {-} + Base64 of [{sender name} + {|} + SENDER_WIFI_NAMING_SALT + {|} + {port}]
             */
//				var androidId = Settings.Secure.ANDROID_ID
//				androidId = androidId.replace("[^A-Za-z0-9]".toRegex(), "")
//				val name = (if (androidId.length > 4) androidId.substring(androidId.length - 4) else androidId) + "-" + Base64.encodeToString((if (TextUtils.isEmpty(sender_name)) generateP2PSpuulName() else sender_name + "|" + WifiUtils.SENDER_WIFI_NAMING_SALT + "|" + m_fileServer.getListeningPort()).toByteArray(), Base64.DEFAULT)
				
				hotspotControl.turnOnPreOreoHotspot(name, port)
//				hotspotCheckHandler.sendEmptyMessage(AP_START_CHECK)
				val config = hotspotControl.configuration
				Log.d(TAG, "startHotspot, ${config.SSID} ${config.preSharedKey}")
			}
		} catch (e: Exception) {
			Log.e(TAG, "exception in hotspot init: " + e.message)
			e.printStackTrace()
		}
	}
	
	fun disabledGps() {
		val builder: AlertDialog.Builder
		val context = context!!
//		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//			builder = AlertDialog.Builder(context, android.R.style.Theme_Material_Dialog_Alert)
//		} else {
			builder = AlertDialog.Builder(context)
//		}
		builder.setTitle("Please enable GPS")
				.setMessage("GPS needs to enabled to use Hotspot mode.")
				.setPositiveButton(android.R.string.yes) { _, _ ->
					displayLocationSettingsRequest()
				}
				.setNegativeButton("Exit") { _, _ ->
					this@HotspotFragment.activity?.onBackPressed()
				}
				.setIcon(android.R.drawable.ic_dialog_alert)
				.show()
	}
	
	private fun displayLocationSettingsRequest() {
		val googleApiClient = GoogleApiClient.Builder(context!!)
				.addApi(LocationServices.API).build()
		googleApiClient.connect()
		
		val locationRequest = LocationRequest.create()
		locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
		locationRequest.interval = 10000
		locationRequest.fastestInterval = (10000 / 2).toLong()
		
		val builder = LocationSettingsRequest.Builder().addLocationRequest(locationRequest)
		builder.setAlwaysShow(true)
		
		val result = LocationServices.SettingsApi.checkLocationSettings(googleApiClient, builder.build())
		result.setResultCallback(object : ResultCallback<LocationSettingsResult> {
			override fun onResult(result: LocationSettingsResult) {
				val status = result.status
				when (status.statusCode) {
					LocationSettingsStatusCodes.SUCCESS -> {
						Log.i(TAG, "All location settings are satisfied.")
						startHotspot()
					}
					LocationSettingsStatusCodes.RESOLUTION_REQUIRED -> {
						Log.i(TAG, "Location settings are not satisfied. Show the user a dialog to upgrade location settings ")
						
						try {
							// Show the dialog by calling startResolutionForResult(), and check the result
							// in onActivityResult().
							status.startResolutionForResult(this@HotspotFragment.activity, REQUEST_CHECK_SETTINGS)
						} catch (e: IntentSender.SendIntentException) {
							Log.i(TAG, "PendingIntent unable to execute request.")
						}
						
					}
					LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE -> Log.i(TAG, "Location settings are inadequate, and cannot be fixed here. Dialog not created.")
				}
			}
		})
	}
	
	override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
		super.onViewCreated(view, savedInstanceState)
		hotspotControl = HotspotControl.getInstance(context)
//		Log.d(TAG, "onViewCreated, $hotspotControl")
		displayLocationSettingsRequest()
	}
	
	override fun onDestroyView() {
		hotspotControl.disable()
		super.onDestroyView()
	}
	
	companion object {
		private val TAG = HotspotFragment::class.java.simpleName
		public val REQUEST_CHECK_SETTINGS = 0x1
	}
}