//
//  Location+CoreDataProperties.m
//  MyLocations
//
//  Created by Weiling Xi on 22/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Location"];
}

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic category;
@dynamic placemark;

@end
