//
//  AdbExecutorProperties.hpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef AdbExecutorProperties_h
#define AdbExecutorProperties_h

#include <string>
#include "AdbExecutionType.h"

class AdbExecutorProperties {
public:
    std::string attributes;
    
    AdbExecutionType executionType;
};

#endif /* AdbExecutorProperties_h */
