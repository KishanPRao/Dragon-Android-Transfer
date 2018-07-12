//
//  UnitBezierMac.m
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#import "IncludeSwift.h"

#include <iostream>
#include <memory>
#include "UnitBezier.hpp"

#import "UnitBezierMac.h"

//@class UnitBezier;

@implementation UnitBezierMac

shared_ptr<UnitBezier> bezier;

- (void) updateCurveType: (BezierCurveType) curveType {
    double point1_x = 0;
    double point1_y = 0;
    double point2_x = 0;
    double point2_y = 0;
    if (self.curveType != curveType) {
        self.curveType = curveType;
        switch (curveType) {
            case kEaseInEaseOut:
                point1_x = 0.419999987;
                point1_y = 0;
                point2_x = 0.579999983;
                point2_y = 1;
                break;
            case kEaseIn:
                point1_x = 0.419999987;
                point1_y = 0;
                point2_x = 1;
                point2_y = 1;
                break;
            case kEaseOut:
                point1_x = 0;
                point1_y = 0;
                point2_x = 0.579999983;
                point2_y = 1;
                break;
            case kLinear:
                point1_x = 0;
                point1_y = 0;
                point2_x = 1;
                point2_y = 1;
                break;
                
            default:
                break;
        }
        bezier = make_shared<UnitBezier>(point1_x, point1_y, point2_x, point2_y);
    }
}

- (double) solve: (double) x {
    if (bezier) {
        return bezier->solve(x);
    } else {
//        std::cout<<"No active bezier!"<<std::endl;
        return x;
    }
}

@end
