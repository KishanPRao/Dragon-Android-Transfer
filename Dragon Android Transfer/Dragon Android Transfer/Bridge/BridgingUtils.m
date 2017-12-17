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

@end
