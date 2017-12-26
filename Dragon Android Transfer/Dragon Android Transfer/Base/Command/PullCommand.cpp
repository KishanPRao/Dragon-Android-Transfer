//
//  PullCommand.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#include "PullCommand.hpp"
#include "StringResource.h"
#include "ShellScripts.h"
#include <iostream>

std::string PullCommand::execute() {
    std::string espaceDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
    std::string commands = "";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
//    commands = commands + "cd /sdcard; ls;";
    if (executor) {
        auto properties = make_shared<AdbExecutorProperties>();
        properties->attributes = commands;
        properties->executionType = AdbExecutionType::ShellAsync;
        auto data = executor->execute(properties, callback);
        return data;
    }
    std::cout<<"Warning, no executor"<<std::endl;
    return "";
}
