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

@property NSInteger idGara;
@property NSInteger idRuolo;
@property NSInteger idRuoloInGara;
@property (nonatomic, readonly, assign) NSString * codRuolo;
@property (nonatomic, readonly, assign) NSString * gara;
@property (nonatomic, readonly, assign) NSString * codiceAttivazione;

- (void) parseFromData:(NSData *)data;

@end
