//
//  mtxLoginViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxLoginViewController.h"

@implementation mtxLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _codiceAttivazione = @"";
        _deviceId = @"";
        
        myLiveRaces = [[NSMutableArray alloc] initWithCapacity:0];
        
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
    
    _btnLogin.enabled = FALSE;
    
    // setting tableview delegate (self)
    _tblLiveRace.delegate = self;
    _tblLiveRace.dataSource = self;
    
    [self RC_LiveRaces];

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
    
    _btnLogin.enabled = FALSE;
    
    _txtCodiceAttivazione.text = [_txtCodiceAttivazione.text uppercaseString];
    _codiceAttivazione = _txtCodiceAttivazione.text;
    
    [self RC_Login];
    
}

#pragma mark - Remote connector

- (void) RC_LoginAsGuestToRace:(NSInteger) IdGara{
    
    [self saveSettings];
    
    myRemoteConnector = [[RemoteConnector alloc] init];
    myRemoteConnector.delegate = self;
    myRemoteConnector.tag = @"LoginAsGuest";
    
    [myRemoteConnector rc_:[NSString stringWithFormat:@"Accesso.asp?DeviceId=%@&IdGara=%@", _deviceId, @"IdGara"]];
}

- (void) RC_Login{
    
    [self saveSettings];
    
    myRemoteConnector = [[RemoteConnector alloc] init];
    myRemoteConnector.delegate = self;
    myRemoteConnector.tag = @"Login";
    
    [myRemoteConnector rc_:[NSString stringWithFormat:@"Accesso.asp?DeviceId=%@&CodiceAttivazione=%@", _deviceId, _codiceAttivazione]];
}

- (void) RC_LiveRaces{
    
    [self saveSettings];
    
    myRemoteConnector = [[RemoteConnector alloc] init];
    myRemoteConnector.delegate = self;
    myRemoteConnector.tag = @"LiveRaces";
    
    [myRemoteConnector rc_:[NSString stringWithFormat:@"LiveRaces.asp?DeviceId=%@&Lat=%f&Long=%f", _deviceId, 0.0, 0.0]];
}

- (void) remoteConnector:(RemoteConnector *)remoteConnector didDataReceived:(NSData *)data{
    
    _btnLogin.enabled = TRUE;

    // answer for login
    if ([@"Login" isEqualToString:myRemoteConnector.tag]) {
        
        mtxLoggedUser *theLoggedUser = [[mtxLoggedUser alloc] init];
        [theLoggedUser parseFromData:data];
        
        if ([theLoggedUser.status isEqualToString:@"R"]) {
            [self.view removeFromSuperview];
            [self.delegate loginViewController:self loggedIn:theLoggedUser];
        }
        else
        {
            [theLoggedUser alertForInvalidLogin:theLoggedUser.status];
        }
    }
    
    // answer for live races
    else if (([@"LiveRaces" isEqualToString:myRemoteConnector.tag])){
        [self parseLiveRaces:data];
    }
    
    // answer for Login as guest
    else if ([@"LoginAsGuest" isEqualToString:myRemoteConnector.tag]) {
        
        mtxLoggedUser *theLoggedUser = [[mtxLoggedUser alloc] init];
        [theLoggedUser parseFromData:data];
        
        if ([theLoggedUser.status isEqualToString:@"R"]) {
            [self.view removeFromSuperview];
            [self.delegate loginViewController:self loggedIn:theLoggedUser];
        }
        else
        {
            [theLoggedUser alertForInvalidLogin:theLoggedUser.status];
        }
    }
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
    
    _btnLogin.enabled = TRUE;

}

#pragma mark - Settings

-(void)loadSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _codiceAttivazione = [prefs stringForKey:@"CodiceAttivazione"];
}

-(void)saveSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_codiceAttivazione forKey:@"CodiceAttivazione"];
    [prefs synchronize];
}

#pragma mark - live races parsing

- (void) parseLiveRaces:(NSData *) data{
    // cicla sui menuitems
    RXMLElement * rootXML = [RXMLElement elementFromXMLData:data];
    
    [rootXML iterate:@"Races.Race" usingBlock: ^(RXMLElement *aMenuItemXML) {
        
        mtxLiveRace *aRace = [[mtxLiveRace alloc] initWithXMLElement:aMenuItemXML];
        
        [myLiveRaces addObject:aRace];
        
    }];
    
    [_tblLiveRace reloadData];

}

#pragma mark - live races table view delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Live races";
            break;
            
        default:
            return @"-";
            break;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Select one to watch the race.";
            break;
            
        default:
            return @"-";
            break;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return myLiveRaces.count;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"LRcell"]];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:[NSString stringWithFormat:@"LRcell"]];
    }
    
    mtxLiveRace *aRace = [myLiveRaces objectAtIndex:indexPath.item];
    
    cell.textLabel.text = aRace.gara;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"TG_%@.png",  aRace.codTipoGara]];
    cell.detailTextLabel.text = aRace.periodo;
    return cell;
}

/*
 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TV_CELL_HEIGTH;
}
*/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self RC_LoginAsGuestToRace:((mtxLiveRace *)[myLiveRaces objectAtIndex:indexPath.item]).idGara];
}


@end
