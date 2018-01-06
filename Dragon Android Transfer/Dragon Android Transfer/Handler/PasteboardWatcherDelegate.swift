//
//  PasteboardWatcherDelegate.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 07/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

protocol PasteboardWatcherDelegate {
    func newlyCopiedUrlObtained(copiedUrl: NSURL)
}
