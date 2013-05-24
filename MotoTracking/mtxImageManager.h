//
//  mtxImageManager.h
//  RaceTracking
//
//  Created by Eugenio Pompei on 23/05/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mtxImageManager : NSObject

+(void) loadRolesImage: (NSMutableArray *) ruoliPrevisti;
+(UIImage *) getRoleImage: (NSString *)codRuolo;


@end
