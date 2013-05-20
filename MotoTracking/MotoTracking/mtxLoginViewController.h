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
#import "mtxLiveRace.h"

@class mtxLoginViewController;

@protocol LoginDelegate

@optional

- (void) loginViewController:(mtxLoginViewController *)loginViewController loggedIn:(mtxLoggedUser *)loggedUser;

@end

@interface mtxLoginViewController: UIViewController <UITextFieldDelegate, RemoteConnectorDelegate, UITableViewDataSource, UITableViewDelegate>
{
    RemoteConnector *myRemoteConnector;
    NSMutableArray *myLiveRaces;
}
@property (nonatomic, assign) id <LoginDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *txtCodiceAttivazione;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UITableView *tblLiveRace;

@property (nonatomic, retain) NSString *codiceAttivazione;
@property (nonatomic, retain) NSString *deviceId;

@end
