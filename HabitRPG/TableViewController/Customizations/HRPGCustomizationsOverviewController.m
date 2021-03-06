//
//  HRPGTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCustomizationsOverviewController.h"
#import "Customization.h"
#import "Gear.h"
#import "HRPGCustomizationCollectionViewController.h"

@interface HRPGCustomizationsOverviewController ()
@property NSString *readableName;
@property NSString *typeName;
@property User *user;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate;
@end

@implementation HRPGCustomizationsOverviewController
Gear *selectedGear;
NSIndexPath *selectedIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [[HRPGManager sharedManager] getUser];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    if (tableSelection) {
        if (tableSelection.section == 1) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[ tableSelection ]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return NSLocalizedString(@"Hair", nil);
    } else {
        return NSLocalizedString(@"Background", nil);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 6;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"SizeCell" forIndexPath:indexPath];
        UISegmentedControl *sizeControl = [cell viewWithTag:1];
        if ([self.user.preferences.size isEqualToString:@"slim"]) {
            [sizeControl setSelectedSegmentIndex:0];
        } else {
            [sizeControl setSelectedSegmentIndex:1];
        }
        return cell;
    }
    NSString *cellName = @"Cell";
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath withAnimation:NO];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return 50;
    }
    return 76;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"purchased == True || price == 0"];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[ typeDescriptor, nameDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    [tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
        withAnimation:(BOOL)animate {
    UILabel *textLabel = [cell viewWithTag:1];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    NSString *searchedKey;
    NSString *typeName;
    NSString *searchedType;
    NSString *searchedGroup;
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            searchedKey = self.user.preferences.size;
            searchedType = @"size";
            typeName = NSLocalizedString(@"Size", nil);
        } else if (indexPath.item == 1) {
            searchedKey = self.user.preferences.shirt;
            searchedType = @"shirt";
            typeName = NSLocalizedString(@"Shirt", nil);
        } else if (indexPath.item == 2) {
            searchedKey = self.user.preferences.skin;
            searchedType = @"skin";
            typeName = NSLocalizedString(@"Skin", nil);
        } else if (indexPath.item == 3) {
            if ([self.user.preferences.useCostume boolValue]) {
                searchedKey = self.user.costume.headAccessory;
            } else {
                searchedKey = self.user.equipped.headAccessory;
            }
            searchedType = @"ear";
            typeName = NSLocalizedString(@"Animal Ears", nil);
        } else if (indexPath.item == 4) {
            searchedKey = self.user.preferences.chair;
            searchedType = @"chair";
            typeName = NSLocalizedString(@"Wheelchair", nil);
        }
    } else if (indexPath.section == 1) {
        searchedType = @"hair";
        if (indexPath.item == 0) {
            searchedGroup = @"color";
            searchedKey = self.user.preferences.hairColor;
            typeName = NSLocalizedString(@"Color", nil);
        } else if (indexPath.item == 1) {
            searchedGroup = @"base";
            searchedKey = self.user.preferences.hairBase;
            typeName = NSLocalizedString(@"Base", nil);
        } else if (indexPath.item == 2) {
            searchedGroup = @"bangs";
            searchedKey = self.user.preferences.hairBangs;
            typeName = NSLocalizedString(@"Bangs", nil);
        } else if (indexPath.item == 3) {
            searchedGroup = @"flower";
            searchedKey = self.user.preferences.hairFlower;
            typeName = NSLocalizedString(@"Flower", nil);
        } else if (indexPath.item == 4) {
            searchedGroup = @"beard";
            searchedKey = self.user.preferences.hairBeard;
            typeName = NSLocalizedString(@"Beard", nil);
        } else if (indexPath.item == 5) {
            searchedGroup = @"mustache";
            searchedKey = self.user.preferences.hairMustache;
            typeName = NSLocalizedString(@"Mustache", nil);
        }
    } else {
        if (indexPath.item == 0) {
            searchedKey = self.user.preferences.background;
            searchedType = @"background";
            typeName = NSLocalizedString(@"Background", nil);
        }
    }

    textLabel.text = typeName;
    UILabel *detailLabel = [cell viewWithTag:2];
    detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UIImageView *imageView = [cell viewWithTag:3];

    if ([searchedType isEqualToString:@"ear"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Gear"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];

        NSPredicate *predicate;
        predicate = [NSPredicate
            predicateWithFormat:@"type == 'headAccessory' && key == %@ && set == 'animal'",
                                searchedKey];
        [fetchRequest setPredicate:predicate];

        NSError *error;
        NSArray *results =
            [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (results.count > 0) {
            Gear *equippedEar = results[0];
            detailLabel.text = equippedEar.text;
            detailLabel.textColor = [UIColor blackColor];
            imageView.contentMode = UIViewContentModeCenter;
            [[HRPGManager sharedManager] setImage:[NSString stringWithFormat:@"shop_%@", equippedEar.key]
                              withFormat:@"png"
                                  onView:imageView];
            imageView.alpha = 1.0;
        } else {
            detailLabel.text = NSLocalizedString(@"Nothing Set", nil);
            detailLabel.textColor = [UIColor grayColor];
            [[HRPGManager sharedManager] setImage:@"head_0" withFormat:@"png" onView:imageView];
            imageView.alpha = 0.4;
        }
    } else {
        Customization *searchedCustomization;
        if (searchedKey && ![searchedKey isEqualToString:@""]) {
            for (Customization *customization in self.fetchedResultsController.fetchedObjects) {
                if ([customization.name isEqualToString:searchedKey] &&
                    [customization.type isEqualToString:searchedType]) {
                    if (searchedGroup) {
                        if (![searchedGroup isEqualToString:customization.group]) {
                            continue;
                        }
                    }
                    searchedCustomization = customization;
                    break;
                }
            }
        }
        if (searchedCustomization && ![searchedCustomization.name isEqualToString:@"0"]) {
            detailLabel.text = [searchedCustomization.name capitalizedString];
            detailLabel.textColor = [UIColor blackColor];
            imageView.contentMode = UIViewContentModeBottomRight;
            [[HRPGManager sharedManager] setImage:[searchedCustomization getImageNameForUser:self.user]
                              withFormat:@"png"
                                  onView:imageView];
            imageView.alpha = 1.0;
        } else {
            detailLabel.text = NSLocalizedString(@"Nothing Set", nil);
            detailLabel.textColor = [UIColor grayColor];
            [[HRPGManager sharedManager] setImage:@"head_0" withFormat:@"png" onView:imageView];
            imageView.alpha = 0.4;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        HRPGCustomizationCollectionViewController *destViewController =
            segue.destinationViewController;
        destViewController.user = self.user;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destViewController.entityName = @"Customization";
        if (indexPath.section == 0) {
            if (indexPath.item == 1) {
                destViewController.userKey = @"preferences.shirt";
                destViewController.type = @"shirt";
            } else if (indexPath.item == 2) {
                destViewController.userKey = @"preferences.skin";
                destViewController.type = @"skin";
            } else if (indexPath.item == 3) {
                destViewController.entityName = @"Gear";
                if ([self.user.preferences.useCostume boolValue]) {
                    destViewController.userKey = @"costume";
                } else {
                    destViewController.userKey = @"equipped";
                }
                destViewController.type = @"ear";
            } else if (indexPath.item == 4) {
                destViewController.userKey = @"preferences.chair";
                destViewController.type = @"chair";
                destViewController.allowUnset = YES;
            }
        } else if (indexPath.section == 1) {
            destViewController.type = @"hair";
            switch (indexPath.item) {
                case 0:
                    destViewController.userKey = @"preferences.hair.color";
                    destViewController.group = @"color";
                    break;
                case 1:
                    destViewController.userKey = @"preferences.hair.base";
                    destViewController.group = @"base";
                    break;
                case 2:
                    destViewController.userKey = @"preferences.hair.bangs";
                    destViewController.group = @"bangs";
                    break;
                case 3:
                    destViewController.userKey = @"preferences.hair.flower";
                    destViewController.group = @"flower";
                    break;
                case 4:
                    destViewController.userKey = @"preferences.hair.beard";
                    destViewController.group = @"beard";
                    break;
                case 5:
                    destViewController.userKey = @"preferences.hair.mustache";
                    destViewController.group = @"mustache";
                    break;

                default:
                    break;
            }
        } else {
            destViewController.userKey = @"preferences.background";
            destViewController.type = @"background";
            destViewController.allowUnset = YES;
        }
    }
}

- (IBAction)userSizeChanged:(UISegmentedControl *)sender {
    NSString *newSize;
    if (sender.selectedSegmentIndex == 0) {
        newSize = @"slim";
    } else {
        newSize = @"broad";
    }

    [[HRPGManager sharedManager] updateUser:@{
        @"preferences.size" : newSize
    }
        onSuccess:nil onError:nil];
}

@end
