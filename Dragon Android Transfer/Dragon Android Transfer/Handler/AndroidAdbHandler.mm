//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#import "AndroidAdbHandler.h"
#import "AdbExecutor.h"


// #import <AppKit/AppKit.h>
// //#import <Foundation/Foundation.h>
// // #import <Dragon_Android_Transfer/Dragon_Android_Transfer-Swift.h>
// // #import "Dragon Android Transfer/Dragon_Android_Transfer-Swift.h"
// // #import <Dragon Android Transfer/Dragon_Android_Transfer-Swift.h>
// #import "Dragon_Android_Transfer-Swift.h"
// //#import "Dragon Android Transfer-Swift.h"
//  //#import <Dragon Android Transfer/Dragon Android Transfer-Swift.h>
// // #import <Dragon_Android_Transfer-Swift.h>

/* Helpers */
#import "IncludeSwift.h"
#import "ShellScripts.h"
#import "CommandConfig.h"
#import "BridgeHelper.h"
#import "MacHelper.h"

/* Commands */
#import "ListCommand.h"
#import "DeviceListCommand.hpp"
#import "FileExistsCommand.hpp"
#import "DeviceInfoCommand.hpp"
#import "SimpleAdbCommand.hpp"
#import "NewFolderCommand.hpp"
#import "DeleteCommand.hpp"
#import "TotalSpaceCommand.hpp"
#import "AvailableSpaceCommand.hpp"
#import "FileSizeCommand.hpp"
#import "PullCommand.hpp"
#import "PushCommand.h"

@class ShellParser;

shared_ptr<AdbExecutor> executor;
// @interface AndroidAdbHandler()

// -(std::string) execute: (AdbCommand *) command;

// @end

@implementation AndroidAdbHandler
// @synthesize deviceId;
// @synthesize adbDirectoryPath;

@synthesize device = _device;
@synthesize adbDirectoryPath = _adbDirectoryPath;

- (void)setDevice:(AndroidDevice *)device; {
	// TODO: Check device name too! Scenario: first time grant USB access (USB Debugging), no name.
	if (device != _device && ![device.id isEqualToString:_device.id]) {
		_device = device;
		if (device == nil) {
			NSLog(@"Empty Device");
			return;
		}
		executor->setDeviceId(_device.id.UTF8String);
		auto simpleCommand = make_shared<SimpleAdbCommand>(ShellScripts::SHELL_TYPE_COMMAND, executor);
		auto data = [ShellParser cleanString:convert(simpleCommand->execute())].UTF8String;
		if (data == StringResource::GNU_TYPE) {
			CommandConfig::shellType = ShellType::Gnu;
		} else if (data == StringResource::BSD_TYPE) {
			CommandConfig::shellType = ShellType::Bsd;
		} else {
			CommandConfig::shellType = ShellType::Solaris;
		}
		auto storageListInfo = make_shared<SimpleAdbCommand>(ShellScripts::STORAGE_LIST_INFO, executor)->execute();
		auto storageList = make_shared<SimpleAdbCommand>(ShellScripts::STORAGE_LIST, executor)->execute();
		
		device.storages = [ShellParser parseStorageOutput:convert(storageList) info:convert(storageListInfo)];
		
		//NSLog(@"New Shell Type: %@, %d", convert(data), CommandConfig::shellType);
		//NSLog(@"Storages: %@", device.storages);
	}
}

- (void)setAdbDirectoryPath:(NSString *)adbDirectoryPath; {
	if (adbDirectoryPath != _adbDirectoryPath) {
		_adbDirectoryPath = adbDirectoryPath;
		executor->setAdbDirectoryPath(_adbDirectoryPath.UTF8String);
		NSLog(@"Adb Dir, %@", _adbDirectoryPath);
	}
}

- (id)initWithDirectory:(NSString *)adbDirectoryPath {
	self = [super init];
	if (self) {
		executor = make_shared<AdbExecutor>();
		self.adbDirectoryPath = adbDirectoryPath;
	}
	return self;
}

-(bool) hasActiveDevice {
    if (_device == nil) {
        NSLog(@"Empty Device");
        return false;
    }
    return true;
}

- (NSArray<BaseFile *> *)getDirectoryListing:(NSString *)path {
    if (![self hasActiveDevice]) { return nil; }
	auto command = make_shared<ListCommand>(path.UTF8String, executor);
	auto listString = convert(command->execute());
	auto list = [ShellParser parseListOutput:listString currentPath:path];
	// NSLog(@"List Output, %@", list);
	return list;
}

