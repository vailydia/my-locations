//
//  MyLocationTableViewController.h
//  MyLocations
//
//  Created by Weiling Xi on 26/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location+CoreDataClass.h"
#import "MyCollectionViewCell.h"

@interface MyLocationTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Location *location;

@end
