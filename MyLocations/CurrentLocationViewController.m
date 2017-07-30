//
//  FirstViewController.m
//  MyLocations
//
//  Created by Weiling Xi on 19/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailsViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController {
    
    CLLocationManager *_locationManager;
    
    CLLocation *_location;
    
    BOOL _updatingLocation;
    
    NSError *_lastLocationError;
    
    //Geocoding
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeocoding;
    NSError *_lastGeocodingError;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if((self = [super initWithCoder:aDecoder])) {
        
        _locationManager = [[CLLocationManager alloc] init];
        
        _geocoder = [[CLGeocoder alloc] init];
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self updateLabels];
    
    [self configureGetButton];
    
}



- (IBAction)getLocation:(id)sender {
    
    if(_updatingLocation) {
        
        [self stopLocationManager];
        
    } else {
        
        _location = nil;
        
        _lastLocationError = nil;
        
        _placemark = nil;
        
        _lastGeocodingError = nil;
        
        [self startLocationManager];
        
    }
    
    [self updateLabels];
    
    [self configureGetButton];
    
}


- (void)updateLabels {
    
    if(_location != nil) {
        
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _location.coordinate.latitude];
        
        self.longtitudeLabel.text = [NSString stringWithFormat:@"%.8f", _location.coordinate.longitude];
        
        self.tagButton.hidden = NO;
        
        self.messsageLabel.text = @"";
        
        if(_placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark:_placemark];
        } else if(_performingReverseGeocoding) {
            self.addressLabel.text = @"Searching...";
        } else if(_lastGeocodingError != nil) {
            self.addressLabel.text = @"Error found in geocoding.";
        } else {
            self.addressLabel.text = @"Nothing found in this area.";
        }
        
    } else {
        
        self.latitudeLabel.text = @"";
        
        self.longtitudeLabel.text = @"";
        
        self.addressLabel.text = @"";
        
        self.tagButton.hidden = YES;
        
        //when error
        NSString *statusMessage;
        
        if(_lastLocationError != nil) {
            
            if([_lastLocationError.domain isEqualToString:kCLErrorDomain] && _lastLocationError.code == kCLErrorDenied) {
                
                statusMessage = @"Sorry, the location service was denied by the user";
                
            } else {
                
                statusMessage = @"Sorry, error when get the location info";
                
            }
            
        } else if(![CLLocationManager locationServicesEnabled]) {
            
            statusMessage = @"Sorry, the location service was denied by the use";
            
        } else if(_updatingLocation) {
            
            statusMessage = @"Get location ...";
            
        } else {
            
            statusMessage = @"Press the Button to Start";
            
        }
        
        self.messsageLabel.text = statusMessage;
        
    }
    
}

- (NSString *)stringFromPlacemark: (CLPlacemark *)thePlacemark {
    
    return [NSString stringWithFormat:@"%@\n%@ %@\n%@ %@ %@", thePlacemark.areasOfInterest.firstObject.description, thePlacemark.subThoroughfare,thePlacemark.thoroughfare,thePlacemark.locality,thePlacemark.administrativeArea,thePlacemark.postalCode];
    
}

- (void)didTimeOut {
    
    NSLog(@"Oops, time out...");
    
    if(_location == nil) {
        [self stopLocationManager];
        _lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        [self updateLabels];
        [self configureGetButton];
        
    }
    
}


- (void)startLocationManager {
    
    if([CLLocationManager locationServicesEnabled]) {
        
        _locationManager.delegate = self;
        
        if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        [_locationManager startUpdatingLocation];
        
        _updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut) withObject:nil afterDelay:60];
        
    }
    
}


- (void)stopLocationManager {
    
    if(_updatingLocation) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut) object:nil];
        
        [_locationManager stopUpdatingLocation];
        
        _locationManager.delegate = nil;
        
        _updatingLocation = NO;
        
    }
    
}

- (void)configureGetButton {
    
    if(_updatingLocation) {
        
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
        
    } else {
        
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
        
    }
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Get location failed: %@.", error);
    
    if(error.code == kCLErrorLocationUnknown) {
        
        return;
        
    }
    
    [self stopLocationManager];
    
    _lastLocationError = error;
    
    [self updateLabels];
    
    [self configureGetButton];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"Get location succeed: %@.", newLocation);
    
    if([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if(newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    
    if(_location != nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    //if has got location data,
    if(_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        if(newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            
            NSLog(@"Get the accurate location!");
            [self stopLocationManager];
            
            [self configureGetButton];
            
            NSLog(@"%f",distance);
            if(distance > 0) {
                _performingReverseGeocoding = NO;
            }
        }
        
        
        //perform reverseGeocoding
        if(!_performingReverseGeocoding) {
            
            NSLog(@"Going to reverseGeocoding...");
            _performingReverseGeocoding = YES;
            
            [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                
                _lastLocationError = error;
                
                if(error == nil && [placemarks count] > 0) {
                    _placemark = placemarks.lastObject;
                } else {
                    _placemark = nil;
                }
                
                _performingReverseGeocoding = NO;
                [self updateLabels];
                
            }];

        }
        
    } else if(distance < 1.0) {
        
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if(timeInterval > 10) {
            
            NSLog(@"Force stop!");
            [self stopLocationManager];
            [self updateLabels];
            [self configureGetButton];
            
        }
        
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"TagLocation"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        
        controller.coordinate = _location.coordinate;
        controller.placemark = _placemark;
        
        controller.managedObjectContext = self.managedObjectContext;
        
    }
    
}


@end






