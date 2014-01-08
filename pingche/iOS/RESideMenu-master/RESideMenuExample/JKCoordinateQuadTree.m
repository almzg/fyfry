//
//  JKCoordinateQuadTree.m
//  RESideMenuExample
//
//  Created by Albert Gu on 1/6/14.
//  Copyright (c) 2014 New Life. All rights reserved.
//

#import "JKCoordinateQuadTree.h"
#import "JKClusterAnnotation.h"

typedef struct JKHotelInfo
{
    char* hotelName;
    char* hotelPhoneNumber;
}JKHotelInfo;

JKQuadTreeNodeData JKDataFromLine(NSString *line)
{
    NSArray *componets = [line componentsSeparatedByString: @","];
    double latitude = [componets[1] doubleValue];
    double longitude = [componets[0] doubleValue];
    
    JKHotelInfo* hotelInfo = malloc(sizeof(JKHotelInfo));
    
    NSString *hotelName = [componets[2] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelName = malloc(sizeof(char) * hotelName.length + 1);
    strncpy(hotelInfo->hotelName, [hotelName UTF8String], hotelName.length + 1);
    
    NSString *hotelPhoneNumber = [[componets lastObject] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelPhoneNumber = malloc(sizeof(char) * hotelPhoneNumber.length + 1);
    strncpy(hotelInfo->hotelPhoneNumber, [hotelPhoneNumber UTF8String], hotelPhoneNumber.length + 1);
    
    return JKQuadTreeNodeDataMake(latitude, longitude, hotelInfo);
}

JKBoundingBox JKBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D bottomRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = bottomRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = bottomRight.longitude;
    
    return JKBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect JKMapRectForBoundingBox(JKBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xMin, boundingBox.yMin));
    MKMapPoint bottomRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xMax, boundingBox.yMax));
    
    return MKMapRectMake(topLeft.x, bottomRight.y, fabs(bottomRight.x - topLeft.x), fabs(bottomRight.y - topLeft.y));
}

NSInteger JKZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
    
    return zoomLevel;
}

float JKCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = JKZoomScaleToZoomLevel(zoomScale);
    
    switch (zoomLevel)
    {
        case 13:
        case 14:
        case 15:
            return 64;
            
        case 16:
        case 17:
        case 18:
            return 32;
        
        case 19:
            return 16;
            
        default:
            return 88;
    }
}

@implementation JKCoordinateQuadTree

- (void)buildTree
{
    @autoreleasepool
    {
        NSString *data = [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"USA-HotelMotel" ofType: @"csv"] encoding: NSASCIIStringEncoding error: nil];
        NSArray *lines = [data componentsSeparatedByString: @"\n"];
        
        NSInteger count = lines.count - 1;
        
        JKQuadTreeNodeData *dataArray = malloc(sizeof(JKQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++)
        {
            dataArray[i] = JKDataFromLine(lines[i]);
        }
        
        JKBoundingBox world = JKBoundingBoxMake(19, -166, 72, -53);
        
        _root = JKQuadTreeBuildWithData(dataArray, count, world, 4);
    }
}

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double JKCellSize = JKCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / JKCellSize;
    
    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    for (NSInteger x = minX; x <= maxX; x++)
    {
        for (NSInteger y = minY; y <= maxY; y++)
        {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            
            NSMutableArray *names = [[NSMutableArray alloc] init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            JKQuadTreeGatherDataInRange(self.root, JKBoundingBoxForMapRect(mapRect), ^(JKQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;
                
                JKHotelInfo hotelInfo = *(JKHotelInfo *)data.data;
                [names addObject: [NSString stringWithFormat: @"%s", hotelInfo.hotelName]];
                [phoneNumbers addObject: [NSString stringWithFormat: @"%s", hotelInfo.hotelPhoneNumber]];
            });
            
            if (count == 1)
            {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                JKClusterAnnotation *annotation = [[JKClusterAnnotation alloc] initWithCoordinate: coordinate count: count];
                annotation.title = [names lastObject];
                annotation.subtitle = [phoneNumbers lastObject];
                [clusteredAnnotations addObject: annotation];
            }
            
            if (count > 1)
            {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                JKClusterAnnotation *annotation = [[JKClusterAnnotation alloc] initWithCoordinate: coordinate count: count];
                [clusteredAnnotations addObject: annotation];
            }
        }
    }
    
    return [NSArray arrayWithArray: clusteredAnnotations];
}

@end
