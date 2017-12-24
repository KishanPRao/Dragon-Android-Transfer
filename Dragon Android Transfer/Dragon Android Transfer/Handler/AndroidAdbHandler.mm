//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#import "AndroidAdbHandler.h"
#import "ListCommand.h"


@implementation AndroidAdbHandler {
	
}
+ (void)test {
	NSLog(@"TEST");
//	new ListCommand().execute();
	ListCommand *command = new ListCommand();
	command->execute();
	delete command;
}

@end