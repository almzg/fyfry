//
//  GPSEntity.h
//  TestGPS
//
//  Created by Albert Gu on 1/5/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GPSEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * mark;
@property (nonatomic, retain) NSNumber * offLatitude;
@property (nonatomic, retain) NSNumber * offLongitude;

@end
