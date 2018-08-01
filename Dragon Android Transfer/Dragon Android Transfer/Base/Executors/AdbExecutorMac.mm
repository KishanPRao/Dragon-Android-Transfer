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
//    auto resourcePath = NSBundle.mainBundle.resourcePath;
    auto resourcePath = NSSearchPathForDirectoriesInDomains(NSApplicationScriptsDirectory, NSUserDomainMask, true)[0];
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
		return executeAdb(adbArgs.UTF8String, properties->executionType, callback);
	}
}

void AdbExecutor::killAdbIfRunning() {
	auto commands = @"killall -9 adb";
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
//    task.arguments = @[@"-l", @"-c", commands];
    task.arguments = @[@"-c", commands];
	[task launch];
	[task waitUntilExit];
}

void AdbExecutor::startAdbIfNotStarted() {
	auto commands = @"./adb start-server";
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-c", commands];
	task.currentDirectoryPath = convert(adbDirectoryPath);
	[task launch];
	[task waitUntilExit];
//    NSLog(@"AdbExecutor, startAdbIfNotStarted: Exit Status: %d", task.terminationStatus);
}

string AdbExecutor::executeAdb(string commands, AdbExecutionType executionType, AdbCallback callback) {
	//killAdbIfRunning();
	startAdbIfNotStarted();
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-c", convert(commands)];
	task.currentDirectoryPath = convert(adbDirectoryPath);

//    NSLog(@"\nexecuteAdb: %s, type: %d\n", commands.c_str(), executionType);
    if (executionType == AdbExecutionType::Shell) {
        NSLog(@"\nexecuteAdb: %s\n", commands.c_str());
    }
    auto errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
	
	auto pipe = [[NSPipe alloc] init];
    task.standardOutput = pipe;
	[task launch];
	
//	TODO: On shell error, redirect, send empty or something similar. No effect to UI!
	auto data = [[pipe fileHandleForReading] readDataToEndOfFile];
	auto output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    auto errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    auto errorOutput = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
	if (EXTREME_VERBOSE) {
		NSLog(@"AdbExecutor, Commands: %@", convert(commands));
	}
//     if (EXTREME_VERBOSE) {
    NSLog(@"AdbExecutor, output: %@, error: %@", output, errorOutput);
    if ([errorOutput containsString: @"error"]) {
        callback(errorOutput.UTF8String, AdbExecutionResult::Error);
    }
//     }
	[task waitUntilExit];
	return [output UTF8String];
}

//typedef (^notification_block_t)(NSNotification *);
NSTask *activeTask = nil;
id dataAvailable;
AdbCallback *adbCallback;

bool cancelCleanup() {
    if (activeTask == nil && adbCallback != nil && dataAvailable != nil) {
        NSLog(@"AdbExecutor, cancelCleanup");
        (*adbCallback)("", AdbExecutionResult::Canceled);
        [[NSNotificationCenter defaultCenter] removeObserver: dataAvailable];
        adbCallback = nil;
        dataAvailable = nil;
        return true;
    }
    return false;
}

string AdbExecutor::executeAdb(string commands, AdbCallback callback) {
	startAdbIfNotStarted();
	auto task = [[NSTask alloc] init];
	auto adbLaunchPath = convert("/bin/bash");
	task.launchPath = adbLaunchPath;
	task.arguments = @[@"-c", convert(commands)];
	task.currentDirectoryPath = convert(adbDirectoryPath);
	auto pipe = [[NSPipe alloc] init];
	task.standardOutput = pipe;
    task.standardError = nil;
    
    NSLog(@"\nexecuteAdb, with callback: %s\n", commands.c_str());
#ifndef PRODUCTION_MODE
    auto errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
#endif
     
	activeTask = task;
    adbCallback = &callback;
//	TODO: Cancellation..
	auto outFile = [pipe fileHandleForReading];
	[outFile waitForDataInBackgroundAndNotify];
	dataAvailable = [[NSNotificationCenter defaultCenter]
			addObserverForName:NSFileHandleDataAvailableNotification
						object:outFile
						 queue:nil
					usingBlock:^(NSNotification *notification) {
                        NSLog(@"AdbExecutor, Task Block");
                        if (cancelCleanup()) {
                            NSLog(@"AdbExecutor, canceled");
                            return;
                        }
						auto data = [pipe fileHandleForReading].availableData;
//                        NSLog(@"Task Data, %@", data);
						if (data.length > 0) {
							auto str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                            NSLog(@"Task Data, %@", str);
							callback(convert(str), AdbExecutionResult::InProgress);
//                            NSLog(@"waitForDataInBackgroundAndNotify");
							[outFile waitForDataInBackgroundAndNotify];
//                            NSLog(@"waitForDataInBackgroundAndNotify, done");
						} /*else {
//							NSLog(@"Task Length 0");
//							TODO: Done Content, somehow:
							callback("", AdbExecutionResult::Ok);
							[[NSNotificationCenter defaultCenter] removeObserver: dataAvailable];
						}*/
                        if (cancelCleanup()) {
                            NSLog(@"AdbExecutor, canceled: second");
                            return;
                        }
					}];
	
	[task launch];
    NSLog(@"AdbExecutor, Task Launched");
	[task waitUntilExit];
    
    NSLog(@"AdbExecutor, Exit Status: %d", task.terminationStatus);
    
#ifndef PRODUCTION_MODE
    auto errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    auto errorOutput = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    NSLog(@"AdbExecutor, Error: %@", errorOutput);
#endif
    NSLog(@"AdbExecutor, Task After Exit");
    //    TODO: Handle error state!
    /*if (task.terminationStatus) {
        auto data = [pipe fileHandleForReading].availableData;
        auto str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"AdbExecutor, error output:%@", str);
    }*/
	if (activeTask != nil && dataAvailable != nil) {
		callback("", AdbExecutionResult::Ok);
		[[NSNotificationCenter defaultCenter] removeObserver: dataAvailable];
	}
	activeTask = nil;
    dataAvailable = nil;
    adbCallback = nil;
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
        if (cancelCleanup()) {
            NSLog(@"AdbExecutor, cancel, canceled");
            return;
        }
	}
}
