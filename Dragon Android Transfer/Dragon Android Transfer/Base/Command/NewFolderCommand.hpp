//
//  NewFolderCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef NewFolderCommand_hpp
#define NewFolderCommand_hpp

#include "AdbCommand.h"
#include <string>

class NewFolderCommand : public AdbCommand {
    std::string folderPath;
public:
    NewFolderCommand(std::string folderPath, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        NewFolderCommand::folderPath = folderPath;
    }
    
    std::string execute() override;
};


#endif /* NewFolderCommand_hpp */
