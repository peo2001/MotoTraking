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
    }else
    {
        myMapView = self.iPhoneMapView;
    }
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set some coordinates for our position (Buckingham Palace!)
	CLLocationCoordinate2D location;
	location.latitude = (double) 51.501468;
	location.longitude = (double) -0.141596;
    
	// Add the annotation to our map view
	mtxMapViewAnnotation *newAnnotation = [[mtxMapViewAnnotation alloc] initWithCode:@"AM1" Coordinate:location];
    
	[myMapView addAnnotation:newAnnotation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    NSLog(@"Map Loaded");
}


#pragma - mark Map Events
// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
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
