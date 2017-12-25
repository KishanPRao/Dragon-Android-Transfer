//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_STRINGRESOURCE_H
#define DRAGON_ANDROID_TRANSFER_STRINGRESOURCE_H

#import <string>

namespace StringResource {
	static std::string ESCAPE_DOUBLE_QUOTES = "\"";
	static std::string SINGLE_QUOTES = "'";

	static std::string GNU_TYPE = "GNU";
	static std::string BSD_TYPE = "BSD";
	static std::string SOLARIS_TYPE = "SOLARIS";
	
//	TODO: Make it more specific.
	static std::string DIRECTORY_TYPE = "DT_DAT_DIRECTORY";
	static std::string FILE_TYPE = "DT_DAT_FILE";
};


#endif //DRAGON_ANDROID_TRANSFER_STRINGRESOURCE_H
