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

#define PRODUCTION_MODE
//#define FILE_WRITE

#ifdef PRODUCTION_MODE
#define NSLog(s,...)
#else
#endif

static NSString *convert(std::string str) {
    return [MacHelper convert:str];
}

static void writeLog(NSString* content) {
#ifdef FILE_WRITE
    content = [NSString stringWithFormat:@"%@\n",content];
    
    //get the documents directory:
    //    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = @"/Users/Kishan/dump.txt";
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else{
        [content writeToFile:fileName
                  atomically:YES
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
#endif
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
    if (str == nil) {
        return "";
    }
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
