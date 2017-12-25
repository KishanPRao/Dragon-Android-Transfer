//
//  FileSizeCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef FileSizeCommand_hpp
#define FileSizeCommand_hpp

#include "AdbCommand.h"
#include <string>

class FileSizeCommand : public AdbCommand {
    std::string path;
public:
    FileSizeCommand(std::string path, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        FileSizeCommand::path = path;
    }
    
    std::string execute() override;
};

#endif /* FileSizeCommand_hpp */
