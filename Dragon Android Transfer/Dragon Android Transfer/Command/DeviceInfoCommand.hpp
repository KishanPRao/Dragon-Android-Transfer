//
//  DeviceInfoCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef DeviceInfoCommand_hpp
#define DeviceInfoCommand_hpp

#include "AdbCommand.h"
#include <string>

class DeviceInfoCommand : public AdbCommand {
    std::string deviceId;
public:
    DeviceInfoCommand(std::string deviceId, AdbExecutor *executor);
    
    std::string execute() override;
};

#endif /* DeviceInfoCommand_hpp */
