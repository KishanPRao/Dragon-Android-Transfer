//
//  AlertUtils.m
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 05/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#import "AlertUtils.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@implementation AlertUtils

+ (NSString *)input:(NSString *)title info:(NSString *)info defaultValue:(NSString *)defaultValue {
	NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
	[alert setInformativeText:info];
    [alert setAlertStyle:NSInformationalAlertStyle];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	
	NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setTranslatesAutoresizingMaskIntoConstraints:true];
	[input setStringValue:defaultValue];
	
	[alert setAccessoryView:input];
    [[alert window] setInitialFirstResponder: input];
	NSInteger button = [alert runModal];
	if (button == NSAlertFirstButtonReturn) {
		[input validateEditing];
		return [input stringValue];
	} else if (button == NSAlertSecondButtonReturn) {
		return nil;
	} else {
//		NSAssert1(NO, @"Invalid input dialog button %d", button);
		return nil;
	}
}

+ (Boolean)showAlert:(NSString *)message info:(NSString *)info confirm:(Boolean)confirmation {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:message];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:@"OK"];
	if (confirmation) {
		[alert addButtonWithTitle:@"Cancel"];
	}
	NSInteger button = [alert runModal];
	if (button == NSAlertFirstButtonReturn) {
		return true;
	}
	return false;
}


+ (void)showAlert:(NSString *)message info:(NSString *)info {
	NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:info];
	[alert setInformativeText:message];
	[alert addButtonWithTitle:@"OK"];
	[alert runModal];
}


@end
