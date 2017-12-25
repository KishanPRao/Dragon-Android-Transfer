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
	AdbExecutor *executor;

	AdbCommand(AdbExecutor *executor) {
		AdbCommand::executor = executor;
	}
};


#endif //DRAGON_ANDROID_TRANSFER_ADBCOMMAND_H
