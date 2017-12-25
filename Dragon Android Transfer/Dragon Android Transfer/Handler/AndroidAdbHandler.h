//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AdbExecutor.h"

//#import "Dragon_Android_Transfer-Swift.h"

@class BaseFile;
@class AndroidDevice;
// @class AdbExecutor;

//extern NSString * const MYSomethingHappenedNotification;

//extern AdbExecutor * const executor;

/*
 Controls all Adb related operations.
 Translates shell output to approp data that can be used by upper layer.
 */
// TODO: Check if possible to convert as C++ class.
@interface AndroidAdbHandler : NSObject
@property(nonatomic, retain) AndroidDevice *device;
@property(nonatomic, retain) NSString *adbDirectoryPath;
//@property (nonatomic, retain) AdbExecutor *executor;

//AdbExecutor *executor;

- (id)initWithDirectory:(NSString *)adbDirectoryPath;

- (NSArray<BaseFile *> *)getDirectoryListing:(NSString *)path;

- (NSArray<AndroidDevice *> *_Nonnull)getDevices;

- (bool)fileExists:(NSString *)path withFileType:(bool)isFile;

- (bool)createNewFolder:(NSString *)path;

- (void)deleteFile:(NSString *)path;

- (NSString *)getTotalSpace:(NSString *)path;

- (NSString *)getAvailableSpace:(NSString *)path;

- (UInt64)getFileSize:(NSString *)path;
@end
