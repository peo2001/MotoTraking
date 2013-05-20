//
//  mtxLiveRaces.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/05/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxLiveRace.h"

@implementation mtxLiveRace

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        _idGara = 0;
        _gara = @"";
        _codTipoGara = @"";
        _tipoGara = @"";
        _periodo = @"";
    }
    return self;
}

- (id) initWithXMLElement:(RXMLElement *) aRace{
    
    self = [super init];
    if (self != nil)
    {
        [self parse:aRace];
    }
    return self;
}

- (void) parse:(RXMLElement *) aRace{
  
    // legge gli attributi della gara
    _idGara = [aRace attributeAsInt:@"IdGara"];
    _gara = [aRace attribute:@"Gara"];
    _codTipoGara = [aRace attribute:@"CodTipoGara"];
    _tipoGara = [aRace attribute:@"TipoGara"];
    _periodo = [aRace attribute:@"Periodo"];

}


@end
