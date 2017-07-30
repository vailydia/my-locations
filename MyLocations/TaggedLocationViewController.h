//
//  SecondViewController.h
//  MyLocations
//
//  Created by Weiling Xi on 19/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location+CoreDataClass.h"
#import "LocationViewCell.h"
#import "MyLocationTableViewController.h"

@interface TaggedLocationViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

