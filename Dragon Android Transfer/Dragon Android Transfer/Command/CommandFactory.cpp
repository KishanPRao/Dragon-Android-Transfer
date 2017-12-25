//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#include "CommandFactory.h"
#include "ListCommand.h"

Command *CommandFactory::getCommand(CommandType type) {
	switch (type) {
		case List: {
			return new ListCommand(directoryName, executor);
		}
	}
	return nullptr;
}

void CommandFactory::setDirectoryName(const std::string &directoryName) {
    CommandFactory::directoryName = directoryName;
}

void CommandFactory::setExecutor(AdbExecutor *executor) {
    CommandFactory::executor = executor;
}
