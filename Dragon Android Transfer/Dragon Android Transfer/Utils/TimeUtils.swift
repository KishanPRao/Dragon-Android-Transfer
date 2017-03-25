//
//  TimeUtils.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 19/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class TimeUtils {
	static let USE_NANO = false
	
	static func getCurrentTime() -> String {
		let date = Date()
		let calendar = Calendar.current
		let components = (calendar as NSCalendar).components([.hour, .minute, .second, .nanosecond], from: date)
		let hour = components.hour
		let minute = components.minute
		let second = components.second
		let nanosecond = components.nanosecond
		var returnValue = "[Hour:"+String(describing: hour)
		returnValue = returnValue+", Minute:"+String(describing: minute)
		returnValue = returnValue+", Second:"+String(describing: second)
		if (!USE_NANO) {
			returnValue = returnValue+"]"
		} else {
			returnValue = returnValue+", Nano Second:"+String(describing: nanosecond)
			returnValue = returnValue+"]"
		}
		return returnValue;
	}
}
