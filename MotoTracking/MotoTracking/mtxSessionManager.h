//
//  mtxSessionManager.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mtxLoginViewController.h"
#import "mtxLoggedUser.h"
#import "mtxTrackings.h"

@class mtxSessionManager;

@protocol SessionManagerDelegate

@optional

//- (void)  didMsgReceived;
- (void) sessionManager:(mtxSessionManager *)sessionManager askForLogin:(NSString *)codiceAttivazione;
- (void) sessionManager:(mtxSessionManager *)sessionManager loggedIn:(mtxLoggedUser *)theLoggedUser;
- (void) sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations;
- (void) sessionManager:(mtxSessionManager *)sessionManager signalMeasured:(int)signalStrengt;
@end

@interface mtxSessionManager : NSObject <LoginDelegate, TrackingDelegate>{
    
    UIViewController *mapViewController;
    mtxLoginViewController *myLogin;
    NSTimer *myTimer;
    NSLock *myLock;
    BOOL isTrackingRunning;
    bool trakingStoppedInBackground;
}

@property (nonatomic, assign) id <SessionManagerDelegate> delegate;
@property (nonatomic, retain, readonly) mtxLoggedUser *loggedUser;
@property (nonatomic, retain) NSString *annotationFilter;
@property (nonatomic, retain, readonly) mtxTrackings *tracking;

- (void)loginOnView:(UIViewController *)aViewController;
- (void) reloadTrackings;
- (NSArray *) annotations;
- (NSArray *) previousAnnotations;
- (BOOL) tryLockTracking;
- (void) unlockTracking;
- (void) startTracking;
- (BOOL) isLogged;

@end
