//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

//TODO: Screen size specific, etc
class DimenUtils {
    static let VERBOSE = false
	static let ORIGINAL_SCREEN_SIZE_WIDTH = 1920.0 as CGFloat
	static var ratio = 1.0 as CGFloat
	
	static func updateRatio(currentWidth : CGFloat) {
		ratio = currentWidth / DimenUtils.ORIGINAL_SCREEN_SIZE_WIDTH
		if (DimenUtils.VERBOSE) {
            Swift.print("DimenUtils, updateRatio:", ratio)
        }
	}
	
	static func getDimension(dimension: Int) -> CGFloat {
		return DimenUtils.ratio * CGFloat(dimension)
	}
	
	static func getDimension(dimension: CGFloat) -> CGFloat {
		return DimenUtils.ratio * dimension
	}
	
	static func getDimensions(dimensions: Array<Int>) -> Array<CGFloat> {
		var floatDimens: Array<CGFloat> = []
		var i = 0
		while (i < dimensions.count) {
			floatDimens.append(DimenUtils.ratio * CGFloat(dimensions[i]))
			i = i + 1
		}
		return floatDimens
	}
	
	static func getDimensionsInInt(dimensions: Array<Int>) -> Array<Int> {
		var floatDimens: Array<Int> = []
		var i = 0
		while (i < dimensions.count) {
			floatDimens.append(Int(DimenUtils.ratio * CGFloat(dimensions[i])))
			i = i + 1
		}
		return floatDimens
	}
	
	static func getDimensionInInt(dimension: Int) -> Int {
		return Int(getDimension(dimension: dimension))
	}
	
	static func getUpdatedRect(dimensions: Array<Int>) -> CGRect {
		var rectArray: Array<CGFloat>
		rectArray = DimenUtils.getDimensions(dimensions: dimensions)
//		let otherFrame = CGRect(x: rectArray[0], y: rectArray[1], width: rectArray[2], height: rectArray[3])
		return CGRect(x: rectArray[0], y: rectArray[1], width: rectArray[2], height: rectArray[3])
	}
	
	static func getUpdatedRect2(frame: CGRect, dimensions: Array<Int>) -> CGRect {
		var rectArray: Array<CGFloat>
		rectArray = DimenUtils.getDimensions(dimensions: dimensions)
		return CGRect(x: frame.origin.x, y: frame.origin.y, width: rectArray[0], height: rectArray[1])
	}
	
	static func getUpdatedRect2WithConv(frame: CGRect, dimensions: Array<Int>) -> CGRect {
		var rectArray: Array<CGFloat>
		rectArray = DimenUtils.getDimensions(dimensions: dimensions)
		let x = DimenUtils.getDimension(dimension: frame.origin.x)
		let y = DimenUtils.getDimension(dimension: frame.origin.y)
		return CGRect(x: x, y: y, width: rectArray[0], height: rectArray[1])
	}
}
