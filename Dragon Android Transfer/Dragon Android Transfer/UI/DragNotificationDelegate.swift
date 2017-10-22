//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol DragNotificationDelegate {
	
	func dragItem(items: [DraggableItem], fromAppToFinderLocation location: String)
	
	func dragItem(items: [String], fromFinderIntoAppItem appItem: DraggableItem)
}
