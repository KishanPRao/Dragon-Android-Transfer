//
//  PullCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef PullCommand_hpp
#define PullCommand_hpp

#include "AdbCommand.h"
#include <string>

class PullCommand : public AdbCommand {
    std::string sourcePath;
    std::string destinationPath;
public:
    PullCommand(std::string sourcePath,std::string destinationPath, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        PullCommand::sourcePath = sourcePath;
        PullCommand::destinationPath = destinationPath;
    }
    
    std::string execute() override;
};

#endif /* PullCommand_hpp */
