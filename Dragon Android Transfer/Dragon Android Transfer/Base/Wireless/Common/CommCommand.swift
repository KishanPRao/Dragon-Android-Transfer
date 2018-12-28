//
//  CommCommand.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 20/10/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class CommCommand {
    private static let Prefix = "DAT_COMMAND:"
    private static let ResponseSuffix = "_RESPONSE"
    private static let RequestSuffix = "_REQUEST"
    static let Ping = "\(Prefix)PING"
    static let Pong = "\(Prefix)PONG"
    static let Quit = "\(Prefix)QUIT"
    
//    static let Begin = "\(Prefix)BEGIN"
//    static let End = "\(Prefix)END"
    static let Cancel = "\(Prefix)CANCEL"
    
    static let List = "LIST"
    static let Pull = "PULL"
    static let Push = "PUSH"
    static let NOP = "NOP"
    
    static let ListRequest = "\(Prefix)\(List)\(RequestSuffix)"
    static let ListResponse = "\(Prefix)\(List)\(ResponseSuffix)"
    
    static let PullRequest = "\(Prefix)\(Pull)\(RequestSuffix)"
    static let PullResponse = "\(Prefix)\(Pull)\(ResponseSuffix)"
    static let PushRequest = "\(Prefix)\(Push)\(RequestSuffix)"
    static let PushResponse = "\(Prefix)\(Push)\(ResponseSuffix)"
}
