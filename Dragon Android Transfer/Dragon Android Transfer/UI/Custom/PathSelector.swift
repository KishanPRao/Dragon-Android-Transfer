//
//  PathSelector.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

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
    
    let indentSize = 1.0 as CGFloat
    
    private func updateText(_ button: NSButton, _ text: String) {
//        let style = NSMutableParagraphStyle()
//        style.alignment = .center
////        style.headIndent = indentSize
////        style.firstLineHeadIndent = indentSize
////        style.tailIndent = -indentSize
//        style.lineBreakMode = .byTruncatingTail
//        button.attributedTitle = NSMutableAttributedString(string: text, attributes: [
//            NSForegroundColorAttributeName: R.color.white,
//            NSParagraphStyleAttributeName: style
//        ])
        
        button.attributedTitle = TextUtils.getTruncatedAttributeString(text)
    }
    
    private func updateButton(_ button: NSButton, _ image: NSImage) {
        button.setImage(image: image)
        button.imageScaling = .scaleAxesIndependently
    }
    
    private func initButtons() {
        updateButton(firstText, disabledImage!)
        updateButton(secondText, disabledImage!)
        updateButton(thirdText, disabledImage!)
    }
    
    var paths = [Path]()
    var currentPath = ""
    
    func updateCurrentPath(_ currentPath: String) {
        let directories = currentPath.characters.split{$0 == "/"}.map(String.init)
        let size = directories.count
        let textArray = [firstText, secondText, thirdText]
        let arrowsArray = [firstImage, secondImage]
        
        for button in textArray {
            button?.isHidden = true
        }
        for arrow in arrowsArray {
            //            TODO: Make the 'current path' button black!
            arrow?.isHidden = true
        }
        self.currentPath = currentPath
        
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
                let image = isCurrentPath(pathElement) ? disabledImage! : clickableImage!
                updateButton(button, image)
                button.imageScaling = .scaleAxesIndependently
                updateText(button, pathElement.getPathName())
                button.isHidden = false
                
                if (updateTextPosition > 0) {
                	let arrow = arrowsArray[updateTextPosition - 1]!
                	arrow.isHidden = false
                }
            }
        }
        LogD("Paths", paths)
        LogD("Current:", currentPath)
    }
    
    internal let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private func updateToPath(_ path: String) {
        NSObject.sendNotification(AndroidViewController.NotificationStartLoading)
        Observable.just(TransferHandler.sharedInstance)
        	.observeOn(bgScheduler)
            .subscribe(onNext: {
                transferHandler in
                transferHandler.updateList(path)
            })
    }
    
    private func isCurrentPath(_ path: Path) -> Bool {
        return (path.fullPath == currentPath)
    }
    
    func first() {
        let path = paths[0].fullPath
        
        if (path != currentPath) {
        	updateToPath(path)
            LogV("Open", path)
        }
    }
    
    func second() {
        let path = paths[1].fullPath
        
        if (path != currentPath) {
            LogV("Open", path)
            updateToPath(path)
        }
    }
    
/*    func third() {
        LogV("Open", paths[2].fullPath)
    }
 */
    var clickableImage: NSImage? = nil
    var disabledImage: NSImage? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("PathSelector", owner: self, topLevelObjects: nil)
        LogV("Path Selector, init coder", firstText)
        clickableImage = NSImage.swatchWithColor(color: R.color.menuNavColor, size: rootView.frame.size).roundCorners()
        disabledImage = NSImage.swatchWithColor(color: R.color.black, size: rootView.frame.size).roundCorners()
        
        initButtons()
        
        firstText.target = self
        firstText.action = #selector(PathSelector.first)
        secondText.target = self
        secondText.action = #selector(PathSelector.second)
//        thirdText.target = self
//        thirdText.action = #selector(PathSelector.third)
        
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
