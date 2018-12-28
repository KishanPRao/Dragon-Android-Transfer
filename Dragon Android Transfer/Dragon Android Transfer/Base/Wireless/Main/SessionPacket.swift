//
//  SessionPacket.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import SwiftyJSON

class SessionPacket: Codable {
    var type: String
    var name: String
    var args: JSON
    
    init(_ name: String, _ args: JSON = JSON(), _ type: String = Constants.RequestMessage) {
        self.name = name
        self.args = args
        self.type = type
    }
    
    init(withJsonString jsonString: String) {
        let data: Data = jsonString.data(using: .utf8)!
        //        let msgDictionary = try? JSONSerialization.jsonObject(with: data,
        //                                                              options: .allowFragments) as? [String: Any]
        //        if let d = msgDictionary, let dictionary = d {
        //            self.name = dictionary["name"] as? String ?? ""
        //            print("init Args: \(dictionary["args"])")
        //            self.args = dictionary["args"] as? JSON ?? JSON("{\"tmp\":\"1\"}")
        //            self.type = dictionary["type"] as? String ?? Constants.RequestMessage
        //            print("inited args: \(self.args["length"])")
        //        } else {
        //            self.args = JSON()
        //            self.name = ""
        //            self.type = Constants.RequestMessage
        //        }
        do {
            let msg = try JSONDecoder().decode(SessionPacket.self,
                                               from: data)
            self.args = msg.args
            self.name = msg.name
            self.type = msg.type
        }
        catch {
            print(error)
            self.args = JSON()
            self.name = ""
            self.type = Constants.RequestMessage
        }
    }
    
    func isValid() -> Bool {
        return name != ""
    }
    
    func isRequest() -> Bool {
        return type == Constants.RequestMessage
    }
}

extension SessionPacket: CustomStringConvertible {
    public var description: String {
        var str = "{"
        str += "name: \(name),"
        str += "args: \(args),"
        str += "type: \(type)"
        str += "}"
        return str
    }
}
