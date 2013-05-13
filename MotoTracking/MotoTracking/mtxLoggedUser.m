//
//  mtxLoggedUser.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 23/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxLoggedUser.h"

@implementation mtxLoggedUser

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        _status = @"";
        _idGara = 0;
        _idRuolo = 0;
        _idRuoloInGara = 0;
        _codRuolo = @"";
        _codiceAttivazione = @"";
        _gara = @"";
        _dataInizio = @"";
        _dataFine = @"";
        _deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    }
    return self;
}

- (void) parseFromData:(NSData *)data{
    
    [self parse:[RXMLElement elementFromXMLData:data]];

}

- (void) parse:(RXMLElement *) rootXML{
    // cicla sui menuitems
    
    _status = [rootXML attribute:@"St"];
    
    [rootXML iterate:@"LoggedUser" usingBlock: ^(RXMLElement *aMenuItemXML) {
        
        // legge gli attributi del login
        _idGara = [aMenuItemXML child:@"IdGara"].textAsInt;
        _idRuolo = [aMenuItemXML child:@"IdRuolo"].textAsInt;
        _idRuoloInGara = [aMenuItemXML child:@"IdRuoloInGara"].textAsInt;
        _codiceAttivazione = [aMenuItemXML child:@"CodiceAttivazione"].text;
        _gara = [aMenuItemXML child:@"Gara"].text;
        _codRuolo = [aMenuItemXML child:@"CodRuolo"].text;
        _dataInizio = [aMenuItemXML child:@"DataInizio"].text;
        _dataFine = [aMenuItemXML child:@"DataFine"].text;
    }];
}

- (BOOL) isLogged{
    return (_idRuoloInGara > 0);
}

- (void) alertForInvalidLogin:(NSString *)aStatus{
    
    NSString *aMessage;
    UIAlertView *alert;
    
    _status = aStatus;
    
    alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Accesso Fallito"];
    if ([_status isEqualToString:@"F"]) {
        aMessage = @"Codice Attivazione errato";
    }
    else if([_status isEqualToString:@"S"]){
        aMessage = [NSString stringWithFormat:@"La gara\n%@\n deve ancora iniziare\n\n%@", _gara, _dataInizio];
    }
    else if([_status isEqualToString:@"E"]){
        aMessage = [NSString stringWithFormat:@"La gara\n%@\n è terminata\n\n%@", _gara, _dataFine];
    }
    else if([_status isEqualToString:@"G"]){
        aMessage = [NSString stringWithFormat:@"Per utilizzare questa applicazione\noccorre attivare i servizi di localizzazione."];
    }
    [alert setMessage:aMessage];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Ok"];
    [alert show];

}
@end
