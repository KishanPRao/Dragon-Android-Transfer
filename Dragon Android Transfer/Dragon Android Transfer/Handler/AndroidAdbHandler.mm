//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#import "AndroidAdbHandler.h"
#import "MacHelper.h"
#import "AdbExecutor.h"

#import "IncludeSwift.h"

// #import <AppKit/AppKit.h>
// //#import <Foundation/Foundation.h>
// // #import <Dragon_Android_Transfer/Dragon_Android_Transfer-Swift.h>
// // #import "Dragon Android Transfer/Dragon_Android_Transfer-Swift.h"
// // #import <Dragon Android Transfer/Dragon_Android_Transfer-Swift.h>
// #import "Dragon_Android_Transfer-Swift.h"
// //#import "Dragon Android Transfer-Swift.h"
//  //#import <Dragon Android Transfer/Dragon Android Transfer-Swift.h>
// // #import <Dragon_Android_Transfer-Swift.h>

#import "ListCommand.h"
#import "DeviceListCommand.hpp"
#import "DeviceInfoCommand.hpp"
#import "ShellScripts.h"
#import "CommandConfig.h"

@class ShellParser;

AdbExecutor *executor;
// @interface AndroidAdbHandler()

// -(std::string) execute: (AdbCommand *) command;

// @end

@implementation AndroidAdbHandler
// @synthesize deviceId;
// @synthesize adbDirectoryPath;

@synthesize deviceId = _deviceId;
@synthesize adbDirectoryPath = _adbDirectoryPath;

- (void)setDeviceId:(NSString *)deviceId;
{
    if (deviceId != _deviceId && ![deviceId isEqualToString:_deviceId])
    {
        _deviceId = deviceId;
        executor->setDeviceId(_deviceId.UTF8String);
        AdbExecutorProperties *properties = new AdbExecutorProperties();
        properties->attributes = ShellScripts::SHELL_TYPE_COMMAND;
        properties->executionType = AdbExecutionType::Shell;
        auto data = [ShellParser cleanString: [MacHelper convert:executor->execute(properties)]].UTF8String;
        if (data == StringResource::GNU_TYPE) {
            CommandConfig::shellType = ShellType::Gnu;
        } else if (data == StringResource::BSD_TYPE) {
            CommandConfig::shellType = ShellType::Bsd;
        } else {
            CommandConfig::shellType = ShellType::Solaris;
        }
        NSLog(@"New Shell Type: %@, %d", [MacHelper convert:data], CommandConfig::shellType);
    }
}

- (void)setAdbDirectoryPath:(NSString *)adbDirectoryPath;
{
    if (adbDirectoryPath != _adbDirectoryPath)
    {
        _adbDirectoryPath = adbDirectoryPath;
        executor->setAdbDirectoryPath(_adbDirectoryPath.UTF8String);
        NSLog(@"Adb Dir, %@", _adbDirectoryPath);
    }
}

- (id)initWithDirectory:(NSString *)adbDirectoryPath {
    self = [super init];
    if (self) {
        executor = new AdbExecutor();
        self.adbDirectoryPath = adbDirectoryPath;
    }
    return self;
}

- (NSArray<BaseFile *> *) getDirectoryListing: (NSString *) path {
	ListCommand *command = new ListCommand(path.UTF8String, executor);
	// TODO: Move Executor to init.
	auto listString = command->execute();
    auto list = [ShellParser parseListOutput: [MacHelper convert:listString]];
    // NSLog(@"List Output, %@", list);
	delete command;
	return list;
}

- (NSArray<AndroidDevice *> *) getDevices {
    DeviceListCommand *command = new DeviceListCommand(executor);
    auto devicesString = command->execute();
    auto deviceIds = [ShellParser parseDeviceListOutput: [MacHelper convert:devicesString]];
    NSLog(@"List Output, %@", deviceIds);
    NSMutableArray<AndroidDevice *> *devices = [NSMutableArray new];

    for (NSString *deviceId in deviceIds) {
        DeviceInfoCommand *command = new DeviceInfoCommand(deviceId.UTF8String, executor);
        auto infoString = command->execute();
		NSLog(@"Info Output, %@", [MacHelper convert:infoString]);
        auto device = [ShellParser parseDeviceInfoOutput: deviceId infoString:
                           [MacHelper convert:infoString]];

        [devices addObject:device];
        delete command;
    }
    delete command;
    return devices;
}

- (void)dealloc
{
    delete executor;
}

@end
