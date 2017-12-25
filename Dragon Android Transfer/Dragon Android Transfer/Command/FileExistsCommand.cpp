//
//  FileExistsCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "FileExistsCommand.hpp"
#include "StringResource.h"
#include <iostream>

std::string FileExistsCommand::execute() {
    std::string quotes = StringResource::ESCAPE_DOUBLE_QUOTES;
    std::string commands = "";
    commands = commands + "[ -" + (isFile ? "f" : "d") + " " + quotes + filePath + quotes + " ]" +
				" && echo " + quotes + StringResource::EXIST + quotes +
				" || echo " + quotes + StringResource::NOT_EXIST + quotes;
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
