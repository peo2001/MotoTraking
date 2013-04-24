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
- (void) sessionManager:(mtxSessionManager *)sessionManager startTracking:(mtxLoggedUser *)theLoggedUser;
- (void) sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations;

@end

@interface mtxSessionManager : NSObject <LoginDelegate, TrackingDelegate>{
    mtxLoginViewController *myLogin;
    NSTimer *myTimer;
    mtxTrackings *myTracking;
}

@property (nonatomic, assign) id <SessionManagerDelegate> delegate;

@property (nonatomic, retain, readonly) mtxLoggedUser *loggedUser;

- (void)loginOnView:(UIViewController *)aViewController;
- (mtxTrackings *) getTracking;

@end
