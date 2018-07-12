//
//  SimpleAdbCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "SimpleAdbCommand.hpp"
#include <iostream>
#include "AdbExecutorProperties.h"

std::string SimpleAdbCommand::execute() {
//    std::cout<<"Adb Simple Command:"<<commands<<std::endl;
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
