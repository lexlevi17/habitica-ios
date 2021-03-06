//
//  HRPGCollectionViewController.m
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCollectionViewController.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Amplitude+HRPGHelpers.h"
#import "Google/Analytics.h"
#import "HRPGManager.h"
#import "HRPGDeathView.h"
#import "Habitica-Swift.h"

@interface HRPGCollectionViewController ()
@end

@implementation HRPGCollectionViewController

- (void)viewDidLoad {
    self.topHeaderCoordinator = [[TopHeaderCoordinator alloc] initWithTopHeaderNavigationController:self.topHeaderNavigationController scrollView:self.collectionView];
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[Amplitude instance] logNavigateEventForClass:NSStringFromClass([self class])];
    
    [self.topHeaderCoordinator viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.topHeaderCoordinator viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.topHeaderCoordinator viewDidAppear];

    User *user = [[HRPGManager sharedManager] getUser];
    if (user && user.health && user.health.floatValue <= 0) {
        [[HRPGDeathView new] show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topHeaderCoordinator viewWillDisappear];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.topHeaderCoordinator scrollViewDidScroll];
}

- (TopHeaderViewController *)topHeaderNavigationController {
    return [self hrpgTopHeaderNavigationController];
}

@end
