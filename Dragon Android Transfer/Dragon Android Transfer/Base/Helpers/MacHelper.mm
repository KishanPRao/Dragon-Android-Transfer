//
//  MacHelper.m
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import "MacHelper.h"

@implementation MacHelper
+(NSString *) convert: (std::string) originalString {
    return [NSString stringWithUTF8String:originalString.c_str()];
}
@end
