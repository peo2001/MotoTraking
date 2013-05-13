//
//  mtxMapViewAnnotation.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 18/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxMapViewAnnotation.h"

@implementation mtxMapViewAnnotation

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}
- (id)initWithCode:(NSString *)aCodRuolo Coordinate:(CLLocationCoordinate2D)aCoordinate {
    self = [super init];
    if (self != nil)
    {
    _codRuolo = aCodRuolo;
	_title = @"";
	_coordinate = aCoordinate;
    _course = 0.0;
    }
	return self;
}

- (UIImage *) GetImage:(CGRect)mapViewBounds FrameHeight:(CGFloat) frHeight {
    // setup image for the map
    UIImage *annImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", _codRuolo]];
    return annImage;    
}

@end
