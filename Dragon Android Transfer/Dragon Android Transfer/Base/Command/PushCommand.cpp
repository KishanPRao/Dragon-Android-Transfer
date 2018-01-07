//
// Created by Kishan P Rao on 27/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#include "PushCommand.h"
#include "StringResource.h"
#include "ShellScripts.h"
#include <iostream>

std::string PushCommand::execute() {
	std::string dq = StringResource::ESCAPE_DOUBLE_QUOTES;
	std::string commands = "";
	commands = commands + "push " + dq + sourcePath + dq + " " + dq + destinationPath + dq + ";";
	if (executor) {
		auto properties = make_shared<AdbExecutorProperties>();
		properties->attributes = commands;
		properties->executionType = AdbExecutionType::DeviceAsync;
		auto data = executor->execute(properties, callback);
		return data;
	}
	std::cout << "Warning, no executor" << std::endl;
	return "";
}