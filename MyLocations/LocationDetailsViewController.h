//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Weiling Xi on 20/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationDetailsViewController : UITableViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
