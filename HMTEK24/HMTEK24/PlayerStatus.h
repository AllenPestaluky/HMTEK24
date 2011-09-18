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
  NSArray *categories;
  NSString *lastVenueName;
  int zeds;
  int fellowSurvivors;
  int zedsKilled;
  
  int hours;
  int minutes;
  bool isZombie;
}

@property long zombieTime;
@property long lastCheckinTime;
@property (retain) NSString *lastVenueName;
@property NSArray *categories;
@property int zeds;
@property int fellowSurvivors;
@property int zedsKilled;

@property int hours;
@property int minutes;
@property int seconds;
@property bool isZombie;

-(void)fetchMostRecent:(StatusViewController *)controller;

-(void)calcZombieTime:(StatusViewController *)controller withVenue:(NSString *)venueID withCreatedAt:(NSDecimalNumber *)createdAt;
-(void)reset;
-(void)load;
-(void)save;
-(void)getZombieStatus:(StatusViewController *)controller;
-(void)recalcTTL:(StatusViewController *)controller;
-(void)checkinZombie:(StatusViewController *)controller;

@end
