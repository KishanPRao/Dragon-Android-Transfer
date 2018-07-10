//
//  AuthCheckCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 10/07/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#include "AuthCheckCommand.hpp"
#include "StringResource.h"
#include "ShellScripts.h"
#include <iostream>

std::string AuthCheckCommand::execute() {
//    Device Info command.
    std::string commands = "-s " + deviceId + " shell getprop ro.product.model";
    std::cout<<"Adb Device Info, Command:"<<commands<<std::endl;
    if (executor) {
        auto properties = make_shared<AdbExecutorProperties>();
        properties->attributes = commands;
        properties->executionType = AdbExecutionType::Full;
        auto data = executor->execute(properties, callback);
        return data;
    }
    std::cout<<"Warning, no executor"<<std::endl;
    return "";
}
