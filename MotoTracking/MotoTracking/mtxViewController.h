//
//  mtxViewController.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NIBadgeView.h"

#import "mtxAppDelegate.h"
#import "mtxLoginViewController.h"
#import "mtxMapViewAnnotation.h"

@interface mtxViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, SessionManagerDelegate>
{
    MKMapView *myMapView;
    mtxLoginViewController *myLogin;
    UILabel *lblGara;
    UIImageView *imgLock;
    
    NSTimer *myLockTimer;
    BOOL myLockMapResize;
}

@property (weak, nonatomic) IBOutlet MKMapView *iPhoneMapView;
@property (weak, nonatomic) IBOutlet UILabel *iPhoneLblGara;
@property (weak, nonatomic) IBOutlet UIImageView *iPhoneImgLock;

@property (strong, nonatomic) IBOutlet MKMapView *iPadMapView;

@end
