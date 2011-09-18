//
//  PlayerStatus.m
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import "PlayerStatus.h"
#import "Foursquare2.h"
#import "FoursquareCheckinList.h"

@implementation PlayerStatus

@synthesize zombieTime;
@synthesize lastCheckinTime;
@synthesize isZombie;
@synthesize hours;
@synthesize minutes;
@synthesize seconds;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
      [self load];
    }
    
    return self;
}

- (void) reset {
  isZombie = NO;
  zombieTime = 0;
  lastCheckinTime = 0;
  categories = nil;
}

- (void) load {
  [self reset];
  NSUserDefaults *usDef = [NSUserDefaults standardUserDefaults];
	if ([usDef integerForKey:@"last_checkin_time"] != 0) {
    lastCheckinTime = [usDef integerForKey:@"last_checkin_time"];
  }
	if ([usDef integerForKey:@"zombie_time"] != 0) {
    zombieTime = [usDef integerForKey:@"zombie_time"];
  }
  if ([usDef objectForKey:@"zombie_categories"] != nil) {
    categories = (NSArray *)[usDef objectForKey:@"zombie_categories"];
  }
  [self getZombieStatus:nil];
}

- (void) save {
	[[NSUserDefaults standardUserDefaults]setInteger:lastCheckinTime forKey:@"last_checkin_time"];
	[[NSUserDefaults standardUserDefaults]setInteger:zombieTime forKey:@"zombie_time"];
  [[NSUserDefaults standardUserDefaults]setObject:categories forKey:@"zombie_categories"];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) fetchMostRecent:(StatusViewController *)controller {
  [Foursquare2 getDetailForUser: @"self" callback:^(BOOL success, id result) {
    if (success) {
      NSDictionary *user = (NSDictionary*)[(NSDictionary*)
                                           [(NSDictionary*)result valueForKey:@"response"]
                                           valueForKey:@"user"];
      NSDictionary *mostRecent = (NSDictionary*)[(NSArray*)
                                                 [(NSDictionary*)
                                                  [user valueForKey:@"checkins"]
                                                  valueForKey:@"items"]
                                                 objectAtIndex:0];
      
      NSDecimalNumber *createdAt = (NSDecimalNumber*)[mostRecent valueForKey:@"createdAt"];
      NSString *venueID = (NSString*)[(NSDictionary*)[mostRecent valueForKey:@"venue"] valueForKey:@"id"];
      
      if (lastCheckinTime == [createdAt longValue]) {
        [self recalcTTL:controller];
      } else {
        [self calcZombieTime:controller withVenue:venueID withCreatedAt:createdAt];
      }
    }
  }];
}

- (void) calcZombieTime:(StatusViewController *)controller withVenue:(NSString *)venueID withCreatedAt:(NSDecimalNumber *)createdAt {
  [Foursquare2 getDetailForVenue:venueID callback:^(BOOL success, id result) {
    if (success) {
      NSDictionary *venue = (NSDictionary*)[(NSDictionary*)
                                            [(NSDictionary*)result valueForKey:@"response"]
                                            valueForKey:@"venue"];
      // zeds = all users ever checked in
      NSDecimalNumber *zeds = (NSDecimalNumber*)[(NSDictionary*)
                                                 [venue valueForKey:@"stats"]
                                                 valueForKey:@"usersCount"];
      // survivors = all users here now
      NSDecimalNumber *survivors = [(NSDecimalNumber*)[(NSDictionary*)
                                                       [venue valueForKey:@"hereNow"]
                                                       valueForKey:@"count"] decimalNumberByAdding:[NSDecimalNumber one]];
      // kills = your check-ins * survivors (as multiplier bonus)
      NSDecimalNumber *kills = [(NSDecimalNumber*)[(NSDictionary*)
                                                   [venue valueForKey:@"beenHere"]
                                                   valueForKey:@"count"] decimalNumberByMultiplyingBy:survivors];
      
      NSDecimalNumber *hour = [NSDecimalNumber decimalNumberWithString:@"3600"];
      // max hours right now is 18.
      NSDecimalNumber *maxHoursMinusOne = [hour decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"17"]];
      
      // remaining
      NSDecimalNumber *remain = [hour decimalNumberByAdding:[maxHoursMinusOne decimalNumberByMultiplyingBy:[kills decimalNumberByDividingBy:zeds]]];
      
      if ([remain compare:maxHoursMinusOne] > 0) {
        remain = [maxHoursMinusOne copy];
      }
      
      zombieTime = [[createdAt decimalNumberByAdding:remain] longValue];
      lastCheckinTime = [createdAt longValue];
      
      [self performSelectorOnMainThread:@selector(save) withObject:nil waitUntilDone:YES];
      //[self save];
      [self recalcTTL:controller];
    }
  }];
}

- (void) getZombieStatus:(StatusViewController *)controller {
  if (zombieTime == 0) {
    if (![Foursquare2 isNeedToAuthorize]) {
      [self fetchMostRecent:controller];
    }
  } else {
    [self recalcTTL:controller];
  }
}

- (void) recalcTTL:(StatusViewController *)controller {
  long now = [[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] decimalValue]] longValue];
  
  int diff = zombieTime - now;
  
  if (diff < 0) {
    isZombie = YES;
  } else {
    isZombie = NO;
    
    hours = diff / 3600;
    minutes = (diff - hours*3600) / 60;
    seconds = (diff - hours*3600 - minutes*60);
  }
  
  if (controller != nil) {
    [controller refreshStatusView];
  }
}

- (void) checkinZombie:(StatusViewController *)controller {
  [FoursquareCheckinList showCheckin:controller shoutList:nil callback:^(BOOL success, id result) {
    if (success) {
      // Do something.
    }
  }];
}

@end
