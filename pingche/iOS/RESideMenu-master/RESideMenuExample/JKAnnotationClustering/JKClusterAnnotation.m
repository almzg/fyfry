//
//  JKClusterAnnotation.m
//  RESideMenuExample
//
//  Created by Albert Gu on 1/6/14.
//  Copyright (c) 2014 New Life. All rights reserved.
//

#import "JKClusterAnnotation.h"

@implementation JKClusterAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count
{
    self = [super init];
    
    if (self)
    {
        _coordinate = coordinate;
        _title = [NSString stringWithFormat: @"%d hotels in this area", count];
        _count = count;
    }
    
    return self;
}

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat: @"%.5F%.5F", self.coordinate.latitude, self.coordinate.longitude];
    
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

@end
