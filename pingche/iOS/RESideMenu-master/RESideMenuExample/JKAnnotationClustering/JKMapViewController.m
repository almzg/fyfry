//
//  JKMapViewController.m
//  RESideMenuExample
//
//  Created by Albert Gu on 1/6/14.
//  Copyright (c) 2014 Roman Efimov. All rights reserved.
//

#import "JKMapViewController.h"
#import "JKCoordinateQuadTree.h"
#import "JKClusterAnnotationView.h"
#import "JKClusterAnnotation.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@interface JKMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) JKCoordinateQuadTree *coordinateQuadTree;
@end

@implementation JKMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapView = [[MKMapView alloc] initWithFrame: self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.coordinateQuadTree = [[JKCoordinateQuadTree alloc] init];
    self.coordinateQuadTree.mapView = self.mapView;
    [self.coordinateQuadTree buildTree];
}

- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *const JKAnnotatioViewReuseID = @"JKAnnotatioViewReuseID";
    
    JKClusterAnnotationView *annotationView = (JKClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:JKAnnotatioViewReuseID];
    
    if (!annotationView) {
        annotationView = [[JKClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:JKAnnotatioViewReuseID];
    }
    
    annotationView.canShowCallout = YES;
    annotationView.count = [(JKClusterAnnotation *)annotation count];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}

@end
