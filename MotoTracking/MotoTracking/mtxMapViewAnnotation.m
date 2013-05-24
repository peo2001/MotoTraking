//
//  mtxMapViewAnnotation.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 18/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxMapViewAnnotation.h"
#import "StaticFunctions.h"
#import "mtxImageManager.h"

static const NSString *DEVICE_ANN_COD = @"SELF";

@implementation mtxMapViewAnnotation

+ annFromUserLocation:(MKUserLocation *) aUserLocation{
    
    mtxMapViewAnnotation *aAnn = [[mtxMapViewAnnotation alloc] initWithCode:DEVICE_ANN_COD Coordinate:aUserLocation.coordinate];
    aAnn.course = aUserLocation.heading.trueHeading;
    
    return aAnn;
}


+ (double)annotationPadding;
{
    return 10.0f;
}
+ (double)calloutHeight;
{
    return 40.0f;
}
- (id)initWithCode:(const NSString *) aCodRuolo Coordinate:(CLLocationCoordinate2D)aCoordinate {
    self = [super init];
    if (self != nil)
    {
    _codRuolo = [NSString stringWithFormat:@"%@", aCodRuolo];
	_title = @"";
	_coordinate = aCoordinate;
    _course = 0.0;
    }
	return self;
}

- (UIImage *) GetImage:(CGRect)mapViewBounds FrameHeight:(double) frHeight {
    // setup image for the map
    //UIImage *annImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",  _codRuolo]];
    UIImage *annImage = [mtxImageManager getRoleImage:_codRuolo];
    return [DEVICE_ANN_COD isEqualToString:_codRuolo] ? rotate(annImage, _course) : annImage;
    
}

@end
