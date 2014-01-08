//
//  MapLocation.h
//  RESideMenuExample
//
//  Created by Albert Gu on 1/5/14.
//  Copyright (c) 2014 Roman Efimov. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface MapLocation : NSObject<MKAnnotation>

@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end
