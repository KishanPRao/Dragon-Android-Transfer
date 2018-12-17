//
//  WlessControllerData.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 17/12/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension WirelessController : NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionView 1")
        return devices.count
    }
    
//    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
//        print("collectionView 2.1")
//        return NSView()
//    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        print("collectionView 2")
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "WlessItem"), for: indexPath)
        guard let collectionViewItem = item as? WlessItem else {return item}
        
        let androidImage = NSImage(named: NSImage.Name(rawValue: R.drawable.android))
        collectionViewItem.itemTitle = devices[indexPath.item]
        collectionViewItem.image = androidImage
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        print("collectionView 3")
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSZeroSize
    }
}
