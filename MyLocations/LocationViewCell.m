//
//  LocationViewCell.m
//  MyLocations
//
//  Created by Weiling Xi on 26/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "LocationViewCell.h"

@implementation LocationViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInternalFields:(Location *)incomingLocationEntity {
    
    CLPlacemark *placemark = incomingLocationEntity.placemark;

    NSString *title = placemark.areasOfInterest.firstObject.description;
    
    if(title == nil) {
        
        if(incomingLocationEntity.locationDescription != nil){
            self.locationLabel.text = incomingLocationEntity.locationDescription;
        }else{
            self.locationLabel.text = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare,placemark.thoroughfare];
        }
        
    } else {
        self.locationLabel.text = title;
    }
    
    
    self.addressLabel.text = [self stringFromPlacemark:placemark];
}

- (NSString *)stringFromPlacemark: (CLPlacemark *)thePlacemark {
    
    return [NSString stringWithFormat:@"%@ %@, %@, %@", thePlacemark.subThoroughfare,thePlacemark.thoroughfare,thePlacemark.locality,thePlacemark.administrativeArea];
    
}

@end
