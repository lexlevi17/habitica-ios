//
//  Gear.h
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "User.h"

@interface Gear : NSManagedObject

@property(nonatomic, retain) NSNumber *con;
@property(nonatomic, retain) NSNumber *index;
@property(nonatomic, retain) NSNumber *intelligence;
@property(nonatomic, retain, getter=getCleanedClassName) NSString *klass;
@property(nonatomic, retain) NSNumber *per;
@property(nonatomic, retain) NSNumber *str;
@property(nonatomic) BOOL owned;
@property(nonatomic) NSDate *eventStart;
@property(nonatomic) NSDate *eventEnd;
@property(nonatomic) NSString *specialClass;
@property(nonatomic) NSString *set;
@property(nonatomic) NSString *key;
@property(nonatomic) NSString *text;
@property(nonatomic) NSString *notes;
@property(nonatomic) NSString *type;
@property(nonatomic) NSNumber *value;


- (BOOL)isEquippedBy:(User *)user;
- (BOOL)isCostumeOf:(User *)user;

- (NSString *)statsText;
@end
