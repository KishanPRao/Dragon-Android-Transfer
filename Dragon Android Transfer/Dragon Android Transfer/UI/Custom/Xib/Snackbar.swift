//
// Created by Kishan P Rao on 01/01/18.
// Copyright (c) 2018 Kishan P Rao. All rights reserved.
//

import Foundation

//TODO: Xib
class Snackbar: NSView {
	public var AnimationDuration: Double = 0.4
	public var timeSnackBarShown: Double = 1.0
	
	public var spaceBetweenElements: CGFloat = 24.0
	public var elementsTopBottomMargins: CGFloat = 14.0
	
	fileprivate var timer: Timer? = nil
	
    @IBOutlet weak var message: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateMessage(_ message: String) {
        self.message.stringValue = message
    }
	
	private func commonInit() {
		Bundle.main.loadNibNamed("Snackbar", owner: self, topLevelObjects: nil)
		message.stringValue = ""
		message.textColor = R.color.black
		self.setBackground(R.color.white)
//		message.textColor = R.color.white
//		self.setBackground(R.color.menuNavColor)
		
		/*
		let leftConstraint = NSLayoutConstraint(item: message,
				attribute: NSLayoutAttribute.leading,
				relatedBy: NSLayoutRelation.equal,
				toItem: self, attribute: NSLayoutAttribute.leading,
				multiplier: 1, constant: self.spaceBetweenElements)
		
//		let rightConstraint = NSLayoutConstraint(item: message,
//				attribute: NSLayoutAttribute.trailing,
//				relatedBy: NSLayoutRelation.equal, toItem: actionLabel ?? self,
//				attribute: actionLabel != nil ? .leading : .trailing,
//				multiplier: 1, constant: -self.spaceBetweenElements)
		
		let topConstraint = NSLayoutConstraint(item: message,
				attribute: NSLayoutAttribute.top,
				relatedBy: NSLayoutRelation.equal, toItem: self,
				attribute: NSLayoutAttribute.top,
				multiplier: 1, constant: self.elementsTopBottomMargins)
		
//		let bottomConstraint = NSLayoutConstraint(item: message,
//				attribute: NSLayoutAttribute.bottom,
//				relatedBy: NSLayoutRelation.equal, toItem: self,
//				attribute: NSLayoutAttribute.bottom,
//				multiplier: 1, constant: -self.elementsTopBottomMargins)
		
//		NSLayoutConstraint.activate([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
		NSLayoutConstraint.activate([leftConstraint, topConstraint])
		*/
		
		self.addSubview(message)
		self.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.size.height)
		//self.frame.origin = CGPoint(x: 0, y: -self.frame.size.height)
		Swift.print("Created Snack")
//		setBackground(bgColor)
	}
    
	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		commonInit()
	}
	
	func showSnackbar() {
		bringToFront()
		Swift.print("Aniamting Snackbar")
        if (isOpen) {
			return
		}
		animate(open: true)
	}
	
	func hideSnackbar() {
        if (!isOpen) {
            return
        }
		animate(open: false)
	}
    
    private var isAnimating = false
    private var isOpen = false
	
	private func animate(open: Bool) {
        if (isAnimating) {
            return
        }
        isAnimating = true
		let animView = self
		var dy = self.frame.size.height
		if (open) {
//			animView.frame = animView.frame.offsetBy(dx: 0, dy: -dy)
		} else {
			dy = -dy
		}
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = AnimationDuration
			context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			animView.animator().frame = animView.frame.offsetBy(dx: 0, dy: dy)
            //animView.animator().frame.origin = CGPoint(x: 0, y: dy)
        }, completionHandler: {
            self.isAnimating = false
            self.isOpen = open
			if (!open) {
//				self.removeFromSuperview()
				return
			}
//			self.timer = Timer.init(timeInterval: TimeInterval(timeSnackBarShown), invocation: #selector(hideSnackbar), repeats: false)
//			self.timer = Timer.init(timeInterval: TimeInterval(timeSnackBarShown), target: self, selector: #selector(hideSnackbar), userInfo: nil, repeats: false)
			self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeSnackBarShown), target: self, selector: #selector(self.hideSnackbar), userInfo: nil, repeats: false)
		})
	}
	
	deinit {
		LogV("Deinit")
		for view in self.subviews {
			view.removeFromSuperview()
		}
		self.removeFromSuperview()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
}
