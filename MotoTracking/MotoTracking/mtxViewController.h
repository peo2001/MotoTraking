//
//  mtxViewController.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "mtxAppDelegate.h"
#import "mtxLoginViewController.h"

#import "mtxMapViewAnnotation.h"

@interface mtxViewController : UIViewController <MKMapViewDelegate, SessionManagerDelegate>
{
    MKMapView *myMapView;
    mtxLoginViewController *myLogin;
}

@property (weak, nonatomic) IBOutlet MKMapView *iPhoneMapView;
@property (strong, nonatomic) IBOutlet MKMapView *iPadMapView;

@end
