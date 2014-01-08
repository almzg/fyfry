//
//  JKCoordinateQuadTree.h
//  RESideMenuExample
//
//  Created by Albert Gu on 1/6/14.
//  Copyright (c) 2014 New Life. All rights reserved.
//

#import "JKQuadTree.h"
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface JKCoordinateQuadTree : NSObject

@property (nonatomic, assign) JKQuadTreeNode* root;
@property (nonatomic, strong) MKMapView *mapView;

- (void)buildTree;
- (NSArray *)clusteredAnnotationsWithinMapRect: (MKMapRect)rect withZoomScale: (double)zoomScale;

@end
