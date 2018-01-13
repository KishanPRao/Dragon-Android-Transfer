//
// Created by Kishan P Rao on 23/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#include <iostream>
#include "ListCommand.h"
#include "CommandConfig.h"
#include "ShellType.h"
#include "ShellScripts.h"
#include "AdbExecutorProperties.h"

ListCommand::ListCommand(std::string directoryName, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
	ListCommand::directoryName = directoryName;
}

std::string ListCommand::execute() {
	std::string escapeDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
//	StringResource::ESCAPE_DOUBLE_QUOTES = "ABC";
	std::string commands;
	switch (CommandConfig::shellType) {
		case ShellType::Gnu:
		case ShellType::Bsd: {
			commands = ShellScripts::GNU_LS_FILE_SIZE;
//            commands = "LS_FILE() { echo \"0\"; }\n";
			break;
		}
        case ShellType::Solaris: {
			commands = ShellScripts::SOLARIS_LS_FILE_SIZE;
			break;
		}
	}
	// std::cout<<"Using Shell Type:"<<CommandConfig::shellType<<std::endl;
	//TODO: While retrieving ls output and appending FILE etc, remove illegal characters (like "\n")
	/*
	commands = commands + "cd " + escapeDoubleQuotes + directoryName + escapeDoubleQuotes + "; ls | for name in *; do echo " + name +
			"; if [ -d " + name + " ]; then echo " + escapeDoubleQuotes + StringResource::DIRECTORY_TYPE + escapeDoubleQuotes + "; echo \"0\"; else echo " + escapeDoubleQuotes + StringResource::FILE_TYPE + escapeDoubleQuotes + "; " + ShellScripts::LS_FILE_SIZE_COMMAND + " " + name + "; fi; done;";
			*/
	
	std::string location = directoryName;
	std::string escapedOne =  escape("1");
	std::string escapedZero =  escape("0");
	std::string escapedArg =  escape("$1");
	std::string dirExistsScript="dir_exists() { if [ -d " + escapedArg + " ]; then return " + escape("1") + "; else return " + escape("0") + "; fi };";
	std::string dirNotEmptyScript="dir_not_empty() { change_dir " + escapedArg + "; count=$(ls | wc -l); if [ " + escape("$count") + " = " + escapedZero + " ]; then return " + escapedZero + "; else return " + escapedOne + "; fi; };";
	std::string changeDirScript="change_dir() { cd " + escapedArg + ";};";
	std::string validDirectoryScript="validDirectory() { dir_exists " + escapedArg + "; result=$?; if [ " + escape("$result") + " -eq " + escapedOne + " ]; then dir_not_empty " + escapedArg +"; result=$?; return " + escape("$result") + "; fi; };";
	std::string locationScript="location=\"" + location + "\";";
	std::string name = escapeDoubleQuotes + "$name" + escapeDoubleQuotes;
	std::string listCheckScriptStart="validDirectory " + escape("$location") + "; result=$?; if [ " + escape("$result") + " -eq " + escapedZero + " ]; then echo ''; else ";
	std::string listCheckScriptEnd=" fi";

	std::string listScript= "ls | for name in *; do echo " + name +
				"; if [ -d " + name + " ]; then echo " + escapeDoubleQuotes + StringResource::DIRECTORY_TYPE + escapeDoubleQuotes + "; echo \"0\"; else echo " + escapeDoubleQuotes + StringResource::FILE_TYPE + escapeDoubleQuotes + "; " + ShellScripts::LS_FILE_SIZE_COMMAND + " " + name + "; fi; done;";

	commands = commands  + locationScript + dirExistsScript + changeDirScript + dirNotEmptyScript + validDirectoryScript + listCheckScriptStart +listScript + listCheckScriptEnd;
	
//	std::cout<<"Adb List Data"<<directoryName<<", Command:"<<commands<<std::endl;
//	let output = adbShell(commands)
	if (executor) {
        auto properties = make_shared<AdbExecutorProperties>();
		properties->attributes = commands;
		properties->executionType = AdbExecutionType::Shell;
		auto data = executor->execute(properties);
		return data;
	}
	std::cout<<"Warning, no executor"<<std::endl;
	return "";
}

//Command *ListCommand::newCommand() {
//	return new ListCommand();
//}

//ListCommand::~ListCommand() {}
