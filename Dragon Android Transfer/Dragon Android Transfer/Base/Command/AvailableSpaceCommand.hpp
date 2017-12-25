//
//  AvailableSpaceCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef AvailableSpaceCommand_hpp
#define AvailableSpaceCommand_hpp

#include "AdbCommand.h"
#include <string>

class AvailableSpaceCommand : public AdbCommand {
    std::string path;
public:
    AvailableSpaceCommand(std::string path, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        AvailableSpaceCommand::path = path;
    }
    
    std::string execute() override;
};

#endif /* AvailableSpaceCommand_hpp */
