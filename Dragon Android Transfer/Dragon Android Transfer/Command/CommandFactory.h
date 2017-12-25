//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_COMMANDFACTORY_H
#define DRAGON_ANDROID_TRANSFER_COMMANDFACTORY_H


#include <string>
#include "Command.h"
#include "CommandType.h"
#include "AdbExecutor.h"

class CommandFactory {
	std::string directoryName;
	
    AdbExecutor *executor;
    
public:
	
	void setDirectoryName(const std::string &directoryName);
    
    void setExecutor(AdbExecutor *executor);
	
	Command *getCommand(CommandType type);
};


#endif //DRAGON_ANDROID_TRANSFER_COMMANDFACTORY_H
