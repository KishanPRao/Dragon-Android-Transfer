//
// Created by Kishan P Rao on 23/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H
#define DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H


#include "AdbCommand.h"
#include <string>

class ListCommand : public AdbCommand {
	std::string directoryName;

public:
	ListCommand(std::string, AdbExecutor *executor);
//	Command* newCommand();
	
	std::string execute() override;
	
	//~ListCommand();
};


#endif //DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H