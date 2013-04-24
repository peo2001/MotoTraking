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
        _idGara = 0;
        _idRuolo = 0;
        _codRuolo = @"";
        _codiceAttivazione = @"";
        _gara = @"";
    }
    return self;
}

- (void) parseFromData:(NSData *)data{
    
    [self parse:[RXMLElement elementFromXMLData:data]];

}

- (void) parse:(RXMLElement *) rootXML{
    // cicla sui menuitems
    [rootXML iterate:@"LoggedUser" usingBlock: ^(RXMLElement *aMenuItemXML) {

    // legge gli attributi del login
    _idGara = [aMenuItemXML child:@"IdGara"].textAsInt;
    _idRuolo = [aMenuItemXML child:@"IdRuolo"].textAsInt;
    _idRuoloInGara = [aMenuItemXML child:@"IdRuoloInGara"].textAsInt;
    _codiceAttivazione = [aMenuItemXML child:@"CodiceAttivazione"].text;
    _gara = [aMenuItemXML child:@"Gara"].text;
    _codRuolo = [aMenuItemXML child:@"CodRuolo"].text;
    }];
}

@end
