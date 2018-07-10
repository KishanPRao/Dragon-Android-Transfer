//
//  NSButton_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSButton {
    
    public func setImage(image: NSImage) {
        self.image = image
        self.imageScaling = .scaleProportionallyUpOrDown
        self.imagePosition = .imageOnly
        self.isBordered = false
    }
    
    public func setImage(name: String) {
//        .imageTintedBy(color: R.color.white)
        self.setImage(image: NSImage(named: NSImage.Name(rawValue: name))!)
    }
    
    func setColorBackground(_ color: NSColor, _ rounded: Bool = false) {
        var image = NSImage.swatchWithColor(color: color, size: self.frame.size)
        LogV("Color Bg: \(self.frame.size)")
        if (rounded) {
            image = image.roundCorners()
        }
        //		self.setImage(image: image)
        self.image = image
        self.isBordered = false
    }
    
    func fillGradientLayer() {
        self.wantsLayer = true
        let gradientLayer = CAGradientLayer()
        //        gradientLayer.colors = [#colorLiteral(red: 0, green: 0.9909763549, blue: 0.7570167824, alpha: 1),#colorLiteral(red: 0, green: 0.4772562545, blue: 1, alpha: 1)].map({return $0.cgColor})
        
        let colors = [R.color.black, R.color.white]
        
        let color1 = colors[0].cgColor
        let color2 = colors[1].cgColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        let margin: CGFloat = 0
        //        gradientLayer.frame = self.frame.insetBy(dx: margin, dy: margin)
        gradientLayer.frame = self.bounds
        gradientLayer.zPosition = 2
        gradientLayer.name = "gradientLayer"
        gradientLayer.contentsScale = (NSScreen.main?.backingScaleFactor)!
        //        self.layer?.addSublayer(gradientLayer)
        self.layer?.insertSublayer(gradientLayer, at: 0)
    }
    
    func setText(text: String, textColor: NSColor,
                 alignment: NSTextAlignment,
                 bgColor: NSColor,
                 isSelected: Bool,
                 rounded: Bool = false) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        var image: NSImage
//        if (!isSelected) {
            image = NSImage.swatchWithColor(color: bgColor, size: self.frame.size)
        /*} else {
            let colors = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)].map({return $0.cgColor})
            image = NSImage.gradientWithColors(colors: colors, size: self.frame.size)
        }*/
        if (rounded) {
            image = image.roundCorners()
        }
        self.setImage(image: image)
        
        /*
         let gradientLayer = CAGradientLayer()
         gradientLayer.frame = self.bounds
         
         let colors = [R.color.black, R.color.white]
         
         let color1 = colors[0].cgColor
         let color2 = colors[1].cgColor
         gradientLayer.colors = [color1, color2]
         gradientLayer.locations = [0.0, 1.0]
         self.wantsLayer = true
         //        self.layer?.insertSublayer(gradientLayer, at: 0)
         self.layer?.addSublayer(gradientLayer)*/
        
        //        fillGradientLayer()
        
        self.imageScaling = .scaleAxesIndependently
        //        Color change not working:
        //        self.attributedTitle = TextUtils.attributedBoldString(from: text, color: R.color.white, nonBoldRange: nil, fontSize: 15.0, .center)
        //        self.attributedStringValue = TextUtils.attributedBoldString(from: text, color: R.color.white, nonBoldRange: nil, fontSize: 15.0, .center)
    }
    
    func updateMainFont(_ fontSize: CGFloat = 40.0) {
        //        let fontSize = self.font?.pointSize ?? 10.0
        //        let mainFont = NSFont(name: R.font.mainFont, size: fontSize)
        let mainFont = NSFont(name: R.font.mainFont, size: fontSize)
        self.font = mainFont
    }
}
