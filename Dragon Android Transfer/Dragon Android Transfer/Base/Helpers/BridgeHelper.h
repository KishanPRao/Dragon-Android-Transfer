//
//  BridgeHelper.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

#ifndef BridgeHelper_h
#define BridgeHelper_h

#import "MacHelper.h"
//#include <iostream>

static NSString *convert(std::string str) {
    return [MacHelper convert:str];
}
/*
std::string ReplaceString(std::string subject, const std::string& search,
                          const std::string& replace) {
    size_t pos = 0;
    while ((pos = subject.find(search, pos)) != std::string::npos) {
        subject.replace(pos, search.length(), replace);
        pos += replace.length();
    }
    return subject;
}*/

static std::string convert(NSString* str) {
    std::string s = str.UTF8String;
//    size_t pos = 0;
//    std::string subject = s;
//    std::string search = "'";
//    std::string replace = "\'";
//    while ((pos = subject.find(search, pos)) != std::string::npos) {
//        subject.replace(pos, search.length(), replace);
//        pos += replace.length();
//    }
//    std::cout<<"Converted:"<<subject<<std::endl;
    return s;
}

#endif /* BridgeHelper_h */
