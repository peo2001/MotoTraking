//
//  StaticFunctions.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 14/05/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#ifndef MotoTracking_StaticFunctions_h
#define MotoTracking_StaticFunctions_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}

static UIImage* rotate(UIImage* src, double degrees)
{
    CGSize aSize = src.size;
    
    UIGraphicsBeginImageContext(aSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetAllowsAntialiasing(context, YES);
    //CGContextSetShouldAntialias(context, YES);
    
    CGContextTranslateCTM(context, src.size.width/2, src.size.height/2);
    CGContextRotateCTM (context, radians(degrees));
    [src drawInRect:(CGRect){ { -aSize.width * 0.5f, -aSize.height * 0.5f }, aSize }];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#endif
