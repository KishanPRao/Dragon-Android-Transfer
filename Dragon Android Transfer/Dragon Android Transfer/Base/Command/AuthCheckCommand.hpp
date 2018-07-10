//
//  AuthCheckCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 10/07/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#ifndef AuthCheckCommand_hpp
#define AuthCheckCommand_hpp

#include "AdbCommand.h"
#include <string>

class AuthCheckCommand : public AdbCommand {
    AdbCallback callback;
    std::string deviceId;
    
public:
    AuthCheckCommand(AdbCallback callback, std::string deviceId, shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {
        AuthCheckCommand::callback = callback;
        AuthCheckCommand::deviceId = deviceId;
    }
    
    std::string execute() override;
};


#endif /* AuthCheckCommand_hpp */
