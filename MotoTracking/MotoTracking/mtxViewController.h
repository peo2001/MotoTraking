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
    UIImageView *imgSignal;
    UILabel *lblTime;
    
    NSTimer *myTimer;

    BOOL myAnnotationFiltered;  // se la mappa è "filtrata" su solo alcune annotations
    int secsToFiltering;    // quanti secondi mancano alla definizione del filtro
    
    double degrees;
    
}

@property (weak, nonatomic) IBOutlet MKMapView *iPhoneMapView;
@property (weak, nonatomic) IBOutlet UILabel *iPhoneLblGara;
@property (weak, nonatomic) IBOutlet UIImageView *iPhoneImgLock;
@property (weak, nonatomic) IBOutlet UIImageView *iPhoneImgSignal;
@property (weak, nonatomic) IBOutlet UILabel *iPhoneTime;

@property (weak, nonatomic) IBOutlet MKMapView *iPadMapView;
@property (weak, nonatomic) IBOutlet UILabel *iPadLblGara;
@property (weak, nonatomic) IBOutlet UIImageView *iPadImgLock;
@property (weak, nonatomic) IBOutlet UIImageView *iPadImgSignal;
@property (weak, nonatomic) IBOutlet UILabel *iPadTime;

@end
