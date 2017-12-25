//
//  DeviceListCommand.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef DeviceListCommand_hpp
#define DeviceListCommand_hpp

//#include <stdio.h>
#include "AdbCommand.h"
#include <string>

class DeviceListCommand : public AdbCommand {
public:
	DeviceListCommand(shared_ptr<AdbExecutor> executor) : AdbCommand(executor) {}

    std::string execute() override;
};

#endif /* DeviceListCommand_hpp */
