//
//  FileSizeCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "FileSizeCommand.hpp"
#include "StringResource.h"
#include "ShellScripts.h"
#include <iostream>

std::string FileSizeCommand::execute() {
    std::string escapeDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
    std::string commands = "";
    commands = commands + ShellScripts::File_Size + escapeDoubleQuotes + escapePath(path, true) + escapeDoubleQuotes;
//    commands = commands + ShellScripts::File_Size_Prefix + path + ShellScripts::File_Size_Suffix;
    std::cout<<"Size command:"<<commands<<std::endl;
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
