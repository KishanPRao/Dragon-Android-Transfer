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
	
    private func updateText(_ button: NSButton, _ text: String, useUnderline : Bool = false) {
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
		
		button.attributedTitle = TextUtils.getTruncatedAttributeString(text,
                                                                       alignment: .center,
                                                                       useUnderline: useUnderline)
        button.updateMainFont()
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
    
    func addElement(_ pathElement: Path, _ updateTextPosition: Int) {
//        LogV("Update Text:", updateTextPosition)
        
        let button = textArray[updateTextPosition]
        
//        LogI("Path Element: \(pathElement)")
        paths.append(pathElement)
        let isLast = isCurrentPath(pathElement)
        let image = isLast ? disabledImage! : clickableImage!
        updateButton(button, image)
        button.imageScaling = .scaleAxesIndependently
        updateText(button, pathElement.name, useUnderline: isLast)
        button.isHidden = false
        
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
		let path = paths[0].absolutePath
		
		if (path != currentPath) {
			updateToPath(path)
//            LogV("Open", path)
		}
	}
	
	@objc func second() {
		let path = paths[1].absolutePath
		
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
		clickableImage = NSImage.swatchWithColor(color: R.color.pathSelectorSelectableItem, size: rootView.frame.size).roundCorners()
		disabledImage = NSImage.swatchWithColor(color: R.color.pathSelectorBg, size: rootView.frame.size).roundCorners()
		
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
