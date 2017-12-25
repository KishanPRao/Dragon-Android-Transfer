//
//  TotalSpaceCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef TotalSpaceCommand_hpp
#define TotalSpaceCommand_hpp

#include "AdbCommand.h"
#include <string>

class TotalSpaceCommand : public AdbCommand {
    std::string path;
public:
    TotalSpaceCommand(std::string path, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        TotalSpaceCommand::path = path;
    }
    
    std::string execute() override;
};

#endif /* TotalSpaceCommand_hpp */
