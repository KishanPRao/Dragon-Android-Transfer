//
//  AvailableSpaceCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "AvailableSpaceCommand.hpp"
#include "StringResource.h"
#include "ShellScripts.h"
#include "CommandConfig.h"
#include "ShellType.h"
#include <iostream>

std::string AvailableSpaceCommand::execute() {
    std::string escapeDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
    std::string diskCommand;
    switch (CommandConfig::shellType) {
        case ShellType::Gnu:
            diskCommand = ShellScripts::Gnu_Disk;
            break;
        case ShellType::Bsd:
            diskCommand = ShellScripts::Bsd_Disk;
            break;
        case ShellType::Solaris:
            diskCommand = ShellScripts::Solaris_Disk;
            break;
        default:
            break;
    }
    std::string commands = "";
    commands = commands + diskCommand + escapeDoubleQuotes + path + escapeDoubleQuotes;
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
