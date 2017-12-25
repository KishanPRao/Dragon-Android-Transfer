//
//  SimpleAdbCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef SimpleAdbCommand_hpp
#define SimpleAdbCommand_hpp

#include "AdbCommand.h"
#include <string>

class SimpleAdbCommand : public AdbCommand {
	std::string commands;

public:
    SimpleAdbCommand(std::string commands, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
		SimpleAdbCommand::commands = commands;
	}
    
    std::string execute() override;
};

#endif /* SimpleAdbCommand_hpp */
