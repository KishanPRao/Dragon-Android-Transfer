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

DeviceInfoCommand::DeviceInfoCommand(std::string deviceId, AdbExecutor *executor) : AdbCommand(executor) {
    DeviceInfoCommand::deviceId = deviceId;
}

std::string DeviceInfoCommand::execute() {
    std::string commands = "-s " + deviceId + " shell getprop ro.product.model";
    std::cout<<"Adb List Devices, Command:"<<commands;
    if (executor) {
		AdbExecutorProperties *properties = new AdbExecutorProperties();
		properties->attributes = commands;
		properties->executionType = AdbExecutionType::Full;
		auto data = executor->execute(properties);
		delete properties;
		return data;
	}
    std::cout<<"Warning, no executor"<<std::endl;
    return "";
}
