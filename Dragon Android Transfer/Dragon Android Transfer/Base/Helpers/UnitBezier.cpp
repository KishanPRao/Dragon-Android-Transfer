//
//  UnitBezier.cpp
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

#include <stdio.h>
#include "UnitBezier.hpp"
#include <math.h>

    UnitBezier::UnitBezier(double p1x, double p1y, double p2x, double p2y)
    {
        // Calculate the polynomial coefficients, implicit first and last control points are (0,0) and (1,1).
        cx = 3.0 * p1x;
        bx = 3.0 * (p2x - p1x) - cx;
        ax = 1.0 - cx -bx;
        
        cy = 3.0 * p1y;
        by = 3.0 * (p2y - p1y) - cy;
        ay = 1.0 - cy - by;
    }
    
    double UnitBezier::sampleCurveX(double t)
    {
        // `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
        return ((ax * t + bx) * t + cx) * t;
    }
    
    double UnitBezier::sampleCurveY(double t)
    {
        return ((ay * t + by) * t + cy) * t;
    }
    
    double UnitBezier::sampleCurveDerivativeX(double t)
    {
        return (3.0 * ax * t + 2.0 * bx) * t + cx;
    }
    
    // Given an x value, find a parametric value it came from.
    double UnitBezier::solveCurveX(double x, double epsilon = 1e-6)
    {
        double t0;
        double t1;
        double t2;
        double x2;
        double d2;
        int i;
        
        // First try a few iterations of Newton's method -- normally very fast.
        for (t2 = x, i = 0; i < 8; i++) {
            x2 = sampleCurveX(t2) - x;
            if (fabs (x2) < epsilon)
                return t2;
            d2 = sampleCurveDerivativeX(t2);
            if (fabs(d2) < 1e-6)
                break;
            t2 = t2 - x2 / d2;
        }
        
        // Fall back to the bisection method for reliability.
        t0 = 0.0;
        t1 = 1.0;
        t2 = x;
        
        if (t2 < t0)
            return t0;
        if (t2 > t1)
            return t1;
        
        while (t0 < t1) {
            x2 = sampleCurveX(t2);
            if (fabs(x2 - x) < epsilon)
                return t2;
            if (x > x2)
                t0 = t2;
            else
                t1 = t2;
            t2 = (t1 - t0) * .5 + t0;
        }
        
        // Failure.
        return t2;
    }
    
    double UnitBezier::solve(double x, double epsilon)
    {
        return sampleCurveY(solveCurveX(x, epsilon));
    }
