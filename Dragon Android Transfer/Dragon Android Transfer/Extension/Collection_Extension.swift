//
// Created by Kishan P Rao on 07/01/18.
// Copyright (c) 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
	subscript (safe index: Index) -> Iterator.Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
