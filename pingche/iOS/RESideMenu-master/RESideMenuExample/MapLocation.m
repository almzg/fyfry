//
//  MapLocation.m
//  RESideMenuExample
//
//  Created by Albert Gu on 1/5/14.
//  Copyright (c) 2014 Roman Efimov. All rights reserved.
//

#import "MapLocation.h"

@implementation MapLocation

- (NSString *)title
{
    return @"[您的位置]";
}

- (NSString *)subtitle
{
    NSMutableString *subtitle = [NSMutableString new];
    
    if (_state) {
        [subtitle appendString: _state];
    }
    
    if (_city) {
        [subtitle appendString: _city];
    }
    
    if (_city && _state) {
        [subtitle appendString: @","];
    }
    
    if (_street) {
        [subtitle appendString: _street];
    }
    
    if (_zip) {
        [subtitle appendFormat: @", %@", _zip];
    }
    
    return subtitle;
}

@end
