//
//  mtxLoggedUser.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 23/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXMLElement.h"

@interface mtxLoggedUser : NSObject
{
}

@property (nonatomic, readonly, retain) NSString *status;
@property (readonly) NSInteger idGara;
@property (readonly) NSInteger idRuolo;
@property (readonly) NSInteger idRuoloInGara;
@property (nonatomic, readonly, retain) NSString * codRuolo;
@property (nonatomic, readonly, retain) NSString * gara;
@property (nonatomic, readonly, retain) NSString * codiceAttivazione;
@property (nonatomic, readonly, retain) NSString * dataInizio;
@property (nonatomic, readonly, retain) NSString * dataFine;

- (void) parseFromData:(NSData *)data;
- (BOOL) isLogged;
- (void) alertForInvalidLogin:(NSString *) aStatus;

@end
