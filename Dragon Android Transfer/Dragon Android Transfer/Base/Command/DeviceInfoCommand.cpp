//
//  DeviceInfoCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "DeviceInfoCommand.hpp"
#include <iostream>
#include "AdbExecutorProperties.h"

DeviceInfoCommand::DeviceInfoCommand(std::string deviceId, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
    DeviceInfoCommand::deviceId = deviceId;
}

std::string DeviceInfoCommand::execute() {
    std::string commands = "-s " + deviceId + " shell getprop ro.product.model";
//     std::cout<<"Adb Device Info, Command:"<<commands<<std::endl;
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
