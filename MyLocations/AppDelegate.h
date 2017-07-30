//
//  AppDelegate.h
//  MyLocations
//
//  Created by Weiling Xi on 19/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end
