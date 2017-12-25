//
// Created by Kishan P Rao on 23/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#include <iostream>
#include "ListCommand.h"
#include "StringResource.h"
#include "CommandConfig.h"
#include "ShellType.h"
#include "ShellScripts.h"
#include "AdbExecutorProperties.h"

ListCommand::ListCommand(std::string directoryName, AdbExecutor *executor) : AdbCommand(executor) {
	ListCommand::directoryName = directoryName;
}

std::string ListCommand::execute() {
	std::string espaceDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
	std::string name = espaceDoubleQuotes + "$name" + espaceDoubleQuotes;
//	StringResource::ESCAPE_DOUBLE_QUOTES = "ABC";
	std::string commands;
	switch (CommandConfig::shellType) {
		case ShellType::Gnu:
		case ShellType::Bsd: {
			commands = ShellScripts::GNU_LS_FILE_SIZE;
			break;
		}
        case ShellType::Solaris: {
			commands = ShellScripts::SOLARIS_LS_FILE_SIZE;
			break;
		}
	}
	// std::cout<<"Using Shell Type:"<<CommandConfig::shellType<<std::endl;
	//TODO: While retrieving ls output and appending FILE etc, remove illegal characters (like "\n")
	commands = commands + "cd " + espaceDoubleQuotes + directoryName + espaceDoubleQuotes + "; ls | for name in *; do echo " + name +
			"; if [ -d " + name + " ]; then echo " + espaceDoubleQuotes + StringResource::DIRECTORY_TYPE + espaceDoubleQuotes + "; echo \"0\"; else echo " + espaceDoubleQuotes + StringResource::FILE_TYPE + espaceDoubleQuotes + "; " + ShellScripts::LS_FILE_SIZE_COMMAND + " " + name + "; fi; done;";
	
	std::cout<<"Adb List Data"<<directoryName<<", Command:"<<commands;
//	let output = adbShell(commands)
	if (executor) {
		AdbExecutorProperties *properties = new AdbExecutorProperties();
		properties->attributes = commands;
		properties->executionType = AdbExecutionType::Shell;
		auto data = executor->execute(properties);
		delete properties;
		return data;
	}
	std::cout<<"Warning, no executor"<<std::endl;
	return "";
}

//Command *ListCommand::newCommand() {
//	return new ListCommand();
//}

//ListCommand::~ListCommand() {}
