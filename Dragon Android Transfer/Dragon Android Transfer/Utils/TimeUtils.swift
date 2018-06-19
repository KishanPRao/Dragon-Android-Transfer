//
//  TimeUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class TimeUtils {
	static let USE_NANO = false
	
	static func getCurrentTime() -> String {
		let date = Date()
		let calendar = Calendar.current
		let components = (calendar as NSCalendar).components([.hour, .minute, .second, .nanosecond], from: date)
        let hour = components.hour! //TODO: Might crash? Remove this debugging later!
		let minute = components.minute!
		let second = components.second!
		let nanosecond = components.nanosecond!
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
    
    static func getDispatchTime() -> DispatchTime {
        return DispatchTime.now()
    }
    
    static func getDifference(_ previousTime: DispatchTime) -> Double {
        let currentTime = TimeUtils.getDispatchTime()
        let timeTakenInNano = currentTime.uptimeNanoseconds - previousTime.uptimeNanoseconds
        let timeTaken = Double(timeTakenInNano) / 1_000_000
        return timeTaken
    }
    
    static func getTime(seconds: Double) -> String {
//        var secondsInInt = Int(seconds)
        var secondsInInt = Number(seconds.roundUp())
        var minutes = secondsInInt / 60
        secondsInInt = secondsInInt % 60
        let hours = minutes / 60
        minutes = minutes % 60
        var time = ""
        if (hours > 0) {
            let hoursString = hours > 1 ? "hours" : "hour"
            time = time + "\(hours) \(hoursString) and "
        }
        if (minutes > 0) {
            let minutesString = minutes > 1 ? "minutes" : "minute"
            time = time + "\(minutes) \(minutesString) and "
        }
//        if (secondsInInt > 0) {
        secondsInInt = secondsInInt < 0 ? 0 : secondsInInt
        let secondsString = secondsInInt == 1 ? "second" : "seconds"
        time = time + "\(secondsInInt) \(secondsString)"
//        }
        print("Time Remaining: \(time)")
        print("Time Values: \(secondsInInt), \(minutes), \(hours)")
        return "\(time) remaining"
    }
}
