//
//  mtxTrackings.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 24/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#import "RemoteConnector.h"
#import "RXMLElement.h"
#import "mtxMapViewAnnotation.h"

@class mtxTrackings;

@protocol TrackingDelegate

@optional

- (void) deviceLocationNotAvailable;
- (void) tracking:(mtxTrackings *)tracking newTackingRetrieved:(NSMutableArray *)tracks;
- (void) tracking:(mtxTrackings *)tracking idleTracking:(NSString *)status;
- (void) tracking:(mtxTrackings *)tracking raceNoMoreValid:(NSString *)status;
- (void) tracking:(mtxTrackings *)tracking signalMeasured:(int)signalStrengt;

@end

@interface mtxTrackings : NSObject <RemoteConnectorDelegate>
{
    RemoteConnector *myRemoteConnector;
    IBOutlet CLLocationManager *locationManager;

    NSTimeInterval startTime;
    NSTimeInterval endTime;

}

@property (nonatomic, assign) id <TrackingDelegate> delegate;

@property (nonatomic, readonly, retain) NSString *status;

@property (nonatomic, retain, readonly) NSMutableArray *tracks;
@property (nonatomic, retain, readonly) NSMutableArray *previousTracks;

- (void) RC_Tracking:(NSInteger) idRuoloInGara idGara:(NSInteger) idGara annotationFilter:annotationFilter;
- (CLLocation *)deviceLocation;
- (double) deviceLocationAccuracy;
- (MKCoordinateRegion)getFitRegion: (BOOL) forceInvalidAnnotation;

@end
