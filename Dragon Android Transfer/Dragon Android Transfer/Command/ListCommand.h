//
// Created by Kishan P Rao on 23/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

#ifndef DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H
#define DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H


#include "Command.h"

class ListCommand : public Command {
public:
//	Command* newCommand();
	
	void execute() override;
	
	~ListCommand();
};


#endif //DRAGON_ANDROID_TRANSFER_LISTCOMMAND_H
