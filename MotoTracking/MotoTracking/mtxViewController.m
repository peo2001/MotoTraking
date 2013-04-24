//
//  mtxViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 16/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxViewController.h"

@interface mtxViewController ()

@end

@implementation mtxViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // use the right mapview depending on the device used
    NSLog(@"Device model:%@", [[UIDevice currentDevice] model]);
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"])
    {
        myMapView = self.iPadMapView;
        lblGara = [[UILabel alloc]init];
    }else
    {
        myMapView = self.iPhoneMapView;
        lblGara = self.iPhoneLblGara;
    }
    myMapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
    myMapView.showsUserLocation = YES;
    myMapView.userTrackingMode = MKUserTrackingModeNone;
    
    // add a wildcard gesture recognizer to intercept resizing of mapview
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(yourmethod)];
    [pinch setDelegate:self];
    [pinch setDelaysTouchesBegan:YES];
    [myMapView addGestureRecognizer:pinch];
    
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
-(void)sessionManager:(mtxSessionManager *)sessionManager startTracking:(mtxLoggedUser *)theLoggedUser{
    
    lblGara.text = theLoggedUser.gara;
    lockMapResize = FALSE;

}

-(void)sessionManager:(mtxSessionManager *)sessionManager didNewTrackingReceived:(NSMutableArray *)annotations{
    [myMapView addAnnotations:(NSArray *) annotations];
    
    MKCoordinateRegion region = sessionManager.getTracking.getFitRegion;
    
    if (!lockMapResize){
        region = [myMapView regionThatFits:region];
        [myMapView setRegion:region animated:YES];
    }

}

#pragma - mark Map Events

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    lockMapResize = TRUE;
    return TRUE;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle custom annotations
    //
    if ([annotation isKindOfClass:[mtxMapViewAnnotation class]])   // Annotation di mark
    {
        static NSString* SFAnnotationIdentifier = @"MarkAnnId";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[myMapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SFAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            // setup image for the map
            annotationView.image = [(mtxMapViewAnnotation *)annotation GetImage:self.view.bounds FrameHeight:self.navigationController.navigationBar.frame.size.height];
            annotationView.opaque = NO;
            
            return annotationView;
        }
        else
        {
            pinView.image = [(mtxMapViewAnnotation *)annotation GetImage:self.view.bounds FrameHeight:self.navigationController.navigationBar.frame.size.height];
            pinView.annotation = annotation;
            return pinView;
        }
    }
    
    return nil;
}



@end
