//
//  HudView.h
//  MyLocations
//
//  Created by Weiling Xi on 21/06/2017.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated;

@property (nonatomic, strong) NSString *text;

@end
