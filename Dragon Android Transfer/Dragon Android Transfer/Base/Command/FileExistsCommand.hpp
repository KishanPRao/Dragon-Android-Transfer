//
//  FileExistsCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef FileExistsCommand_hpp
#define FileExistsCommand_hpp

#include "AdbCommand.h"
#include <string>

class FileExistsCommand : public AdbCommand {
    bool isFile;
    std::string filePath;
public:
    FileExistsCommand(std::string filePath, bool isFile, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        FileExistsCommand::filePath = filePath;
        FileExistsCommand::isFile = isFile;
    }
    
    std::string execute() override;
};

#endif /* FileExistsCommand_hpp */
