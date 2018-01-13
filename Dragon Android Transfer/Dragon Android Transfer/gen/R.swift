//
// Created by Kishan P Rao on 30/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class R {
	//internal static let _lightTheme = LightTheme()
	internal static let _darkTheme = DarkTheme()
	
	public internal(set) static var color: Theme = _darkTheme
	public static let drawable = ImageResource()
	public static let integer = IntegerResource()
    public static let string = StringResource()
    public static let font = FontResource()
}
