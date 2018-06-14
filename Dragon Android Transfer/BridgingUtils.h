//
//  BridgingUtils.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 18/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BridgingUtils : NSObject
+ (unsigned)parseIntFromData:(NSData *)data;

+ (long)nr_getAllocatedSize:(NSURL *)url error:(NSError * __autoreleasing *)error;

@end
