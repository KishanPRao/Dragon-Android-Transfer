//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#import "AdbExecutor.h"
#import <Foundation/Foundation.h>
#import <iostream>
#import "StringResource.h"
#import "ShellScripts.h"
#import "CommandConfig.h"
#import "BridgeHelper.h"
// #import "Macros.h"

// #import "IncludeSwift.h"

// @class ShellParser;

auto EXTREME_VERBOSE = false;

string AdbExecutor::execute(shared_ptr<AdbExecutorProperties> properties, AdbCallback callback) {
	auto resourcePath = NSBundle.mainBundle.resourcePath;
	id adbPath = [[NSMutableString alloc] init];
	[adbPath appendString:resourcePath];
	[adbPath appendString:@"/adb"];
	// TODO: Move this out...
//	auto fileManager = NSFileManager.defaultManager;
//	auto fileExists = [fileManager fileExistsAtPath:adbPath];
	// NSLog(@"File Exists, %d", fileExists);
	auto escape = convert(StringResource::SINGLE_QUOTES);
	
	NSArray<NSString *> *adbArgsArray;
	
	switch (properties->executionType) {
		case AdbExecutionType::Full: {
			adbArgsArray = @[@"./adb ", convert(properties->attributes)];
			break;
		}
		case AdbExecutionType::DeviceAsync: {
			adbArgsArray = @[@"./adb -s ", convert(deviceId), @" ", convert(properties->attributes)];
			break;
		}
		case AdbExecutionType::Shell: {
			adbArgsArray = @[@"./adb -s ", convert(deviceId), @" shell ", escape, convert(properties->attributes), escape];
			break;
		}
	}
	auto adbArgs = [adbArgsArray componentsJoinedByString:@""];
	if (properties->executionType == AdbExecutionType::DeviceAsync) {
//        std::cout<<"Calling Adb Args:"<<adbArgs.UTF8String<<std::endl;
		auto output = executeAdb(adbArgs.UTF8String, callback);
//		std::cout<<"Calling Callback:"<<output<<std::endl;
//		callback(output);
		return "";
	} else {
		return executeAdb(adbArgs.UTF8String);
	}
}

void AdbExecutor::killAdbIfRunning() {
	auto commands = @"killall -9 adb";
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-l", @"-c", commands];
	[task launch];
	[task waitUntilExit];
}

void AdbExecutor::startAdbIfNotStarted() {
	auto commands = @"./adb start-server";
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-l", @"-c", commands];
	task.currentDirectoryPath = convert(adbDirectoryPath);
	[task launch];
	[task waitUntilExit];
}

string AdbExecutor::executeAdb(string commands) {
	//killAdbIfRunning();
	startAdbIfNotStarted();
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-l", @"-c", convert(commands)];
	task.currentDirectoryPath = convert(adbDirectoryPath);
	
	auto pipe = [[NSPipe alloc] init];
	task.standardOutput = pipe;
	[task launch];
	
//	TODO: On shell error, redirect, send empty or something similar. No effect to UI!
	auto data = [[pipe fileHandleForReading] readDataToEndOfFile];
	auto output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (EXTREME_VERBOSE) {
		NSLog(@"AdbExecutor, Commands: %@", convert(commands));
	}
	// if (EXTREME_VERBOSE) {
	//     NSLog(@"AdbExecutor, %@", output);
	// }
	[task waitUntilExit];
	return [output UTF8String];
}

//typedef (^notification_block_t)(NSNotification *);
NSTask *activeTask = nil;
string AdbExecutor::executeAdb(string commands, AdbCallback callback) {
	startAdbIfNotStarted();
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-l", @"-c", convert(commands)];
	task.currentDirectoryPath = convert(adbDirectoryPath);
	auto pipe = [[NSPipe alloc] init];
	task.standardOutput = pipe;
	task.standardError = nil;
	activeTask = task;
//	TODO: Cancellation..
	auto outFile = [pipe fileHandleForReading];
	[outFile waitForDataInBackgroundAndNotify];
	id dataAvailable;
	dataAvailable = [[NSNotificationCenter defaultCenter]
			addObserverForName:NSFileHandleDataAvailableNotification
						object:outFile
						 queue:nil
					usingBlock:^(NSNotification *notification) {
//						NSLog(@"Task Block");
						if (activeTask == nil) {
							callback("", AdbExecutionResult::Canceled);
							return;
						}
						auto data = [pipe fileHandleForReading].availableData;
//                        NSLog(@"Task Data, %@", data);
						if (data.length > 0) {
							auto str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                            NSLog(@"Task Data, %@", str);
							callback(convert(str), AdbExecutionResult::InProgress);
							[outFile waitForDataInBackgroundAndNotify];
						} /*else {
//							NSLog(@"Task Length 0");
//							TODO: Done Content, somehow:
							callback("", AdbExecutionResult::Ok);
							[[NSNotificationCenter defaultCenter] removeObserver: dataAvailable];
						}*/
					}];
	
	[task launch];
//	NSLog(@"Task Launched");
	[task waitUntilExit];
//	NSLog(@"Task After Exit");
	if (activeTask != nil) {
		callback("", AdbExecutionResult::Ok);
		[[NSNotificationCenter defaultCenter] removeObserver: dataAvailable];
	}
	activeTask = nil;
	return "";
}

void AdbExecutor::setAdbDirectoryPath(const string &adbDirectoryPath) {
	AdbExecutor::adbDirectoryPath = adbDirectoryPath;
}

void AdbExecutor::setDeviceId(const string &deviceId) {
	// Assuming always new device
	if (AdbExecutor::deviceId == deviceId) {
		NSLog(@"Warning, Same device!");
		return;
	}
	NSLog(@"AdbExec, New Device: %@, old: %@", convert(deviceId), convert(AdbExecutor::deviceId));
	AdbExecutor::deviceId = deviceId;
}

void AdbExecutor::cancel() {
	if (activeTask != nil) {
		NSLog(@"Cancelling active task");
		[activeTask terminate];
		activeTask = nil;
	}
}
