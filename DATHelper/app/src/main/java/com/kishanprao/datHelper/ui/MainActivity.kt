package com.kishanprao.datHelper.ui

import android.app.Activity
import android.content.Intent
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import com.google.android.gms.location.LocationSettingsStates
import com.kishanprao.datHelper.R
import com.kishanprao.datHelper.ui.hotspot.HotspotFragment

class MainActivity : AppCompatActivity() {
	companion object {
		private val TAG = MainActivity::class.java.simpleName
	}
	var hotspotFragment: HotspotFragment? = null
	var wifiFragment: WifiFragment? = null
	
	fun openWifi(v: View) {
		wifiFragment = WifiFragment()
		supportFragmentManager.beginTransaction()
				.replace(R.id.mainContainer, wifiFragment)
				.addToBackStack(null)
				.commit()
	}
	
	fun openHotspot(v: View) {
		hotspotFragment = HotspotFragment()
		supportFragmentManager.beginTransaction()
				.replace(R.id.mainContainer, hotspotFragment)
				.addToBackStack(null)
				.commit()
	}
	
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		setContentView(R.layout.activity_main)
	}
	
	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		val states = LocationSettingsStates.fromIntent(data);
		when (requestCode) {
			HotspotFragment.REQUEST_CHECK_SETTINGS -> {
				when (resultCode) {
					Activity.RESULT_OK -> {
						Log.d(TAG, "onActivityResult, success")
						hotspotFragment?.startHotspot()
					}
					Activity.RESULT_CANCELED -> {
						Log.d(TAG, "onActivityResult, canceled")
						if (!states.isGpsUsable) {
							Log.d(TAG, "onActivityResult, unusable")
							hotspotFragment?.disabledGps()
						}
					}
				}
			}
			
		}
	}
}
