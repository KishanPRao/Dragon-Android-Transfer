//
// Created by Kishan P Rao on 27/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_ADBEXECUTIONRESULTWRAPPER_H
#define DRAGON_ANDROID_TRANSFER_ADBEXECUTIONRESULTWRAPPER_H

#import <Foundation/Foundation.h>
#import "AdbExecutionResult.h"

typedef NS_ENUM(NSInteger, AdbExecutionResultWrapper) {
	Result_InProgress,
	Result_Ok,
	Result_Canceled,
};

AdbExecutionResultWrapper wrapper(enum AdbExecutionResult result) {
	switch (result) {
		case InProgress: {
			return Result_InProgress;
		}
		case Ok: {
			return Result_Ok;
		}
		case Canceled: {
			return Result_Canceled;
		}
	}
}


#endif //DRAGON_ANDROID_TRANSFER_ADBEXECUTIONRESULTWRAPPER_H
