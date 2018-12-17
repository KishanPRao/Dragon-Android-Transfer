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
        return 3
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        print("collectionView 2.1")
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "WlessItem"), for: indexPath)
        return item.view
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        print("collectionView 2")
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "WlessItem"), for: indexPath)
        guard let collectionViewItem = item as? WlessItem else {return item}
        
        // 5
//        let imageFile = imageDirectoryLoader.imageFileForIndexPath(indexPath)
//        collectionViewItem.imageFile = imageFile
//        return item
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        print("collectionView 3")
        return 5
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: 1000, height: 40)
    }
}
