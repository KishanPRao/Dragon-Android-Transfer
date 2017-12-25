//
//  StorageListCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef StorageListCommand_hpp
#define StorageListCommand_hpp

#include "AdbCommand.h"
#include <string>

class StorageListCommand : public AdbCommand {
public:
    StorageListCommand(AdbExecutor *executor) : AdbCommand(executor) {}
    
    std::string execute() override;
};

#endif /* StorageListCommand_hpp */
