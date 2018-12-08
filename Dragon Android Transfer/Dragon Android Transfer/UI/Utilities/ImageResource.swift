//
//  ImageResource.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class ImageResource {
//    public var path_selector_div: String { get {return R.isDark() ? "path_selector_div" : "path_selector_div_l"}}
    public var path_selector_div: String { get {return "path_selector_div"}}
//    public var path_selector_back: String { get { return R.isDark() ? "backward": "backward_l" } }
    public var path_selector_back: String { get { return "toolbar_back" } }
    public var file: String {get{return R.isDark() ? "file" : "file_l"}}
    
    public var cancel_transfer: String {get{return R.isDark() ? "cancel" : "cancel_l"}}
    public var android: String {get{return R.isDark() ? "android" : "android_l"}}
    public var mac: String {get{return R.isDark() ? "mac" : "mac_l"}}
    public var more: String {get{return R.isDark() ? "transfer_more" : "transfer_more_l"}}
    
    public let clipboard = "clipboard"
    public let paste = "paste"
    public let remove = "remove"
    public let options = "options"
    public let info = "info"
    
    public let folder = "folder"
    
    public let menu_back = "menu_back"
    public let refresh = "refresh"
    
    public let app_icon_copy = "app_icon_copy"
    public let app_icon_paste = "app_icon_paste"
    
    public func imageName(_ name: String) -> NSImage.Name {
        return NSImage.Name(rawValue: name)
    }
}
