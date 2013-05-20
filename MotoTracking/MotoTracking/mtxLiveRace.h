//
//  mtxLiveRaces.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/05/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXMLElement.h"

@interface mtxLiveRace : NSObject

@property (nonatomic, readonly) NSString* gara;
@property (readonly) NSInteger idGara;
@property (nonatomic, readonly) NSString* codTipoGara;
@property (nonatomic, readonly) NSString* tipoGara;
@property (nonatomic, readonly) NSString* periodo;

- (id) initWithXMLElement:(RXMLElement *) aRace;

@end
