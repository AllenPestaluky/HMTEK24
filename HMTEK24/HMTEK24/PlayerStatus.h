//
//  PlayerStatus.h
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatusViewController.h"

@interface PlayerStatus : NSObject {
  long zombieTime;
  int hours;
  int minutes;
  bool isZombie;
  NSArray *categories;
}

@property long zombieTime;
@property long lastCheckinTime;
@property int hours;
@property int minutes;
@property int seconds;
@property bool isZombie;
@property NSArray *categories;

-(void)fetchMostRecent:(StatusViewController *)controller;

-(void)calcZombieTime:(StatusViewController *)controller withVenue:(NSString *)venueID withCreatedAt:(NSDecimalNumber *)createdAt;
-(void)reset;
-(void)load;
-(void)save;
-(void)getZombieStatus:(StatusViewController *)controller;
-(void)recalcTTL:(StatusViewController *)controller;
-(void)checkinZombie:(StatusViewController *)controller;

@end
