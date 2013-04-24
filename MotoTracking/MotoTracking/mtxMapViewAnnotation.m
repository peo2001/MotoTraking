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
    UIImage *annImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", _codRuolo]];
    return annImage;
    
    CGRect resizeRect;
    
    resizeRect.size.height = annImage.size.height * 0.6 ;
    resizeRect.size.width = annImage.size.width * 0.6 ;
        
    resizeRect.origin = (CGPoint){0.0f, 0.0f};
    UIGraphicsBeginImageContext(resizeRect.size);
    
    
    [annImage drawInRect:resizeRect blendMode:kCGBlendModeLuminosity alpha:1];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
    
}

@end
