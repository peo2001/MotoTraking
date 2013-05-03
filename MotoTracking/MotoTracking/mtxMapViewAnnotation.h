//
//  mtxMapViewAnnotation.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 18/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface mtxMapViewAnnotation : NSObject <MKAnnotation>

@property NSInteger idRuoloInGara;
@property (nonatomic, readonly, retain) NSString *codRuolo;
@property (nonatomic, retain) NSString *codiceAttivazione;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property  CGFloat Reliability;

- (id)initWithCode:(NSString *)aCodRuolo Coordinate:(CLLocationCoordinate2D)aCoordinate;

- (UIImage *) GetImage:(CGRect)mapViewBounds FrameHeight:(CGFloat) frHeight;

@end
