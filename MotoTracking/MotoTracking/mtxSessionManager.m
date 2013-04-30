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
    }
    return self;
}

- (void)loginOnView:(UIViewController *)aViewController{
    
    
    myLogin = [[mtxLoginViewController alloc] init];
    myLogin.codiceAttivazione = _loggedUser.codiceAttivazione;
    myLogin.delegate = self;
    [aViewController.view addSubview:myLogin.view];
    
}

-(void)loginViewController:(mtxLoginViewController *)loginViewController loggedIn:(mtxLoggedUser *)loggedUser{
    
    _loggedUser = loggedUser;
    
    myLogin = nil;
    
    if (![loggedUser.codiceAttivazione isEqualToString:@""]) {
        [self.delegate sessionManager:self startTracking:loggedUser];
        [self startReloadTimer];
    }
}

-(void) startReloadTimer{
    myTimer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_INTERVAL_SECS
                                            target:self selector:@selector(reloadTrackings)
                                            userInfo:nil repeats:YES];
    [self reloadTrackings];
}

-(void)reloadTrackings{
    if ([myLock tryLock]) {
        //NSLog(@"Reload tracking");
        [_tracking RC_Tracking:_loggedUser.idRuoloInGara idGara:_loggedUser.idGara annotationFilter:_annotationFilter];
    }
}

-(void)tracking:(mtxTrackings *)tracking newTackingRetrieved:(NSMutableArray *)tracks{
    [myLock unlock];
    [self.delegate sessionManager:self didNewTrackingReceived:tracks];
}


-(void)terminateTracking{
    //NSLog(@"Terminate tracking");
    [_tracking RC_terminateTracking:_loggedUser.idRuoloInGara idGara:_loggedUser.idGara];
}

- (NSArray *) annotations{
    return (NSArray *)_tracking.tracks;
}

- (NSArray *) previousAnnotations{
    return (NSArray *)_tracking.previousTracks;
}

- (void) setAnnotationFilter:(NSString *)annotationFilter{
    _annotationFilter = annotationFilter;
}

- (BOOL) tryLockTracking{
    return [myLock tryLock];
}

- (void) unlockTracking{
    [myLock unlock];
}

@end
