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

@property (nonatomic, readonly) NSString *status;
@property (readonly) NSInteger idGara;
@property (readonly) NSInteger idRuolo;
@property (readonly) NSInteger idRuoloInGara;
@property (nonatomic, readonly) NSString * codRuolo;
@property (nonatomic, readonly) NSString * gara;
@property (nonatomic, readonly) NSString * codiceAttivazione;
@property (nonatomic, readonly) NSString * dataInizio;
@property (nonatomic, readonly) NSString * dataFine;
@property (nonatomic, readonly) NSString * deviceId;

- (void) parseFromData:(NSData *)data;
- (BOOL) isLogged;
- (void) alertForInvalidLogin:(NSString *) aStatus;

@end
