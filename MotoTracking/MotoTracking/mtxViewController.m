//
//  mtxViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxViewController.h"

const NSTimeInterval LOCK_INTERVAL_SECS = 4.0;

@implementation mtxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // use the right mapview depending on the device used
    //NSLog(@"Device model:%@", [[UIDevice currentDevice] model]);
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"])
    {
        myMapView = self.iPadMapView;
        lblGara = self.iPadLblGara;
        imgLock = self.iPadImgLock;
        imgSignal = self.iPadImgSignal;
        lblTime = self.iPadTime;
    }else
    {
        myMapView = self.iPhoneMapView;
        lblGara = self.iPhoneLblGara;
        imgLock = self.iPhoneImgLock;
        imgSignal = self.iPhoneImgSignal;
        lblTime = self.iPhoneTime;
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
    
    
    degrees = 0;
    
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



#pragma mark - Session Manager Events
-(void)sessionManager:(mtxSessionManager *)sessionManager loggedIn:(mtxLoggedUser *)theLoggedUser{
    
    lblGara.text = theLoggedUser.gara;
    myAnnotationFiltered = FALSE;

}

-(void)sessionManager:(mtxSessionManager *)sessionManager signalMeasured:(int)signalStrengt{
    
    imgSignal.image = [UIImage imageNamed:[NSString stringWithFormat:@"SIG%i", signalStrengt]];
        
}

-(void)sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations{
    
    [myMapView removeAnnotations:MainAppDelegate.mainSessionManager.previousAnnotations];
    [myMapView addAnnotations:(NSArray *) annotations];
    
    if (secsToFiltering == 0)
        [self resizeMap];
    
}

#pragma mark - gesture Events

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
            [MainAppDelegate.mainSessionManager reloadTrackings];
        }
        else{
            [self resizeMap];

        }
        
    }
}

#pragma mark - PHASE MANAGER

- (void) phaseManager{
    // viene chiamato ogni secondo e, a secondo dello stato della maschera, attiva le funzioni corrispondenti.
    
    if (MainAppDelegate.isForeground && MainAppDelegate.mainSessionManager.isLogged){
        
        if (secsToFiltering == 0 && !myMapView.userLocationVisible)
            [self resizeMap];
        
        if (secsToFiltering > 0){
            secsToFiltering -- ;
            if (secsToFiltering == 0) {
                [self filterTrackingAnnotation];
            }
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
        
        
        // Visulaizza l'ora.
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc]
                                initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit
                                                             | NSMinuteCalendarUnit)
                                                   fromDate:today];
        lblTime.text = [NSString stringWithFormat:@"%2d:%02d", components.hour, components.minute];

        
    }
}


- (void) resizeMap{
    // ridimensiona la mappa

    MKCoordinateRegion region = [MainAppDelegate.mainSessionManager.tracking getFitRegion: myAnnotationFiltered];
    region = [myMapView regionThatFits:region];
    [myMapView setRegion:region animated:YES];

}

- (void) filterTrackingAnnotation{
    
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
        
        myAnnotationFiltered = ![annToShow isEqualToString:@"(0)"];
        if (myAnnotationFiltered)
            [MainAppDelegate.mainSessionManager setAnnotationFilter:annToShow];
        
        [MainAppDelegate.mainSessionManager unlockTracking];
        [MainAppDelegate.mainSessionManager reloadTrackings];
    }
}

#pragma mark - map events

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]){

        return nil;

        mtxMapViewAnnotation *theAnn = [mtxMapViewAnnotation annFromUserLocation:annotation];
        NSString *aIdentifier = [NSString stringWithFormat:@"%@%i",theAnn.codRuolo, theAnn.progressivo];

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
    else if ([annotation isKindOfClass:[mtxMapViewAnnotation class]]){
        // Annotation mtxMapViewAnnotation - handle custom annotations
        
        mtxMapViewAnnotation *theAnn = annotation;
        NSString *aIdentifier = [NSString stringWithFormat:@"%@%i",theAnn.codRuolo, theAnn.progressivo];
        
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
    
    else{
        // other kind of annotation
        return nil;
    }
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

    }

}

@end




