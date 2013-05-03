//
//  mtxAppDelegate.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mtxSessionManager.h"


#define MainAppDelegate ((mtxAppDelegate *)[UIApplication sharedApplication].delegate)

@interface mtxAppDelegate : UIResponder <UIApplicationDelegate>
{

}
@property (readonly) BOOL isForeground;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) mtxSessionManager *mainSessionManager;

@property bool connectionError;


@end
