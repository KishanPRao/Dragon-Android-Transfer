//
//  R_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension R {
    
    public static func setDarkTheme() {
        //print("Set Dark:", R.color.dark, R.color.dark)
        R.color = R._darkTheme
        //print("Set Dark:", R.color.dark, R.color.dark)
    }
    
    public static func isDark() -> Bool {
        return R.color.isDark
    }
    
    public static func setLightTheme() {
        R.color = R._lightTheme
    }
}
