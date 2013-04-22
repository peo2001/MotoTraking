//
//  mtxSessionManager.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class mtxSessionManager;

@protocol SessionManagerDelegate

@optional

//- (void)  didMsgReceived;
- (void) sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations;
- (void) sessionManager:(mtxSessionManager *)sessionManager askForLogin:(NSString *)codiceAttivazione;

@end

@interface mtxSessionManager : NSObject

@property (nonatomic, assign) id <SessionManagerDelegate> delegate;

@property (nonatomic, assign) NSString *idRuoloInGara;
@property (nonatomic, assign) NSString *codiceAttivazione;

- (void) login;

@end
