//
//  PathSelector.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class PathSelector: NSView {
    /*@IBOutlet weak var firstLabel: NSTextField!
    @IBOutlet weak var secondLabel: NSTextField!
    @IBOutlet weak var thirdLabel: NSTextField!
 */
    @IBOutlet var rootView: NSView!
    
    @IBOutlet weak var firstText: NSButton!
    @IBOutlet weak var secondText: NSButton!
    @IBOutlet weak var thirdText: NSButton!
    
    @IBOutlet weak var firstImage: NSImageView!
    @IBOutlet weak var secondImage: NSImageView!
    
    class Path: NSObject {
        func getPathName() -> String {
            var pathName = ""
            if (fullPath == "/sdcard") {
                pathName = "Internal Storage"
            } else {
                pathName = name
            }
            return pathName
        }
        
        var name: String
        var fullPath: String
        
        init(_ _name: String, _ path: String) {
            name = _name
            fullPath = path
        }
        
        override public var description: String {
            return "Path: \(name), \(fullPath)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /*override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        LogV("Path Selector, init frame, ", firstLabel)
        //let bgColor = R.color.menuNavColor
        Bundle.main.loadNibNamed("PathSelector", owner: self, topLevelObjects: nil)
    }*/
    
    private func updateText(_ button: NSButton, _ text: String) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        button.attributedTitle = NSMutableAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: NSColor.white,
            NSParagraphStyleAttributeName: style
        ])
    }
    
    private func initButton(_ button: NSButton, _ image: NSImage) {
        button.setImage(image: image)
        button.imageScaling = .scaleAxesIndependently
    }
    
    private func initButtons() {
        let image = NSImage.swatchWithColor(color: R.color.menuNavColor, size: rootView.frame.size)
        initButton(firstText, image)
        initButton(secondText, image)
        initButton(thirdText, image)
    }
    
    var paths = [Path]()
    
    func updateCurrentPath(_ currentPath: String) {
        let directories = currentPath.characters.split{$0 == "/"}.map(String.init)
        let size = directories.count
        let textArray = [firstText, secondText, thirdText]
        let arrowsArray = [firstImage, secondImage]
        
        for button in textArray {
            button?.isHidden = true
        }
        for arrow in arrowsArray {
            arrow?.isHidden = true
        }
        
        paths.removeAll()
        var path = ""
        for index in 0..<size {
            path = path + "/" + directories[index]
            //TODO: Merge multiple directories, for external storage.
            if (size - index <= 3) {
                let directory = directories[index]
                LogI("Display Directory:", directory)
                let maxIndex = size > 3 ? 3 : size
                let updateTextPosition = maxIndex - (size - index)
                LogV("Update Text:", updateTextPosition)
                
                let button = textArray[updateTextPosition]!
                
                let pathElement = Path(directory, path)
                paths.append(pathElement)
                updateText(button, pathElement.getPathName())
 				
                button.isHidden = false
                
                if (updateTextPosition > 0) {
                	let arrow = arrowsArray[updateTextPosition - 1]!
                	arrow.isHidden = false
                }
            }
        }
        LogD("Paths", paths)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("PathSelector", owner: self, topLevelObjects: nil)
        LogV("Path Selector, init coder", firstText)
        initButtons()
        
        updateText(firstText, "Unknown")
        updateText(secondText, "Unknown")
        updateText(thirdText, "Unknown")
 
        
   //     thirdText.attributedTitle = NSMutableAttributedString(string: "Internal Storage", attributes: [NSForegroundColorAttributeName: NSColor.white])
  /*      thirdText.lineBreakMode = .byTruncatingTail
        thirdText.attributedTitle.boundingRect(with: thirdText.frame.size, options: (
            //NSStringDrawingOptions.usesLineFragmentOrigin
            NSStringDrawingOptions.usesFontLeading
        ))
 */
        
        let image = NSImage(named: R.drawable.path_selector_div)
        firstImage.setImage(image: image!)
        secondImage.setImage(image: image!)
        
        self.addSubview(rootView)
    }
}
