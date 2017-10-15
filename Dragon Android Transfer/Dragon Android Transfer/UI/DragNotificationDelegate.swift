//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol DragNotificationDelegate {
	
	func dragItem(item: DraggableItem, fromAppToFinderLocation location: String)
	
	func dragItem(item: String, fromFinderIntoAppItem appItem: DraggableItem)
}