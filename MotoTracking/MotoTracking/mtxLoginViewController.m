//
//  mtxLoginViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxLoginViewController.h"

@interface mtxLoginViewController ()

@end

@implementation mtxLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _codiceAttivazione = @"";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _txtCodiceAttivazione.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _txtCodiceAttivazione.delegate = self;
    
    if ([_codiceAttivazione isEqualToString:@""]) {
        [self loadSettings];
    }

    _txtCodiceAttivazione.text = _codiceAttivazione;
    
    [_btnLogin addTarget:self action:@selector(askLogin:)forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return ([textField.text length] + [string length] - range.length <=6);

}

- (void) askLogin:(id)sender{
    _txtCodiceAttivazione.text = [_txtCodiceAttivazione.text uppercaseString];
    _codiceAttivazione = _txtCodiceAttivazione.text;
    
    [self RC_Login];
    
}

- (void) RC_Login{
    
    [self saveSettings];
    
    myRemoteConnector = [[RemoteConnector alloc] init];
    myRemoteConnector.delegate = self;

    [myRemoteConnector rc_:[NSString stringWithFormat:@"Accesso.asp?CodiceAttivazione=%@", _codiceAttivazione]];
}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didDataReceived:(NSData *)data{
    
    mtxLoggedUser *theLoggedUser = [[mtxLoggedUser alloc] init];
    [theLoggedUser parseFromData:data];
    
    [self.view removeFromSuperview];
    [self.delegate loginViewController:self loggedIn:theLoggedUser];

}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didConnectionErrorReceived:(NSError *)error{

    NSLog(@"Eror during connection: %@", [error description]);
    
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Problemi di connessione"];
    [alert setMessage:@"La connessione ai server non è disponibile."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Ok"];
    [alert show];

}

-(void)loadSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _codiceAttivazione = [prefs stringForKey:@"CodiceAttivazione"];
}

-(void)saveSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_codiceAttivazione forKey:@"CodiceAttivazione"];
    [prefs synchronize];
}

@end
