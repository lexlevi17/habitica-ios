//
//  HRPGGroupAboutTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 16/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "HRPGBaseViewController.h"

@interface HRPGGroupAboutTableViewController : HRPGBaseViewController

@property Group *group;
@property BOOL isLeader;

@end
