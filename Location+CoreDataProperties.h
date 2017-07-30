//
//  Location+CoreDataProperties.h
//  MyLocations
//
//  Created by Weiling Xi on 22/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "Location+CoreDataClass.h"
#import <CoreLocation/CoreLocation.h>


NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *locationDescription;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, retain) CLPlacemark *placemark;

@end

NS_ASSUME_NONNULL_END
