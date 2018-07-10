//
//  ImageResource.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class ImageResource {
    public var path_selector_div: String { get {return R.isDark() ? "path_selector_div" : "path_selector_div_l"}}
    public var path_selector_back: String { get { return R.isDark() ? "backward": "backward_l" } }
    public var file: String {get{return R.isDark() ? "file" : "file_l"}}
    
    public let cancel_transfer = "cancel"
    public let android = "android"
    public let mac = "mac"
    public let more = "transfer_more"
    
    public let clipboard = "clipboard"
    public let paste = "paste"
    public let remove = "remove"
    public let options = "options"
    public let info = "info"
    
    public let folder = "folder"
    
    public let menu_back = "menu_back"
    public let refresh = "refresh"
    
    public func imageName(_ name: String) -> NSImage.Name {
        return NSImage.Name(rawValue: name)
    }
}
