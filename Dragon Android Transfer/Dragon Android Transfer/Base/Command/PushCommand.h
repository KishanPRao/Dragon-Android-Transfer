//
// Created by Kishan P Rao on 27/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_PUSHCOMMAND_H
#define DRAGON_ANDROID_TRANSFER_PUSHCOMMAND_H

#include "AdbCommand.h"
#include <string>

class PushCommand : public AdbCommand {
	std::string sourcePath;
	std::string destinationPath;
	AdbCallback callback;

public:
	PushCommand(std::string sourcePath, std::string destinationPath,
			AdbCallback callback, shared_ptr<AdbExecutor> executor)
	: AdbCommand(executor) {
			PushCommand::sourcePath = sourcePath;
			PushCommand::callback = callback;
			PushCommand::destinationPath = destinationPath;
	}
	
	std::string execute() override;
};


#endif //DRAGON_ANDROID_TRANSFER_PUSHCOMMAND_H
