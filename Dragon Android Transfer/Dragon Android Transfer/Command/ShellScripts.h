//
// Created by Kishan P Rao on 24/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_SHELLSCRIPTS_H
#define DRAGON_ANDROID_TRANSFER_SHELLSCRIPTS_H


#include <string>
#include "StringResource.h"

namespace ShellScripts {
	static std::string espaceDoubleQuotes = StringResource::ESCAPE_DOUBLE_QUOTES;
	static std::string SHELL_TYPE_COMMAND =
			"TYPE=" + espaceDoubleQuotes + espaceDoubleQuotes + ";" +
					"GNU=" + espaceDoubleQuotes + StringResource::GNU_TYPE + espaceDoubleQuotes + ";" +
					"BSD=" + espaceDoubleQuotes + StringResource::BSD_TYPE + espaceDoubleQuotes + ";" +
					"SOLARIS=" + espaceDoubleQuotes + StringResource::SOLARIS_TYPE + espaceDoubleQuotes + ";" +
					"if ls --color -d . >/dev/null 2>&1; then " +
					"TYPE=$GNU;" +
					"elif ls -G -d . >/dev/null 2>&1; then " +
					"TYPE=$BSD;" +
					"else " +
					"TYPE=$SOLARIS;" +
					"fi;" +
					"echo \"$TYPE\";";
	
	static std::string LS_FILE_SIZE_COMMAND = "LS_FILE";
	static std::string GNU_LS_FILE_SIZE = "LS_FILE() { output=$(ls -sk -- \"$1\"); first=${output%% *}; echo \"$first\"; }\n";
	static std::string SOLARIS_LS_FILE_SIZE = "LS_FILE() { output=$(ls -s -- \"$1\"); first=${output%% *}; echo \"$first\"; }\n";
	static std::string GNU_LS_SIZE_COMMAND_NAME = "GNU_LS";
	static std::string GNU_LS_SIZE_COMMAND = "GNU_LS(){ lsOutput=$(ls -AskLR -- \"$1\"); output=$(echo \"$lsOutput\" | grep '^total [0-9]*$'); total=0; for size in $output; do if [ $size = \"total\" ]; then continue; fi; total=$(( total + size )); done; echo \"$total\"; }\n";
	static std::string SOLARIS_LS_SIZE_COMMAND_NAME = "SOLARIS_LS";
	static std::string SOLARIS_LS_SIZE_COMMAND = "SOLARIS_LS(){ lsOutput=$(ls -sR -- \"$1\"); output=$(echo \"$lsOutput\" | grep '^total [0-9]*$'); total=0; for size in $output; do if [ $size = \"total\" ]; then continue; fi; total=$(( total + size )); done; echo \"$total\"; }\n";
	
	static std::string GNU_LS_SIZE = GNU_LS_FILE_SIZE + GNU_LS_SIZE_COMMAND + "ls | for name in *; do echo \"$name\"; if [ -d \"$name\" ]; then echo \"DIRECTORY\"; GNU_LS \"$name\"; else echo \"FILE\"; LS_FILE \"$name\"; fi; done;";

	static std::string BSD_LS_SIZE = GNU_LS_SIZE;
	static std::string SOLARIS_LS_SIZE = GNU_LS_FILE_SIZE + SOLARIS_LS_SIZE_COMMAND + "ls | for name in *; do echo \"$name\"; if [ -d \"$name\" ]; then echo \"DIRECTORY\"; SOLARIS_LS \"$name\"; else echo \"FILE\"; LS_FILE \"$name\"; fi; done;";
};


#endif //DRAGON_ANDROID_TRANSFER_SHELLSCRIPTS_H
