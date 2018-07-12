//
//  NibLoader.m
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import "NibLoader.h"
#import "BridgeHelper.h"

@implementation NibLoader
+ (NSView *)loadWithNibNamed:(NSString *)nibNamed owner:(id)owner class:(Class)loadClass {
    
    NSNib * nib = [[NSNib alloc] initWithNibNamed:nibNamed bundle:nil];
    
    NSArray * objects;
    if (![nib instantiateWithOwner:owner topLevelObjects:&objects]) {
        NSLog(@"Couldn't load nib named %@", nibNamed);
        return nil;
    }
    
    for (id object in objects) {
        if ([object isKindOfClass:loadClass]) {
            return object;
        }
    }
    return nil;
}

@end
