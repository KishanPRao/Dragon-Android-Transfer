//
// Created by Kishan P Rao on 17/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

struct AndroidShellScripts {
	fileprivate static let escapeDoubleQuotes = StringResource.ESCAPE_DOUBLE_QUOTES
	public static let JAVA_TYPE_COMMAND =
			"TYPE=" + escapeDoubleQuotes + escapeDoubleQuotes + ";" +
					"GNU=" + escapeDoubleQuotes + StringResource.GNU_TYPE + escapeDoubleQuotes + ";" +
					"BSD=" + escapeDoubleQuotes + StringResource.BSD_TYPE + escapeDoubleQuotes + ";" +
					"SOLARIS=" + escapeDoubleQuotes + StringResource.SOLARIS_TYPE + escapeDoubleQuotes + ";" +
					"if ls --color -d . >/dev/null 2>&1; then " +
					"TYPE=$GNU;" +
					"elif ls -G -d . >/dev/null 2>&1; then " +
					"TYPE=$BSD;" +
					"else " +
					"TYPE=$SOLARIS;" +
					"fi;" +
					"echo \"$TYPE\";"
	
	public static let LS_FILE_SIZE_COMMAND = "LS_FILE"
	public static let GNU_LS_FILE_SIZE = "LS_FILE() { output=$(ls -sk -- \"$1\"); first=${output%% *}; echo \"$first\"; }\n"
	public static let SOLARIS_LS_FILE_SIZE = "LS_FILE() { output=$(ls -s -- \"$1\"); first=${output%% *}; echo \"$first\"; }\n"
	public static let GNU_LS_SIZE_COMMAND_NAME = "GNU_LS"
	public static let GNU_LS_SIZE_COMMAND = "GNU_LS(){ lsOutput=$(ls -AskLR -- \"$1\"); output=$(echo \"$lsOutput\" | grep '^total [0-9]*$'); total=0; for size in $output; do if [ $size = \"total\" ]; then continue; fi; total=$(( total + size )); done; echo \"$total\"; }\n"
//	private static let SOLARIS_LS_SIZE_COMMAND = "SOLARIS_LS(){ total=0; for a in $(ls -sR \"$1\" | grep '^total [0-9]*$'); do if [ $a = \"total\" ]; then continue; fi; total=$(( total + a )); done; echo \"$total\"; }\n"
	public static let SOLARIS_LS_SIZE_COMMAND_NAME = "SOLARIS_LS"
	public static let SOLARIS_LS_SIZE_COMMAND = "SOLARIS_LS(){ lsOutput=$(ls -sR -- \"$1\"); output=$(echo \"$lsOutput\" | grep '^total [0-9]*$'); total=0; for size in $output; do if [ $size = \"total\" ]; then continue; fi; total=$(( total + size )); done; echo \"$total\"; }\n"
	
	public static let GNU_LS_SIZE = GNU_LS_FILE_SIZE + GNU_LS_SIZE_COMMAND + "ls | for name in *; do echo \"$name\"; if [ -d \"$name\" ]; then echo \"DIRECTORY\"; GNU_LS \"$name\"; else echo \"FILE\"; LS_FILE \"$name\"; fi; done;"

//	private static let BSD_LS_SIZE_COMMAND = GNU_LS_SIZE
	public static let BSD_LS_SIZE = GNU_LS_SIZE
	public static let SOLARIS_LS_SIZE = GNU_LS_FILE_SIZE + SOLARIS_LS_SIZE_COMMAND + "ls | for name in *; do echo \"$name\"; if [ -d \"$name\" ]; then echo \"DIRECTORY\"; SOLARIS_LS \"$name\"; else echo \"FILE\"; LS_FILE \"$name\"; fi; done;"
}