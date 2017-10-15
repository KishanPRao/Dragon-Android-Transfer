//
//  AlertUtils.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 05/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertUtils : NSObject

+ (NSString *)input:(NSString *)title info:(NSString *)info defaultValue:(NSString *)defaultValue;

+ (Boolean)showAlert:(NSString *)message info:(NSString *)info confirm:(Boolean) confirmation;


+ (void)showAlert:(NSString *)message info:(NSString *)info;

@end
