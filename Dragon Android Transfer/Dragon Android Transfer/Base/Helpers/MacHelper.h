//
//  MacHelper.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <string>

@interface MacHelper : NSObject
+(NSString *) convert: (std::string) originalString;
@end
