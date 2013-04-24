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
        myTracking = [[mtxTrackings alloc] init];
        myTracking.delegate = self;
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
        [self reloadTrackings];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_INTERVAL_SECS target:self selector:@selector(reloadTrackings) userInfo:nil repeats:YES];
    }
}

-(void)reloadTrackings{
    [myTracking RC_Tracking:_loggedUser.idRuoloInGara idGara:_loggedUser.idGara];
}

-(void)tracking:(mtxTrackings *)tracking newTackingRetrieved:(NSMutableArray *)tracks{
    [self.delegate sessionManager:self didNewTrackingReceived:tracks];
}

- (mtxTrackings *) getTracking{
    return myTracking;
}
@end
