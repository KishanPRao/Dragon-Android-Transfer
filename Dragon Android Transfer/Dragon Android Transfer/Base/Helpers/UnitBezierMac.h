//
//  UnitBezierMac.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BezierCurveType) {
    kLinear,
    kEaseInEaseOut,
    kEaseIn,
    kEaseOut
};

@interface UnitBezierMac : NSObject
@property (nonatomic, assign) BezierCurveType curveType;

- (void) updateCurveType: (BezierCurveType) curveType;
- (double) solve: (double) x;
@end
