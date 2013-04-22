//
//  mtxSessionManager.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxSessionManager.h"

@implementation mtxSessionManager

- (void)login{
    
    [self.delegate sessionManager:self askForLogin:@"ABCDEF"];
    
}

@end
