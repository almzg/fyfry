//
//  MapViewController.m
//  RESideMenuExample
//
//  Created by Albert Gu on 1/5/14.
//  Copyright (c) 2014 Roman Efimov. All rights reserved.
//

#import "MapViewController.h"
#import "MapLocation.h"
#import "AppDelegate.h"
#import "GPSEntity.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreData/CoreData.h>

@interface MapViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currLocation;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10000.0f;
    
    _mapView = [[MKMapView alloc] initWithFrame: self.view.bounds];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    [self.view addSubview: _mapView];
    
    [_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [_locationManager startUpdatingLocation];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    [_locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currLocation = [locations lastObject];
    CLLocationCoordinate2D coordinate = [self zzTransGPS: currLocation.coordinate];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    [_mapView setRegion: viewRegion animated: NO];
    _mapView.centerCoordinate = coordinate;
    
    MapLocation *annotation = [[MapLocation alloc] init];
    annotation.coordinate = coordinate;
    [_mapView addAnnotation: annotation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier: @"PIN_ANNOTATION"];
    
    if (nil == annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"PIN_ANNOTATION"];
    }
    
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

#pragma mark -
#pragma mark - helper
-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
//    int TenLat=0;
//    int TenLog=0;
//    TenLat = (int)(yGps.latitude*10);
//    TenLog = (int)(yGps.longitude*10);
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"latitude == %d AND longitude == %d", TenLat, TenLog];
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"GPSEntity"];
//    request.predicate = predicate;
//    
//    NSArray *results = [self.managedObjectContext executeFetchRequest: request error: nil];
//    NSLog(@"results: %@", results);
//    
//    int offLat=0;
//    int offLog=0;
//    
//    if (results && results.count > 0)
//    {
//        GPSEntity *gps = [results lastObject];
//        offLat = [gps.offLatitude intValue];
//        offLog = [gps.offLongitude intValue];
//    }
//    
//    yGps.latitude = yGps.latitude+offLat*0.0001;
//    yGps.longitude = yGps.longitude + offLog*0.0001;
//    
    return yGps;
}

@end
