//
//  BridgeHelper.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef BridgeHelper_h
#define BridgeHelper_h

#import "MacHelper.h"

static NSString *convert(std::string str) {
    return [MacHelper convert:str];
}

static std::string convert(NSString* str) {
    return str.UTF8String;
}

#endif /* BridgeHelper_h */
