//
//  mtxTrackings.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 24/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxTrackings.h"
#import "mtxAppDelegate.h"

static const CGFloat MIMAL_ACCURACY = 200.0;

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
        
    }
    return self;
}

-(BOOL) validDeviceLocation{
    if (![CLLocationManager locationServicesEnabled]){
        return false;
    }
    if ((locationManager.location.horizontalAccuracy+locationManager.location.verticalAccuracy) > MIMAL_ACCURACY){
        return false;
    }
    return true;
}

-(CLLocation *)deviceLocation{
    
    if ([self validDeviceLocation]){
        return locationManager.location;
        }
    else{
        return [[CLLocation alloc] init];
    }
    
}

- (void) RC_Tracking:(NSInteger) idRuoloInGara idGara:(NSInteger) idGara annotationFilter:annotationFilter{
    NSString *aURL = [NSString stringWithFormat:@"Tracking.asp?IdGara=%i&IdRuoloInGara=%i&Lat=%f&Long=%f",
                      idGara, idRuoloInGara,
                      [self deviceLocation].coordinate.latitude, [self deviceLocation].coordinate.longitude];
    if (![annotationFilter isEqualToString:@""]) {
        aURL = [NSString stringWithFormat:@"%@&AnnotationFilter=%@", aURL, annotationFilter];
    }
    
    [myRemoteConnector rc_:aURL];
}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didDataReceived:(NSData *)data{
    

        [self parse:[RXMLElement elementFromXMLData:data]];

}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didConnectionErrorReceived:(NSError *)error{
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

- (MKCoordinateRegion)getFitRegion {
    
    MKCoordinateRegion region;

    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.longitude = 180;
    topLeftCoord.latitude = -90;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.longitude = -180;
    bottomRightCoord.latitude = 90;
    
    if ([self validDeviceLocation]) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [self deviceLocation].coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [self deviceLocation].coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [self deviceLocation].coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [self deviceLocation].coordinate.latitude);
    }
    for(mtxMapViewAnnotation *aAnn in _tracks) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, aAnn.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, aAnn.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, aAnn.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, aAnn.coordinate.latitude);
    }
    
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) *1.4;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) *1.4;
    
    return region;
        
}


@end
