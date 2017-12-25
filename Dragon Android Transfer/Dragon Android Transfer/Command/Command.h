//
// Created by Kishan P Rao on 23/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_COMMAND_H
#define DRAGON_ANDROID_TRANSFER_COMMAND_H


#import <string>

class Command {
public:
	virtual std::string execute() = 0;
	
	virtual ~Command() {}
};


#endif //DRAGON_ANDROID_TRANSFER_COMMAND_H
