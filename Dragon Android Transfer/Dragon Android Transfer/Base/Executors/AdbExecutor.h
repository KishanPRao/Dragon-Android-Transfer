//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_ADBEXECUTOR_H
#define DRAGON_ANDROID_TRANSFER_ADBEXECUTOR_H

#import <string>
#include "Macros.h"
#include "AdbExecutorProperties.h"

using namespace std;

class AdbExecutor {
private:
	string deviceId;
    
    string adbDirectoryPath;
    
    string executeAdb(string );
    
    void startAdbIfNotStarted();
	
public:
    
    void setDeviceId(const string &deviceId);
    
    void setAdbDirectoryPath(const string &adbDirectoryPath);
    
    void killAdbIfRunning();
	
	string execute(shared_ptr<AdbExecutorProperties> properties);
};


#endif //DRAGON_ANDROID_TRANSFER_ADBEXECUTOR_H
