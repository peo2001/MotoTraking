//
//  mtxSessionManager.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxSessionManager.h"
#import "mtxAppDelegate.h"

const NSTimeInterval RELOAD_INTERVAL_SECS = 5.0;

@implementation mtxSessionManager
- (id) init
{
    self = [super init];
    if (self != nil)
    {
        _loggedUser = [[mtxLoggedUser alloc] init];
        _tracking = [[mtxTrackings alloc] init];
        _tracking.delegate = self;
        _annotationFilter = @"";
        
        myLock = [[NSLock alloc]init];
        
        trakingStoppedInBackground = FALSE;
        isTrackingRunning = false;

        myTimer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_INTERVAL_SECS
                                                   target:self selector:@selector(reloadTrackings)
                                                 userInfo:nil repeats:YES];
    }
    return self;
}

- (void)loginOnView:(UIViewController *)aViewController{
    
    if(mapViewController == nil){
        mapViewController = aViewController;
    }
    myLogin = [[mtxLoginViewController alloc] init];
    myLogin.codiceAttivazione = _loggedUser.codiceAttivazione;
    myLogin.delegate = self;
    myLogin.view.frame = mapViewController.view.bounds;
    [mapViewController.view addSubview:myLogin.view];

    
}

-(void)loginViewController:(mtxLoginViewController *)loginViewController loggedIn:(mtxLoggedUser *)loggedUser{
    
    _loggedUser = loggedUser;

    myLogin = nil;
    
    if ([self isLogged]) {
        [self.delegate sessionManager:self loggedIn:loggedUser];
        [self startTracking];
    }
}

- (void) stopTracking{
    isTrackingRunning = false;
    
}
- (void) startTracking{
    
    isTrackingRunning = true;
    [self reloadTrackings];
}

-(void)reloadTrackings{
    if (MainAppDelegate.isForeground && trakingStoppedInBackground) {
        trakingStoppedInBackground = FALSE;
        [self startTracking];
    }
    else
    {
        if (isTrackingRunning && [myLock tryLock]) {
            //NSLog(@"Reload tracking");
            [_tracking RC_Tracking:_loggedUser.idRuoloInGara idGara:_loggedUser.idGara annotationFilter:_annotationFilter];
        }
    }
}

-(void)tracking:(mtxTrackings *)tracking signalMeasured:(int)signalStrengt{
    [self.delegate sessionManager:self signalMeasured:signalStrengt];
}

-(void)tracking:(mtxTrackings *)tracking newTackingRetrieved:(NSMutableArray *)tracks{
    [myLock unlock];
    [self.delegate sessionManager:self didNewTrackingReceived:tracks];
}

- (void)tracking:(mtxTrackings *)tracking raceNoMoreValid:(NSString *)status{
    [myLock unlock];
    [self stopTracking];

    if (MainAppDelegate.isForeground) {
        [_loggedUser alertForInvalidLogin:status];
        [self loginOnView:nil];
    }else{
        trakingStoppedInBackground = true;
    }
}

-(void)tracking:(mtxTrackings *)tracking idleTracking:(NSString *)status
{
    [myLock unlock];
}

- (NSArray *) annotations{
    return (NSArray *)_tracking.tracks;
}

- (NSArray *) previousAnnotations{
    return (NSArray *)_tracking.previousTracks;
}

- (BOOL) tryLockTracking{
    return [myLock tryLock];
}

- (void) unlockTracking{
    [myLock unlock];
}

- (BOOL) isLogged{
    return _loggedUser.isLogged;
}

@end
