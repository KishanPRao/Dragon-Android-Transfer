//
//  DeleteCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "DeleteCommand.hpp"
#include "StringResource.h"
#include <iostream>

std::string DeleteCommand::execute() {
    std::string escapeDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
    std::string commands = "";
    commands = commands + "rm -rf " + escapeDoubleQuotes + path + escapeDoubleQuotes;
    std::cout<<"Delete:"<< commands<<std::endl;
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
