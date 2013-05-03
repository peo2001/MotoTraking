//
//  mtxLoginViewController.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteConnector.h"
#import "mtxLoggedUser.h"

@class mtxLoginViewController;

@protocol LoginDelegate

@optional

- (void) loginViewController:(mtxLoginViewController *)loginViewController loggedIn:(mtxLoggedUser *)loggedUser;

@end

@interface mtxLoginViewController: UIViewController <UITextFieldDelegate, RemoteConnectorDelegate>
{
    RemoteConnector *myRemoteConnector;
}
@property (nonatomic, assign) id <LoginDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *txtCodiceAttivazione;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@property (nonatomic, retain) NSString *codiceAttivazione;

@end
