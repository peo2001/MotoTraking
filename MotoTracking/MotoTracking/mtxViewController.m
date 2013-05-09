//
//  mtxViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxViewController.h"

const NSTimeInterval LOCK_INTERVAL_SECS = 5.0;


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
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self selector:@selector(phaseManager)
                                                 userInfo:nil repeats:YES];

    
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
    myAnnotationFiltered = FALSE;

}

-(void)sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations{
    
    [myMapView removeAnnotations:MainAppDelegate.mainSessionManager.previousAnnotations];
    [myMapView addAnnotations:(NSArray *) annotations];
    
}

#pragma - mark Map Events

// Allow to recognize multiple gestures simultaneously (Implementation of the protocole UIGestureRecognizerDelegate)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePinchGesture:(UIGestureRecognizer *)sender {
    
    [self handleResizeGesture:sender.state];
    
}

- (void)handlePanGesture:(UIGestureRecognizer *)sender {
    
    [self handleResizeGesture:sender.state];
    
}

- (void)handleResizeGesture:(UIGestureRecognizerState) state {
    
    if (state == UIGestureRecognizerStateBegan){
        
        //NSLog(@"handleResizeGesture state:%i", state);

        secsToFiltering=LOCK_INTERVAL_SECS;
        [self phaseManager];
    }

}

- (void)handleTapGesture:(UIGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        //NSLog(@"Tapped");
        
        [MainAppDelegate.mainSessionManager setAnnotationFilter:@""];
        
        secsToFiltering = 0;
        
        if (myAnnotationFiltered){
            myAnnotationFiltered = FALSE;
            imgLock.image = nil;
            [self phaseManager];
        }
        
    }
}


- (void) phaseManager{
    // viene chiamato ogni secondo e, a secondo dello stato della maschera, attiva le funzioni corrispondenti.
    
    if (MainAppDelegate.isForeground && MainAppDelegate.mainSessionManager.isLogged){
        
        
        if (secsToFiltering > 0){
            secsToFiltering -- ;
            if (secsToFiltering == 0) {
                [self filterTrackingAnnotation];
            }
        }

        if (secsToFiltering == 0) {
            // aggiorna la mappa
            MKCoordinateRegion region = [MainAppDelegate.mainSessionManager.tracking getFitRegion: myAnnotationFiltered];
            region = [myMapView regionThatFits:region];
            [myMapView setRegion:region animated:YES];
            
        }
        
        if (secsToFiltering>0){
            imgLock.image = [UIImage imageNamed:@"Clock.png"];
        }
        else if (myAnnotationFiltered) {
            
            imgLock.image = [UIImage imageNamed:@"Lock.png"];
            
        }
        else{
            imgLock.image = nil;
        }
        
        
    }
}




- (void) filterTrackingAnnotation{
    
    myTimer = nil;

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
        
        if (![annToShow isEqualToString:@"(0)"]) {

            [MainAppDelegate.mainSessionManager setAnnotationFilter:annToShow];
            
            myAnnotationFiltered = TRUE;
        }
        
        [MainAppDelegate.mainSessionManager unlockTracking];
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
    pinView.alpha = 1 - (theAnn.Reliability * .4);
    pinView.opaque = NO;
    
    if (theAnn.progressivo >0 && pinView.subviews.count == 0) {
        NIBadgeView* badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
        badgeView.text = [NSString stringWithFormat:@"%i", theAnn.progressivo];
        badgeView.font = [UIFont boldSystemFontOfSize:10];
        badgeView.backgroundColor = [UIColor clearColor];
        badgeView.tintColor = [UIColor whiteColor];
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
