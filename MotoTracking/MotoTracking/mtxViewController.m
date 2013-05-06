//
//  mtxViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxViewController.h"

const NSTimeInterval LOCK_INTERVAL_SECS = 8.0;


@implementation mtxViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // use the right mapview depending on the device used
    //NSLog(@"Device model:%@", [[UIDevice currentDevice] model]);
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"])
    {
        myMapView = self.iPadMapView;
        lblGara = [[UILabel alloc]init];
        imgLock = [[UIImageView alloc] init];
    }else
    {
        myMapView = self.iPhoneMapView;
        lblGara = self.iPhoneLblGara;
        imgLock = self.iPhoneImgLock;
    }
    
    imgLock.image = nil;
    
    myMapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
    myMapView.showsUserLocation = YES;
    myMapView.userTrackingMode = MKUserTrackingModeNone;
    
    // Add gesture recognizer for map pinching
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [myMapView addGestureRecognizer:pinchGesture];

    // Add gesture recognizer for map tapping
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [myMapView addGestureRecognizer:tapGesture];

    // Add gesture recognizer for map dragging
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;  // In order to discard dragging when pinching
    [myMapView addGestureRecognizer:panGesture];
    
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidAppear:(BOOL)animated{
    // Receive the events from the the main session manager
    MainAppDelegate.mainSessionManager.delegate = self;
    
    [MainAppDelegate.mainSessionManager loginOnView:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{

}


#pragma - mark Session Manager Events
-(void)sessionManager:(mtxSessionManager *)sessionManager loggedIn:(mtxLoggedUser *)theLoggedUser{
    
    lblGara.text = theLoggedUser.gara;
    myLockMapResize = FALSE;

}

-(void)sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations{
    
    [myMapView removeAnnotations:MainAppDelegate.mainSessionManager.previousAnnotations];
    [myMapView addAnnotations:(NSArray *) annotations];
    
    MKCoordinateRegion region = sessionManager.tracking.getFitRegion;
    
    if (!myLockMapResize){
        region = [myMapView regionThatFits:region];
        [myMapView setRegion:region animated:YES];
    }

}

#pragma - mark Map Events

// Allow to recognize multiple gestures simultaneously (Implementation of the protocole UIGestureRecognizerDelegate)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePinchGesture:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        //NSLog(@"Pinched");
        
        [self lockMapresize];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        //NSLog(@"Tapped");

        [MainAppDelegate.mainSessionManager setAnnotationFilter:@""];
        imgLock.image = nil;
        
        [self unlockMapresize];
        
        [MainAppDelegate.mainSessionManager reloadTrackings];
        
    }
}

- (void)handlePanGesture:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized){
        //NSLog(@"Panned");
        
        [self lockMapresize];
    }
}

- (void) unlockMapresize{
    
    [self clearLockTimer];
    myLockMapResize = FALSE;
    [MainAppDelegate.mainSessionManager reloadTrackings];
    
}

- (void) lockMapresize{
    if (!myLockMapResize) {
        imgLock.image = [UIImage imageNamed:@"Clock.png"];
        myLockMapResize = TRUE;
        [self resetLockTimer];
    }
}

- (void) resetLockTimer {
    
    [self clearLockTimer];
    
    myLockTimer = [NSTimer scheduledTimerWithTimeInterval:LOCK_INTERVAL_SECS
                                                   target:self selector:@selector(filterTrackingAnnotation)
                                                 userInfo:nil repeats:NO];


}

- (void) clearLockTimer{
    if (myLockTimer != nil) {
        [myLockTimer invalidate];
        myLockTimer = nil;
    }

}


- (void) filterTrackingAnnotation{
    
    myLockTimer = nil;

    if ([MainAppDelegate.mainSessionManager tryLockTracking]){
    
        MKMapRect visibleMapRect = myMapView.visibleMapRect;
        NSSet *visibleAnnotations = [myMapView annotationsInMapRect:visibleMapRect];
        NSString *annToShow = @"(";
        
        for (mtxMapViewAnnotation *aAnn in MainAppDelegate.mainSessionManager.annotations) {
            if ([visibleAnnotations containsObject:aAnn]){
                annToShow = [NSString stringWithFormat:@"%@%i,", annToShow, aAnn.idRuoloInGara];
            }
        }
        
        annToShow = [NSString stringWithFormat:@"%@0)", annToShow];
        
        [MainAppDelegate.mainSessionManager setAnnotationFilter:annToShow];
        
        imgLock.image = [UIImage imageNamed:@"Lock.png"];
        
        [self unlockMapresize];
        [MainAppDelegate.mainSessionManager unlockTracking];
        
        [MainAppDelegate.mainSessionManager reloadTrackings];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    mtxMapViewAnnotation *theAnn = annotation;

    // handle custom annotations
    NSString *aIdentifier = [NSString stringWithFormat:@"%@%i",theAnn.codRuolo, theAnn.progressivo];
    if ([annotation isKindOfClass:[mtxMapViewAnnotation class]])   // Annotation di mark
    {
        //static NSString* SFAnnotationIdentifier = @"MarkAnnId";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[myMapView dequeueReusableAnnotationViewWithIdentifier:aIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:aIdentifier];
            
            
            [self designPin:annotationView withAnnotation:theAnn];
            
            return annotationView;
        }
        else
        {
            
            [self designPin:pinView withAnnotation:theAnn];
            
            return pinView;
        }
    }
    
    return nil;
}

- (void) designPin:(MKAnnotationView *) pinView withAnnotation:(mtxMapViewAnnotation *) theAnn{

    pinView.canShowCallout = NO;
    
    // setup image for the map
    pinView.image = [theAnn GetImage:self.view.bounds FrameHeight:self.navigationController.navigationBar.frame.size.height];
    //pinView.alpha = 1 - 0.4* theAnn.Reliability;
    pinView.opaque = NO;
    
    if (theAnn.progressivo >0 && pinView.subviews.count == 0) {
        NIBadgeView* badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
        badgeView.text = [NSString stringWithFormat:@"%i", theAnn.progressivo];
        badgeView.font = [UIFont boldSystemFontOfSize:10];
        badgeView.backgroundColor = [UIColor clearColor];
        badgeView.tintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.7];
        badgeView.textColor = [UIColor blackColor];
        badgeView.shadowColor = [UIColor blackColor];
        [badgeView sizeToFit];
        [pinView addSubview:badgeView];
        
        /*
        // Ann text over annotation
        UILabel *label = [[UILabel alloc] initWithFrame:pinView.frame];
        label.text = [NSString stringWithFormat:@"%i", theAnn.progressivo];
        label.textAlignment = NSTextAlignmentCenter;
        //label.backgroundColor = [UIColor clearColor];
        
        [pinView addSubview:label];
        */
    }
    
//    NSLog(@"N. Subviews: %i", pinView.subviews.count);


}
@end
