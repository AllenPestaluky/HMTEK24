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
  NSString *category1;
  NSString *category2;
  NSString *category3;
  NSString *category4;
  NSString *lastVenueName;
  NSString *zombifiedVenue;
  int zeds;
  int fellowSurvivors;
  int zedsKilled;
  
  NSString *playerName;
  NSString *playerIcon;
  int hours;
  int minutes;
  int seconds;
  bool isZombie;
}

@property long zombieTime;
@property long lastCheckinTime;
@property (retain) NSString *lastVenueName;
@property (retain) NSString *category1;
@property (retain) NSString *category2;
@property (retain) NSString *category3;
@property (retain) NSString *category4;
@property (retain) NSString *zombifiedVenue;
@property int zeds;
@property int fellowSurvivors;
@property int zedsKilled;

@property (retain) NSString *playerName;
@property (retain) NSString *playerIcon;
@property int hours;
@property int minutes;
@property int seconds;
@property bool isZombie;

- (id)initWithStatusViewController: (StatusViewController*) viewController;

-(void)fetchMostRecent:(StatusViewController *)controller;
- (void) processMostRecent:(StatusViewController *)controller checkin:(NSDictionary *)checkin;

-(void)calcZombieTime:(StatusViewController *)controller withVenue:(NSString *)venueID withCreatedAt:(NSDecimalNumber *)createdAt;
-(void)reset;
- (void) loadWithViewController: (StatusViewController*) viewController;
-(void)save;
-(void)getZombieStatus:(StatusViewController *)controller;
- (void) recalcTTL:(StatusViewController *)controller fastRefresh: (BOOL) fastRefresh;
-(void)checkin:(StatusViewController *)controller;
-(void)checkinHuman:(StatusViewController *)controller;
-(void)checkinZombie:(StatusViewController *)controller;

@end
