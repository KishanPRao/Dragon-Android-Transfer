//
// Created by Kishan P Rao on 23/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H
#define DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H


#include "AdbCommand.h"
#include <string>
#include "StringResource.h"

class ListCommand : public AdbCommand {
	std::string directoryName;
	
	std::string escape(std::string str) {
		std::string escapeDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
		return escapeDoubleQuotes + str + escapeDoubleQuotes;
	}

public:
	ListCommand(std::string, shared_ptr<AdbExecutor> executor);
//	Command* newCommand();
	
	std::string execute() override;
	
	//~ListCommand();
};


#endif //DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H
