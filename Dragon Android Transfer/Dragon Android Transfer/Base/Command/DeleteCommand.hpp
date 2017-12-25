//
//  DeleteCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef DeleteCommand_hpp
#define DeleteCommand_hpp

#include "AdbCommand.h"
#include <string>

class DeleteCommand : public AdbCommand {
    std::string path;
public:
    DeleteCommand(std::string path, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        DeleteCommand::path = path;
    }
    
    std::string execute() override;
};

#endif /* DeleteCommand_hpp */