- (NSArray<AndroidDevice *> *)getDevices {
	auto command = make_shared<DeviceListCommand>(executor);
	auto devicesString = convert(command->execute());
	auto deviceIds = [ShellParser parseDeviceListOutput:devicesString];
	// NSLog(@"List Output, %@", deviceIds);
	NSMutableArray<AndroidDevice *> *devices = [NSMutableArray new];
	
	for (NSString *deviceId in deviceIds) {
		auto command = make_shared<DeviceInfoCommand>(deviceId.UTF8String, executor);
		auto infoString = convert(command->execute());
		// NSLog(@"Info Output, %@", infoString);
		auto device = [ShellParser parseDeviceInfoOutput:deviceId infoString:infoString];
		
		[devices addObject:device];
	}
	return devices;
}

- (bool)fileExists:(NSString *)path withFileType:(bool)isFile {
    if (![self hasActiveDevice]) { return false; }
	auto command = make_shared<FileExistsCommand>(convert(path), isFile, executor);
	auto output = command->execute();
	return [ShellParser parseFileExists:convert(output)];
}

- (bool)createNewFolder:(NSString *)path {
    if (![self hasActiveDevice]) { return false; }
	auto command = make_shared<NewFolderCommand>(convert(path), executor);
	command->execute();
	return true;
}

- (void)deleteFile:(NSString *)path {
    if (![self hasActiveDevice]) { return; }
	auto command = make_shared<DeleteCommand>(convert(path), executor);
	command->execute();
}


- (NSString *)getTotalSpace:(NSString *)path {
    if (![self hasActiveDevice]) { return @""; }
	auto command = make_shared<TotalSpaceCommand>(convert(path), executor);
	return [ShellParser parseTotalSpace:convert(command->execute())];
}

- (NSString *)getAvailableSpace:(NSString *)path {
    if (![self hasActiveDevice]) { return @""; }
	auto command = make_shared<AvailableSpaceCommand>(convert(path), executor);
	return [ShellParser parseAvailableSpace:convert(command->execute())];
	
}

- (UInt64)getFileSize:(NSString *)path {
    if (![self hasActiveDevice]) { return 0; }
	auto command = make_shared<FileSizeCommand>(convert(path), executor);
	return [ShellParser parseFileSize:convert(command->execute())];
}

//- (void) pull: (void (^)(NSString * output, enum AdbExecutionResult result))completionBlock {
- (void)pull:(NSString *)sourceFile toDestination:(NSString *)destination :TransferBlock transferBlock {
    if (![self hasActiveDevice]) { return; }
	auto command = make_shared<PullCommand>(convert(sourceFile), convert(destination), [transferBlock](std::string output, AdbExecutionResult result) {
//		NSLog(@"Output Pull: %@, finished: %d", convert(output), result);
//		[pullBlock: 0, result: result];
		long progress;
		if (result == AdbExecutionResult::InProgress) {
			progress = [ShellParser parseTransferOutput:convert(output)];
		} else {
			progress = 100;
		}
		AdbExecutionResultWrapper wrapperResult = AdbExecutionResultWrapper(result);
		transferBlock(progress, wrapperResult);
	}, executor);
	/*auto outputPull =*/ convert(command->execute());
//	NSLog(@"Outer Output Pull: %@", outputPull);
}

- (void)push:(NSString *)sourceFile toDestination:(NSString *)destination :TransferBlock transferBlock {
    if (![self hasActiveDevice]) { return; }
	auto command = make_shared<PushCommand>(convert(sourceFile), convert(destination), [transferBlock](std::string output, AdbExecutionResult result) {
		long progress;
		if (result == AdbExecutionResult::InProgress) {
			progress = [ShellParser parseTransferOutput:convert(output)];
		} else {
			progress = 100;
		}
		AdbExecutionResultWrapper wrapperResult = AdbExecutionResultWrapper(result);
		transferBlock(progress, wrapperResult);
	}, executor);
	/*auto outputPull =*/ convert(command->execute());
//	NSLog(@"Outer Output Pull: %@", outputPull);
}

- (void)cancelActiveTask {
	if (executor) {
		executor->cancel();
	}
}



// - (void)dealloc
// {
//     delete executor;
// }

@end
