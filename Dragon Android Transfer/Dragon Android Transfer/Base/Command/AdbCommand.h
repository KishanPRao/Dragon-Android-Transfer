//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_ADBCOMMAND_H
#define DRAGON_ANDROID_TRANSFER_ADBCOMMAND_H


#import "Command.h"
#import "Macros.h"

#import "AdbExecutor.h"

class AdbCommand : public Command {
protected:
	shared_ptr<AdbExecutor> executor;

	AdbCommand(shared_ptr<AdbExecutor> executor) {
		AdbCommand::executor = executor;
	}
    
//    Move to a common utils namespace.
    void replaceAll(std::string& str, const std::string& from, const std::string& to) {
        if(from.empty())
            return;
        size_t start_pos = 0;
        while((start_pos = str.find(from, start_pos)) != std::string::npos) {
            str.replace(start_pos, from.length(), to);
            start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
        }
    }
    
    std::string escapePathInternal(std::string str, char const *from, char const *to) {
        std::string from_s = from;
        std::string to_s = to;
        replaceAll(str, from, to);
        return str;
    }
    
    std::string escapePath(std::string str, bool inSingleQuotes = false) {
        str = escapePathInternal(str, "\"", "\\\"");
        if (inSingleQuotes) {
            str = escapePathInternal(str, "'", "'\\''");
        }
        return str;
    }
};


#endif //DRAGON_ANDROID_TRANSFER_ADBCOMMAND_H
