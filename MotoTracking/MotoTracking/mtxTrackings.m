//
//  mtxTrackings.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 24/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxTrackings.h"
#import "mtxAppDelegate.h"

static const CGFloat MIMAL_ACCURACY = 250.0;

@implementation mtxTrackings

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
        
        myRemoteConnector = [[RemoteConnector alloc] init];
        myRemoteConnector.delegate = self;
        
        _tracks = [[NSMutableArray alloc] initWithCapacity:0];
        _previousTracks = [[NSMutableArray alloc] initWithCapacity:0];
        
        myOldLocation = [[CLLocation alloc] initWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude];
        
    }
    return self;
}

-(BOOL) validDeviceLocation{
    if (![CLLocationManager locationServicesEnabled]){
        return false;
    }
    if ((locationManager.location.horizontalAccuracy+locationManager.location.verticalAccuracy) > MIMAL_ACCURACY){
        //NSLog(@"Low accuracy %f", locationManager.location.horizontalAccuracy+locationManager.location.verticalAccuracy);
        return false;
    }
    return true;
}

-(CLLocation *)deviceLocation{
    
    if ([self validDeviceLocation]){
        myOldLocation = myOldLocation = [[CLLocation alloc] initWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude];
        return locationManager.location;
        }
    else{
        return myOldLocation;
    }
    
}

- (void) RC_Tracking:(NSInteger) idRuoloInGara idGara:(NSInteger) idGara annotationFilter:annotationFilter{
    
    NSString *aURL = [NSString stringWithFormat:@"Tracking.asp?IdGara=%i&IdRuoloInGara=%i&Lat=%f&Long=%f&Course=%f&Speed=%f",
                      idGara, idRuoloInGara,
                      [self deviceLocation].coordinate.latitude, [self deviceLocation].coordinate.longitude,
                      [self deviceLocation].course, [self deviceLocation].speed];
    
    if (![annotationFilter isEqualToString:@""]) {
        aURL = [NSString stringWithFormat:@"%@&AnnotationFilter=%@", aURL, annotationFilter];
    }
    
    [myRemoteConnector rc_:aURL];
    
    // Start timer
    startTime = [NSDate timeIntervalSinceReferenceDate];

}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didDataReceived:(NSData *)data{
    
    RXMLElement * aRootElement = [RXMLElement elementFromXMLData:data];
    
    // Stop timer
    endTime = [NSDate timeIntervalSinceReferenceDate];
    
    [self parse:aRootElement];

    
    [self.delegate tracking:self signalMeasured:[self getSignalStrenght]];

}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didConnectionErrorReceived:(NSError *)error{

    // Stop timer
    endTime = 0;
    [self.delegate tracking:self signalMeasured:[self getSignalStrenght]];

    [self.delegate tracking:self newTackingRetrieved:_tracks];
}

- (void) parse:(RXMLElement *) rootXML{
    
    
    _status = [rootXML attribute:@"St"];
    
    if (!MainAppDelegate.isForeground) {
        if ([_status isEqualToString:@"R"]) {
            [self.delegate tracking:self idleTracking:_status];
        }
    }else{
        
        _previousTracks = _tracks;
        _tracks = [[NSMutableArray alloc] initWithCapacity:0];
        
        // cicla sui menuitems
        [rootXML iterate:@"Tracks.Track" usingBlock: ^(RXMLElement *aMenuItemXML) {
            
            int aReliability = [aMenuItemXML  attributeAsInt:@"Rel"];
            int aProgressivo = [aMenuItemXML  attributeAsInt:@"Pr"];
            
            CLLocationCoordinate2D aCoord;
            aCoord.latitude = [aMenuItemXML  attributeAsDouble:@"y"] ;
            aCoord.longitude = [aMenuItemXML  attributeAsDouble:@"x"] ;
            
            NSString *codRuolo = [aMenuItemXML  attribute:@"cr"];
            
            mtxMapViewAnnotation *aAnnotation = [[mtxMapViewAnnotation alloc] initWithCode:codRuolo Coordinate:aCoord];
            aAnnotation.idRuoloInGara = [aMenuItemXML  attributeAsInt:@"idRG"];
            aAnnotation.Reliability = aReliability;
            aAnnotation.progressivo = aProgressivo;
            
            [_tracks addObject:aAnnotation];
            
        }];
        
        if ([_status isEqualToString:@"R"]) {
            [self.delegate tracking:self newTackingRetrieved:_tracks];
        }
    }
    if (![_status isEqualToString:@"R"]){
        [self.delegate tracking:self raceNoMoreValid:_status];
    }
}

- (MKCoordinateRegion)getFitRegion:(BOOL)forceInvalidAnnotation {
    
    BOOL mapResized = FALSE;
    MKCoordinateRegion region;

    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.longitude = 180;
    topLeftCoord.latitude = -90;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.longitude = -180;
    bottomRightCoord.latitude = 90;
    
    if ([self validDeviceLocation]) {
        mapResized = TRUE;
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [self deviceLocation].coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [self deviceLocation].coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [self deviceLocation].coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [self deviceLocation].coordinate.latitude);
    }
    for(mtxMapViewAnnotation *aAnn in _tracks) {
        if (aAnn.Reliability<2 || forceInvalidAnnotation) {
            mapResized = TRUE;
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, aAnn.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, aAnn.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, aAnn.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, aAnn.coordinate.latitude);
        }
    }
    
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    if (mapResized) {
        
        // Add a little extra space on the sides
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) *1.4;
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) *1.4;
        
        if ((region.span.latitudeDelta+region.span.longitudeDelta) < 0.006) {
            region.span.latitudeDelta = 0.003;
            region.span.longitudeDelta = 0.003;
        }
    }
    return region;
        
}

- (int) getSignalStrenght{

    if (endTime==0) {
        return 0;
    }

    // Get the elapsed time in milliseconds
    NSTimeInterval enlapsedTime = pow((endTime - startTime) + 0.7 * self.getReliability, 2);
    
    NSLog(@"enlapsed time: %f", enlapsedTime);
    
    if (enlapsedTime>5) {
        enlapsedTime = 5;
    }
    else if (enlapsedTime < 1) {
        enlapsedTime = 1;
    }
    
    return (int) (6-enlapsedTime);

}

- (CGFloat) getReliability{
    if (_tracks.count==0) {
        return 2.0;
    }else{
        CGFloat totReliability = 0.0;
        for (mtxMapViewAnnotation * aTrack in _tracks) {
            totReliability = totReliability + aTrack.Reliability;
        }
        return totReliability / _tracks.count;
    }
}
@end
