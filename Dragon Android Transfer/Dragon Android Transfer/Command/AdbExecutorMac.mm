//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#import "AdbExecutor.h"
#import <Foundation/Foundation.h>
#import "StringResource.h"
#import "MacHelper.h"
#import "ShellScripts.h"
#import "CommandConfig.h"
// #import "Macros.h"

// #import "IncludeSwift.h"

// @class ShellParser;

auto EXTREME_VERBOSE = true;

string AdbExecutor::execute(AdbExecutorProperties *properties) {
	NSLog(@"DD");
	auto resourcePath = NSBundle.mainBundle.resourcePath;
	auto fileManager = NSFileManager.defaultManager;
	id adbPath = [[NSMutableString alloc] init];
	[adbPath appendString:resourcePath];
	[adbPath appendString:@"/adb"];
	auto fileExists = [fileManager fileExistsAtPath:adbPath];
	NSLog(@"File Exists, %d", fileExists);
    auto escape = [MacHelper convert:StringResource::SINGLE_QUOTES];

    NSArray<NSString *> *adbArgsArray;

	switch(properties->executionType) {
		case AdbExecutionType::Full: {
			adbArgsArray = @[@"./adb ", [MacHelper convert: properties->attributes]];
			break;
		}
		case AdbExecutionType::Shell: {
			adbArgsArray = @[@"./adb -s ", [MacHelper convert:deviceId], @" shell ", escape, [MacHelper convert: properties->attributes], escape];
			break;
		}
	}
    auto adbArgs = [adbArgsArray componentsJoinedByString:@""];
	return executeAdb(adbArgs.UTF8String);
}

void AdbExecutor::killAdbIfRunning() {
    auto commands = @"killall -9 adb";
    auto task = [[NSTask alloc] init];
    auto adbLaunchPath = [MacHelper convert:"/bin/bash"];
    task.launchPath = adbLaunchPath;
    task.arguments = @[@"-l", @"-c", commands];
    [task launch];
    [task waitUntilExit];
}

void AdbExecutor::startAdbIfNotStarted() {
    auto commands = @"./adb start-server";
    auto task = [[NSTask alloc] init];
    auto adbLaunchPath = [MacHelper convert:"/bin/bash"];
    task.launchPath = adbLaunchPath;
    task.arguments = @[@"-l", @"-c", commands];
    task.currentDirectoryPath = [MacHelper convert: adbDirectoryPath];
    [task launch];
    [task waitUntilExit];
}

string AdbExecutor::executeAdb(string commands) {
    //killAdbIfRunning();
    startAdbIfNotStarted();
    auto task = [[NSTask alloc] init];
    auto adbLaunchPath = [MacHelper convert:"/bin/bash"];
    task.launchPath = adbLaunchPath;
    task.arguments = @[@"-l", @"-c", [MacHelper convert: commands]];
    task.currentDirectoryPath = [MacHelper convert: adbDirectoryPath];
    
    auto pipe = [[NSPipe alloc] init];
    task.standardOutput = pipe;
    [task launch];
    
    auto data = [[pipe fileHandleForReading] readDataToEndOfFile];
    auto output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (EXTREME_VERBOSE) {
        NSLog(@"AdbExecutor, Commands: %@", [MacHelper convert: commands]);
    }
    // if (EXTREME_VERBOSE) {
    //     NSLog(@"AdbExecutor, %@", output);
    // }
    [task waitUntilExit];
    return [output UTF8String];
}
void AdbExecutor::setAdbDirectoryPath(const string &adbDirectoryPath) {
	AdbExecutor::adbDirectoryPath =  adbDirectoryPath;
}

void AdbExecutor::setDeviceId(const string &deviceId) {
	// Assuming always new device
	if (AdbExecutor::deviceId == deviceId) {
		NSLog(@"Warning, Same device!");
		return;
	}
	NSLog(@"New Device: %@, old: %@", [MacHelper convert:deviceId], [MacHelper convert:AdbExecutor::deviceId]);
	AdbExecutor::deviceId = deviceId;
	// AdbExecutorProperties *properties = new AdbExecutorProperties();
	// properties->attributes = ShellScripts::SHELL_TYPE_COMMAND;
	// properties->executionType = AdbExecutionType::Shell; 
    // auto data = [ShellParser cleanString: [MacHelper convert:execute(properties)]].UTF8String;
	// if (data == StringResource::GNU_TYPE) {
	// 	CommandConfig::shellType = ShellType::Gnu;
	// } else if (data == StringResource::BSD_TYPE) {
	// 	CommandConfig::shellType = ShellType::Bsd;
	// } else {
	// 	CommandConfig::shellType = ShellType::Solaris;
	// }
	// NSLog(@"New Shell Type: %@, %d", [MacHelper convert:data], CommandConfig::shellType);
}
