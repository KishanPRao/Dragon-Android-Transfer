//
//  BlurOverlayView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class BlurOverlayView: NSView {
    
    override init(frame frameRect: Foundation.NSRect) {
        super.init(frame: frameRect)
        blur(view: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        blur(view: self)
    }
    
    var onClick: () -> () = {}
    
    func setOnClickListener(onClick: (@escaping () -> ())) {
        self.onClick = onClick
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        onClick()
    }
    
    private func blur(view: NSView!) {
        LogV("Blurring!")
        /*var blurView = NSView(frame: view.bounds)
        blurView.wantsLayer = true
        blurView.layer?.backgroundColor = NSColor.clear.cgColor
        blurView.layer?.masksToBounds = true
        blurView.layerUsesCoreImageFilters = true
        blurView.layer?.needsDisplayOnBoundsChange = true
        
        let satFilter = CIFilter(name: "CIColorControls")
        satFilter?.setDefaults()
//        satFilter?.setValue(NSNumber(value: 2.0), forKey: "inputSaturation")
        satFilter?.setValue(NSNumber(value: 20.0), forKey: "inputSaturation")
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
//        blurFilter?.setValue(NSNumber(value: 2.0), forKey: "inputRadius")
        blurFilter?.setValue(NSNumber(value: 10.0), forKey: "inputRadius")
        
        blurView.layer?.backgroundFilters = [satFilter, blurFilter]
        
        view.addSubview(blurView)
        self.superview?.wantsLayer = true
        
        blurView.layer?.needsDisplay()*/
        
        view.wantsLayer = true
        view.layerUsesCoreImageFilters = true
        //view.layer?.backgroundColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5).cgColor
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.name = "test"
        blurFilter?.setDefaults()
        blurFilter?.setValue(10, forKey: kCIInputRadiusKey)
//        view.layer?.backgroundFilters?.append(blurFilter!)
        
        isHidden = true
//        LogV("\(blurFilter?.outputKeys), \(blurFilter?.inputKeys), \(blurFilter?.attributeKeys)")
        
        /*
        let blurAnimation = CABasicAnimation()
        blurAnimation.keyPath = ("filters.test." + kCIInputRadiusKey)
        blurAnimation.fromValue = 3.0
        blurAnimation.toValue = 50.0
        blurAnimation.duration = 20
        
        view.layer?.add(blurAnimation, forKey: "blurAnimation")
 */
 
        /*
        self.alphaValue = 0.0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 15
            self.animator().alphaValue = 1.0
        }, completionHandler: {
            self.LogV("Done!")
        })
*/
        /*let backgroundView = self
        let backgroundLayer = CALayer(layer: layer);
        backgroundView.layer = backgroundLayer
        backgroundView.wantsLayer = true
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        
        backgroundView.layer?.backgroundFilters = [blurFilter]
 */
    }
}
