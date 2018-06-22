//
//  UnitBezier.h
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#ifndef UnitBezier_h
#define UnitBezier_h

class UnitBezier {
public:
    UnitBezier(double p1x, double p1y, double p2x, double p2y);
    
    double sampleCurveX(double t);
    
    double sampleCurveY(double t);
    
    double sampleCurveDerivativeX(double t);
    
    // Given an x value, find a parametric value it came from.
    double solveCurveX(double x, double epsilon);
    
    double solve(double x, double epsilon);
    
private:
    double ax;
    double bx;
    double cx;
    
    double ay;
    double by;
    double cy;
};

#endif /* UnitBezier_h */
