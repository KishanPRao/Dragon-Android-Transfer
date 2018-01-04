//
//  NSImage_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

import Cocoa

extension NSImage {
    class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
        image.unlockFocus()
        return image
    }
    
    /*
    func roundCorners() -> NSImage {
        let image = self
        let width = self.size.width
        let height = self.size.height
        let xRad = 5.0 as CGFloat
        let yRad = 5.0 as CGFloat
        let existing = image
        let esize = existing.size
        let newSize = NSMakeSize(esize.width, esize.height)
        let composedImage = NSImage(size: newSize)
        
        composedImage.lockFocus()
        let ctx = NSGraphicsContext.current()
        ctx?.imageInterpolation = NSImageInterpolation.high
        
        let imageFrame = NSRect(x: 0, y: 0, width: width, height: height)
        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
        clipPath.windingRule = NSWindingRule.evenOddWindingRule
        clipPath.addClip()
        
        let rect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        image.draw(at: NSZeroPoint, from: rect, operation: NSCompositingOperation.sourceOver, fraction: 1)
        composedImage.unlockFocus()
        
        return composedImage
    }*/

    func roundCorners(withRadius radius: CGFloat = 5.0) -> NSImage {
        let rect = NSRect(origin: NSPoint.zero, size: size)
        if
            let cgImage = self.cgImage,
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 4 * Int(size.width),
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
            context.beginPath()
            context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
            context.closePath()
            context.clip()
            context.draw(cgImage, in: rect)
            
            if let composedImage = context.makeImage() {
                return NSImage(cgImage: composedImage, size: size)
            }
        }
        
        return self
    }
    
    var cgImage: CGImage? {
        var rect = CGRect.init(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }
}
