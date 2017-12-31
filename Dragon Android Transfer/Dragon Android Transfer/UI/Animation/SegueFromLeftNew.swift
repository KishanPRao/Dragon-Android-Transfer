//
//  SegueFromLeftNew.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class SegueFromLeftNew: NSStoryboardSegue {
    override func perform() {
        /*let src = self.sourceController as! NSViewController
        let dst = self.destinationController as! NSViewController
        
        src.view.superview?.addSubview(dst.view, positioned: NSWindowOrderingMode.above, relativeTo: src.view)
        dst.view.wantsLayer = true
        dst.view.layer?.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        NSView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        }
        )*/
    }
}
