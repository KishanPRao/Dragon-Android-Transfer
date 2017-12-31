//
//  NibLoader.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NibLoader : NSObject
+ (NSView *)loadWithNibNamed:(NSString *)nibNamed owner:(id)owner class:(Class)loadClass;
@end
