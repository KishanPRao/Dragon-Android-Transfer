//
//  StorageListCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "StorageListCommand.hpp"
#include <iostream>
#include "AdbExecutorProperties.h"

/**
 * Use when the storage detection logic is smarter.
 */
std::string StorageListCommand::execute() {
	std::string commands = "devices";
//    std::cout<<"Adb List Storage, Command:"<<commands<<std::endl;
	if (executor) {
		auto properties = make_shared<AdbExecutorProperties>();
		properties->attributes = commands;
		properties->executionType = AdbExecutionType::Shell;
		auto data = executor->execute(properties);
		return data;
	}
	std::cout << "Warning, no executor" << std::endl;
	return "";
}
