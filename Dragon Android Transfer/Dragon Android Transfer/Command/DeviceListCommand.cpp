//
//  DeviceListCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "DeviceListCommand.hpp"
#include <iostream>
#include "AdbExecutorProperties.h"

std::string DeviceListCommand::execute() {
    std::string commands = "devices";
    // std::cout<<"Adb List Devices, Command:"<<commands<<std::endl;
    if (executor) {
        auto properties = make_shared<AdbExecutorProperties>();
		properties->attributes = commands;
		properties->executionType = AdbExecutionType::Full;
		auto data = executor->execute(properties);
		return data;
	}
    std::cout<<"Warning, no executor"<<std::endl;
    return "";
}
