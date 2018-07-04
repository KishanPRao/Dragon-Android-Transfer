//
//  NSImage_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

import Cocoa
import Quartz

extension NSImage {
	class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
		let image = NSImage(size: size)
		image.lockFocus()
		color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
		image.unlockFocus()
		return image
	}
    
    class func gradientWithColors(colors: [CGColor], size: NSSize) -> NSImage {
        let contentsScale: CGFloat = 1
        let width = Int(size.width * contentsScale)
        let height = Int(size.height * contentsScale)
        let bytesPerRow = width * 4
        let alignedBytesPerRow = ((bytesPerRow + (64 - 1)) / 64) * 64
        
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: alignedBytesPerRow,
            space: NSScreen.main?.colorSpace?.cgColorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )!
        
        context.scaleBy(x: contentsScale, y: contentsScale)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var locations = [CGFloat]()
        
        for i in 0...colors.endIndex {
            locations.append(CGFloat(i) / CGFloat(colors.count))
        }
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        context.drawLinearGradient(gradient!,
                                   start: CGPoint(x: center.x, y: 0.0),
                                   end: CGPoint(x: center.x, y: size.height),
                                   options: CGGradientDrawingOptions(rawValue: 0))
        
        let image = NSImage(cgImage:  context.makeImage()!, size: size)
        return image
//        image.unlockFocus()
//        return image
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
	
	func imageTintedWithColor(tint: NSColor) -> NSImage {
		let image = NSImage(cgImage: self.cgImage!, size: self.size)
		image.lockFocus()
		tint.set()
		let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
		imageRect.fill(using: .destinationAtop)
		image.unlockFocus()
		return image
	}
	
	func imageRotated(by degrees: CGFloat) -> NSImage {
		let imageRotator = IKImageView()
		var imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		let cgImage = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
//		imageRotator.backgroundColor = NSColor.clear
		imageRotator.setImage(cgImage, imageProperties: [:])
		imageRotator.rotationAngle = CGFloat(-(degrees / 180) * CGFloat(M_PI))
		let rotatedCGImage = imageRotator.image().takeUnretainedValue()
		return NSImage(cgImage: rotatedCGImage, size: NSSize.zero)
	}
	
	
	public func imageRotatedByDegrees(degrees: CGFloat) -> NSImage {
		var imageBounds = NSZeroRect;
		imageBounds.size = self.size
		let pathBounds = NSBezierPath(rect: imageBounds)
		var transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        pathBounds.transform(using: transform as AffineTransform)
		let rotatedBounds: NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, pathBounds.bounds.size.width, pathBounds.bounds.size.height)
//		let rotatedBounds: NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, self.size.width, self.size.height)
		let rotatedImage = NSImage(size: rotatedBounds.size)
		
		//Center the image within the rotated bounds
		imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2)
		imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2)
		
		// Start a new transform
		transform = NSAffineTransform()
		// Move coordinate system to the center (since we want to rotate around the center)
        transform.translateX(by: +(NSWidth(rotatedBounds) / 2), yBy: +(NSHeight(rotatedBounds) / 2))
        transform.rotate(byDegrees: degrees)
		// Move the coordinate system bak to normal 
        transform.translateX(by: -(NSWidth(rotatedBounds) / 2), yBy: -(NSHeight(rotatedBounds) / 2))
		// Draw the original image, rotated, into the new image
		rotatedImage.lockFocus()
		transform.concat()
        self.draw(in: imageBounds, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
		rotatedImage.unlockFocus()
		
		return rotatedImage
	}
	
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
