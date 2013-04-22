//
//  RemoteConnector.h
//  iVixiV
//
//  Created by Eugenio Pompei on 22/10/12.
//  Copyright (c) 2012 xTreme Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RemoteConnector;
// definisce il protocollo di delegate
@protocol RemoteConnectorDelegate

@optional

//- (void)  didMsgReceived;
- (void) remoteConnector:(RemoteConnector *)remoteConnector didMessageReceived:(NSString *)msg;
- (void) remoteConnector:(RemoteConnector *)remoteConnector didDataReceived:(NSData *)data;

@end

@interface RemoteConnector : NSObject
{
    NSMutableData *dataWebService;
    BOOL mStandardBodyPrepared;
}

@property (nonatomic, assign) id <RemoteConnectorDelegate> delegate;
@property (nonatomic, retain) NSString *message;

@property (nonatomic, retain) NSMutableDictionary *parameters;

@property (nonatomic, retain) NSString *dataMode;

- (void) rc_:(NSString *) virtualDir;
+ (NSInteger) nextCall: (NSInteger) increment;

@end
