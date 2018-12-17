//
//  PathSelector.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

class PathSelector: VerboseView {
	/*override var Verbose: Bool {
		return false
	}*/
	@IBOutlet var rootView: NSView!
	
	@IBOutlet weak var firstText: NSButton!
	@IBOutlet weak var secondText: NSButton!
	@IBOutlet weak var thirdText: NSButton!
	
	@IBOutlet weak var firstImage: NSImageView!
	@IBOutlet weak var secondImage: NSImageView!
    
    var disposeBag = DisposeBag()
    
    var textArray = [NSButton]()
    var arrowsArray = [NSImageView]()
    
    var storages = [StorageItem]() {
        didSet {
            self.updateCurrentPath(self.currentPath)
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
	
    private func updateText(_ button: NSButton, _ text: String,
                            useUnderline : Bool = false,
                            textColor : NSColor = R.color.textColor,
                            bold: Bool = false) {
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
        
        if (bold) {
            button.attributedTitle = TextUtils.attributedBoldString(from: text, color: textColor,
                                                   nonBoldRange: nil, fontSize: NSFont.systemFontSize, .center)
        } else {
            button.attributedTitle = TextUtils.getTruncatedAttributeString(text,
                                                                           alignment: .center,
                                                                           useUnderline: useUnderline,
                                                                           color: textColor)
        }
        button.updateButtonMainFont()
	}
	
	private func updateButton(_ button: NSButton, _ image: NSImage) {
		button.setImage(image: image)
		button.imageScaling = .scaleAxesIndependently
	}
	
	private func initButtons() {
		updateButton(firstText, disabledImage!)
		updateButton(secondText, disabledImage!)
		updateButton(thirdText, disabledImage!)
        textArray = [firstText, secondText, thirdText]
        arrowsArray = [firstImage, secondImage]
	}
	
	var paths = [Path]()
	var currentPath = ""
    
    func getStoragePath(_ path: String) -> Path? {
        for storage in storages {
//            LogV("Storage Path check: \(storage)")
            if (path.starts(with: storage.path.absolutePath)) {
                return storage.path
            }
        }
        return nil
    }
    
    func getActiveItemName() -> String {
        if (paths.count > 0) {
            return paths[paths.count - 1].name
        }
        return ""
    }
    
    func addElement(_ pathElement: Path, _ updateTextPosition: Int) {
//        LogV("Update Text:", updateTextPosition)
        
        let button = textArray[updateTextPosition]
        
//        LogI("Path Element: \(pathElement)")
        paths.append(pathElement)
        let isLast = isCurrentPath(pathElement)
        let image = isLast ? disabledImage! : clickableImage!
        updateButton(button, image)
        button.imageScaling = .scaleAxesIndependently
        let textColor = isLast ? R.color.pathSelectorLastTextColor : R.color.pathSelectorTextColor
        updateText(button, pathElement.name, useUnderline: isLast, textColor: textColor, bold: isLast)
        button.isHidden = false
//        button.isEnabled = !isLast
        
        if (updateTextPosition > 0) {
            let arrow = arrowsArray[updateTextPosition - 1]
            arrow.isHidden = false
        }
    }
	
	func updateCurrentPath(_ currentPath: String) {
//        paths.removeAll()
        var paths = [Path]()
        self.currentPath = currentPath
        let storagePath = getStoragePath(currentPath)
        
        for button in textArray {
            button.isHidden = true
        }
        for arrow in arrowsArray {
            //            TODO: Make the 'current path' button black!
            arrow.isHidden = true
        }
        if let storagePath = storagePath {
//            LogV("Storage Path: \(storagePath)")
            let newPath = currentPath.replacingOccurrences(of: storagePath.absolutePath, with: "")
            let directories = newPath.split {
                $0 == "/"
            }.map(String.init)
//            LogI("New Path: \(newPath), dirs: \(directories)")
            var size = directories.count
            
            paths.append(storagePath)
            
            var path = ""
            
            for index in 0..<size {
                let name = directories[index]
                path = path + "/" + name
                paths.append(Path(name, storagePath.absolutePath + path))
            }
            
            size = paths.count
            let maxIndex = size > 3 ? 3 : size
            for index in 0..<size {
                if (size - index <= 3) {
                    let updateTextPosition = maxIndex - (size - index)
                    addElement(paths[index], updateTextPosition)
                }
            }
            
//            LogD("Paths", paths)
//            LogD("Current:", currentPath)
        }
        self.paths = paths
        NSObject.sendNotification(AndroidViewController.NotificationWindowTitle)
	}
    
    func canGoBackward() -> Bool {
        return paths.count > 1
    }
	
	internal let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
	
	private func updateToPath(_ path: String) {
		NSObject.sendNotification(AndroidViewController.NotificationStartLoading)
		Observable.just(TransferHandler.sharedInstance)
				.observeOn(bgScheduler)
				.subscribe(onNext: {
					transferHandler in
					transferHandler.updateList(path)
				}).disposed(by: disposeBag)
	}
	
	private func isCurrentPath(_ path: Path) -> Bool {
		return (path.absolutePath == currentPath)
	}
	
	@objc func first() {
        let index = paths.count > 3 ? paths.count - 3 : 0
		let path = paths[index].absolutePath
		
		if (path != currentPath) {
			updateToPath(path)
//            LogV("Open", path)
		}
	}
	
	@objc func second() {
        let index = paths.count > 3 ? paths.count - 2 : 1
        let path = paths[index].absolutePath
		
		if (path != currentPath) {
//            LogV("Open", path)
			updateToPath(path)
		}
	}

/*    func third() {
        LogV("Open", paths[2].absolutePath)
    }
 */
	var clickableImage: NSImage? = nil
	var disabledImage: NSImage? = nil
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		Bundle.main.loadNibNamed(NSNib.Name(rawValue: "PathSelector"), owner: self, topLevelObjects: nil)
		LogV("Path Selector, init coder", firstText)
//        let clickableColor = R.color.pathSelectorSelectableItem
//        let clickableColor = R.color.listSelectedBackgroundColor
        let clickableColor = R.color.toolbarColor
		clickableImage = NSImage.swatchWithColor(color: clickableColor, size: rootView.frame.size).roundCorners()
//        let disabledColor = R.color.pathSelectorBg
        let disabledColor = R.color.toolbarColor
		disabledImage = NSImage.swatchWithColor(color: disabledColor, size: rootView.frame.size).roundCorners()
		
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
        firstText.isHidden = true
        firstImage.isHidden = true
        secondText.isHidden = true
        secondImage.isHidden = true
        thirdText.isHidden = true
		
		
		//     thirdText.attributedTitle = NSMutableAttributedString(string: "Internal Storage", attributes: [NSForegroundColorAttributeName: NSColor.white])
		/*      thirdText.lineBreakMode = .byTruncatingTail
			  thirdText.attributedTitle.boundingRect(with: thirdText.frame.size, options: (
				  //NSStringDrawingOptions.usesLineFragmentOrigin
				  NSStringDrawingOptions.usesFontLeading
			  ))
	   */
		
		let image = NSImage(named: NSImage.Name(rawValue: R.drawable.path_selector_div))
		firstImage.setImage(image: image!)
		secondImage.setImage(image: image!)
		
		self.addSubview(rootView)
	}
}
