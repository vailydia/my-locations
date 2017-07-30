//
//  LocationViewCell.h
//  MyLocations
//
//  Created by Weiling Xi on 26/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location+CoreDataClass.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) Location *locationEntity;

- (void) setInternalFields: (Location *)incomingLocationEntity;

@end
