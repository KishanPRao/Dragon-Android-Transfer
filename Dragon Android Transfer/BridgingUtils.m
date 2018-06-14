//
//  BridgingUtils.m
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 18/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import "BridgingUtils.h"
#import <Cocoa/Cocoa.h>

@implementation BridgingUtils
+ (unsigned)parseIntFromData:(NSData *)data{
    
//    NSString *dataDescription = [data description];
//    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
//    
//    unsigned intData = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
//    [scanner scanHexInt:&intData];
//    NSLog(@"Val %d", intData);
////    return intData;
//    
//    int intSize = sizeof(int); // change it to fixe length
//    unsigned char * buffer = malloc(intSize * sizeof(unsigned char));
//    [data getBytes:buffer length:intSize];
//    int num = 0;
//    for (int i = 0; i < intSize; i++) {
//        num = (num << 8) + buffer[i];
//    }
//    free(buffer);
//    NSLog(@"Val %d", num);
////    return num;
//    
//    
//    intSize = sizeof(int);// change it to fixe length
//    buffer = malloc(intSize * sizeof(unsigned char));
//    [data getBytes:buffer length:intSize];
//    num = 0;
//    for (int i = intSize - 1; i >= 0; i--) {
//        num = (num << 8) + buffer[i];
//    }
//    free(buffer);
//    NSLog(@"Val %d", num);
////    return num;
//    
//    const uint8_t *bytes = [data bytes]; // pointer to the bytes in data
//    NSLog(@"Val %d", bytes[0]);
////    return bytes[0];
//    
//    NSString *stringData = [data description];
//    stringData = [stringData substringWithRange:NSMakeRange(1, [stringData length]-2)];
//    
//    unsigned dataAsInt = 0;
//    scanner = [NSScanner scannerWithString: stringData];
//    [scanner scanHexInt:& dataAsInt];
//    NSLog(@"Val %d", dataAsInt);
//    
//    int i;
//    [data getBytes: &i length: sizeof(i)];
//    NSLog(@"Val %d", i);
    
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    string = [@"0x" stringByAppendingString:string];
    
    unsigned short value;
    sscanf([string UTF8String], "%hx", &value);
    
    NSLog(@"%d", value);
    return value;
}



+ (long)nr_getAllocatedSize:(NSURL *)directoryURL error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(directoryURL != nil);
    
    // We'll sum up content size here:
    unsigned long long accumulatedSize = 0;
    
    // prefetching some properties during traversal will speed up things a bit.
    NSArray *prefetchedProperties = @[
                                      NSURLIsRegularFileKey,
                                      NSURLFileAllocatedSizeKey,
                                      NSURLTotalFileAllocatedSizeKey,
                                      ];
    
    // The error handler simply signals errors to outside code.
    __block BOOL errorDidOccur = NO;
    BOOL (^errorHandler)(NSURL *, NSError *) = ^(NSURL *url, NSError *localError) {
        if (error != NULL)
            *error = localError;
        errorDidOccur = YES;
        return NO;
    };
    
    NSNumber *fileSize;
    NSNumber *isDirectory;
    if (! [directoryURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:error])
        return NO;
    if (! [isDirectory boolValue]) {
        [directoryURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:error];
        if (fileSize == nil) {
            if (! [directoryURL getResourceValue:&fileSize forKey:NSURLFileAllocatedSizeKey error:error])
                return NO;
        }
        return fileSize.unsignedLongLongValue;
    }
        
    // We have to enumerate all directory contents, including subdirectories.
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL
                                                             includingPropertiesForKeys:prefetchedProperties
                                                                                options:(NSDirectoryEnumerationOptions)0
                                                                           errorHandler:errorHandler];
    
    // Start the traversal:
    for (NSURL *contentItemURL in enumerator) {
        
        // Bail out on errors from the errorHandler.
        if (errorDidOccur)
            return NO;
        
        // Get the type of this item, making sure we only sum up sizes of regular files.
        NSNumber *isRegularFile;
        if (! [contentItemURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:error])
            return NO;
        if (! [isRegularFile boolValue])
            continue; // Ignore anything except regular files.
        
        // To get the file's size we first try the most comprehensive value in terms of what the file may use on disk.
        // This includes metadata, compression (on file system level) and block size.
        NSNumber *fileSize;
        //        Working: NSURLFileSizeKey, expected: NSURLTotalFileAllocatedSizeKey
        [contentItemURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:error];
        
//        NSLog(@"Size: %ld", fileSize.unsignedLongLongValue);
        
        // In case the value is unavailable we use the fallback value (excluding meta data and compression)
        // This value should always be available.
        if (fileSize == nil) {
            if (! [contentItemURL getResourceValue:&fileSize forKey:NSURLFileAllocatedSizeKey error:error])
                return NO;
            
            NSAssert(fileSize != nil, @"huh? NSURLFileAllocatedSizeKey should always return a value");
        }
        
        // We're good, add up the value.
        accumulatedSize += [fileSize unsignedLongLongValue];
    }
    
    // Bail out on errors from the errorHandler.
    if (errorDidOccur)
        return NO;
    
    // We finally got it.
    return accumulatedSize;
}

@end
