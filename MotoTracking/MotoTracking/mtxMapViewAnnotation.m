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
    }
	return self;
}

- (UIImage *) GetImage:(CGRect)mapViewBounds FrameHeight:(CGFloat) frHeight {
    // setup image for the map
    UIImage *flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", _codRuolo]];
    
    
    CGRect resizeRect;
    
    resizeRect.size.height = flagImage.size.height * 0.25 ;
    resizeRect.size.width = flagImage.size.width * 0.25 ;
        
    resizeRect.origin = (CGPoint){0.0f, 0.0f};
    UIGraphicsBeginImageContext(resizeRect.size);
    
    
    [flagImage drawInRect:resizeRect blendMode:kCGBlendModeLuminosity alpha:1];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
    
}

@end
