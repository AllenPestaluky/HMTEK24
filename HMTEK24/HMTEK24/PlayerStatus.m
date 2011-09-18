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
@synthesize lastVenueName;
@synthesize lastCheckinTime;
@synthesize zeds;
@synthesize fellowSurvivors;
@synthesize zedsKilled;
@synthesize zombifiedVenue;

@synthesize category1;
@synthesize category2;
@synthesize category3;
@synthesize category4;

@synthesize playerName;
@synthesize playerIcon;

@synthesize isZombie;
@synthesize hours;
@synthesize minutes;
@synthesize seconds;

- (id)initWithStatusViewController: (StatusViewController*) viewController
{
    self = [super init];
    if (self) {
        // Initialization code here.
      [self loadWithViewController: viewController];
    }
    
    return self;
}

- (void) reset {
  isZombie = NO;
  zombieTime = 0;
  lastCheckinTime = 0;
  zeds = 0;
  fellowSurvivors = 0;
  zedsKilled = 0;
  self.lastVenueName = nil;
  self.category1 = nil;
  self.category2 = nil;
  self.category3 = nil;
  self.category4 = nil;
}

- (void) loadWithViewController: (StatusViewController*) viewController {
  [self reset];
  NSUserDefaults *usDef = [NSUserDefaults standardUserDefaults];
  if ([usDef objectForKey:@"player_name"] != nil) {
    self.playerName = (NSString *)[usDef objectForKey:@"player_name"];
    self.playerIcon = (NSString *)[usDef objectForKey:@"player_icon"];
  }
	if ([usDef integerForKey:@"last_checkin_time"] != 0) {
    lastCheckinTime = [usDef integerForKey:@"last_checkin_time"];
    self.lastVenueName = [usDef objectForKey:@"last_venue_name"];
    zombieTime = [usDef integerForKey:@"zombie_time"];
    zeds = [usDef integerForKey:@"zeds"];
    fellowSurvivors = [usDef integerForKey:@"fellow_survivors"];
    zedsKilled = [usDef integerForKey:@"zeds_killed"];
  }
  if ([usDef objectForKey:@"zombie_categories"] != nil) {
    self.category1 = (NSString *)[usDef objectForKey:@"zombie_category1"];
    self.category2 = (NSString *)[usDef objectForKey:@"zombie_category2"];
    self.category3 = (NSString *)[usDef objectForKey:@"zombie_category3"];
    self.category4 = (NSString *)[usDef objectForKey:@"zombie_category4"];    
  }
  if (![Foursquare2 isNeedToAuthorize]) {
    [self fetchMostRecent:viewController];
  }
}

- (void) save {
  [[NSUserDefaults standardUserDefaults]setObject:playerName forKey:@"player_name"];
  [[NSUserDefaults standardUserDefaults]setObject:playerIcon forKey:@"player_icon"];
  
	[[NSUserDefaults standardUserDefaults]setInteger:lastCheckinTime forKey:@"last_checkin_time"];
  [[NSUserDefaults standardUserDefaults]setObject:lastVenueName forKey:@"last_venue_name"];
	[[NSUserDefaults standardUserDefaults]setInteger:zombieTime forKey:@"zombie_time"];
  [[NSUserDefaults standardUserDefaults]setInteger:zeds forKey:@"zeds"];
  [[NSUserDefaults standardUserDefaults]setInteger:fellowSurvivors forKey:@"fellow_survivors"];
  [[NSUserDefaults standardUserDefaults]setInteger:zedsKilled forKey:@"zeds_killed"];

  [[NSUserDefaults standardUserDefaults]setObject:category1 forKey:@"zombie_category1"];
  [[NSUserDefaults standardUserDefaults]setObject:category2 forKey:@"zombie_category2"];
  [[NSUserDefaults standardUserDefaults]setObject:category3 forKey:@"zombie_category3"];  
  [[NSUserDefaults standardUserDefaults]setObject:category4 forKey:@"zombie_category4"];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) fetchMostRecent:(StatusViewController *)controller {
  [Foursquare2 getDetailForUser: @"self" callback:^(BOOL success, id result) {
    if (success) {
      NSDictionary *user = (NSDictionary*)[(NSDictionary*)
                                           [(NSDictionary*)result valueForKey:@"response"]
                                           valueForKey:@"user"];
      self.playerName = [NSString stringWithFormat:@"%@ %@", (NSString *)[user valueForKey:@"firstName"], (NSString *)[user valueForKey:@"lastName"]];
      self.playerIcon = [user valueForKey:@"photo"];
      
      NSDictionary *mostRecent = (NSDictionary*)[(NSArray*)
                                                 [(NSDictionary*)
                                                  [user valueForKey:@"checkins"]
                                                  valueForKey:@"items"]
                                                 objectAtIndex:0];
      
      [self processMostRecent:controller checkin:mostRecent];
    }
  }];
}

- (void) processMostRecent:(StatusViewController *)controller checkin:(NSDictionary *)checkin {
  NSDecimalNumber *createdAt = (NSDecimalNumber*)[checkin valueForKey:@"createdAt"];
  NSString *venueID = (NSString*)[(NSDictionary*)[checkin valueForKey:@"venue"] valueForKey:@"id"];
  self.lastVenueName = [(NSDictionary*)[checkin valueForKey:@"venue"] valueForKey:@"name"];
  
  if (lastCheckinTime == [createdAt longValue]) {
    [self recalcTTL:controller fastRefresh: NO];
  } else {
    [self calcZombieTime:controller withVenue:venueID withCreatedAt:createdAt];
  }
}

- (void) calcZombieTime:(StatusViewController *)controller withVenue:(NSString *)venueID withCreatedAt:(NSDecimalNumber *)createdAt {
  [Foursquare2 getDetailForVenue:venueID callback:^(BOOL success, id result) {
    if (success) {
      NSDictionary *venue = (NSDictionary*)[(NSDictionary*)
                                            [(NSDictionary*)result valueForKey:@"response"]
                                            valueForKey:@"venue"];
      // zeds = all users ever checked in
      NSDecimalNumber *zedsHere = (NSDecimalNumber*)[(NSDictionary*)
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
      if ([kills compare:zedsHere] > 0) {
        kills = [zedsHere copy];
      }
      
      NSDecimalNumber *hour = [NSDecimalNumber decimalNumberWithString:@"3600"];
      // max hours right now is 18.
      NSDecimalNumber *maxHoursMinusOne = [hour decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"17"]];
      
      // remaining
      NSDecimalNumber *remain = [hour decimalNumberByAdding:[maxHoursMinusOne decimalNumberByMultiplyingBy:[kills decimalNumberByDividingBy:zedsHere]]];
      
      if ([remain compare:maxHoursMinusOne] > 0) {
        remain = [maxHoursMinusOne copy];
      }
      
      zombieTime = [[createdAt decimalNumberByAdding:[remain decimalNumberByAdding:hour]] longValue];
      lastCheckinTime = [createdAt longValue];
      zeds = [zedsHere intValue];
      fellowSurvivors = [survivors intValue];
      zedsKilled = [kills intValue];
      
      
      [self performSelectorOnMainThread:@selector(save) withObject:nil waitUntilDone:YES];
      //[self save];
      [self recalcTTL:controller fastRefresh: NO];
    }
  }];
}

- (void) getZombieStatus:(StatusViewController *)controller {
  if (zombieTime == 0) {
    if (![Foursquare2 isNeedToAuthorize]) {
      [self fetchMostRecent:controller];
    }
  } else {
    [self recalcTTL:controller fastRefresh: NO];
  }
}

- (void) recalcTTL:(StatusViewController *)controller fastRefresh: (BOOL) fastRefresh {
  long now = [[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] decimalValue]] longValue];
  
  int diff = zombieTime - now;
  
  if (diff < 0) {
    isZombie = YES;
    if (zombifiedVenue == nil) {
      self.zombifiedVenue = [lastVenueName copy];
    }
  }
  
  if (!isZombie) {
    self.zombifiedVenue = nil;
    self.category1 = nil;
    self.category2 = nil;
    self.category3 = nil;
    self.category4 = nil;
    
    isZombie = NO;
    
    hours = diff / 3600;
    minutes = (diff - hours*3600) / 60;
    seconds = (diff - hours*3600 - minutes*60);
  }
  
  if (controller != nil) {
    [controller refreshStatusView: fastRefresh];
  }
}

- (void) checkin:(StatusViewController *)controller {
  [self recalcTTL:nil fastRefresh: NO];
  
  if (isZombie) {
    [self checkinZombie:controller];
  } else {
    [self checkinHuman:controller];
  }
}

- (void) checkinHuman:(StatusViewController *)controller {
  [FoursquareCheckinList showCheckin:controller shoutList:nil callback:^(BOOL success, id result) {
    if (success) {
      [self processMostRecent:controller checkin:result];
    }
  }];
}

- (void) checkinZombie:(StatusViewController *)controller {
  [FoursquareCheckinList showCheckin:controller shoutList:nil callback:^(BOOL success, id result) {
    if (success) {
      NSArray *categories = (NSArray *)[(NSDictionary *)[(NSDictionary *)[(NSDictionary *)[(NSDictionary *)result valueForKey:@"response"] valueForKey:@"checkin"] valueForKey:@"venue"] valueForKey:@"categories"];
//      NSString *categoryId = (NSString *)[(NSDictionary *)[categories objectAtIndex:0] valueForKey:@"id"];
      
      NSString *categoryIcon = [(NSDictionary *)[categories objectAtIndex:0] valueForKey:@"icon"];
      
      if (category1 == nil) {
        self.category1 = categoryIcon;
      } else if ([category1 compare:categoryIcon] == 0) {
        // You've already visited this category.
      } else if (category2 == nil) {
        self.category2 = categoryIcon;
      } else if ([category2 compare:categoryIcon] == 0) {
        // You've already visited this category.
      } else if (category3 == nil) {
        self.category3 = categoryIcon;
      } else if ([category3 compare:categoryIcon] == 0) {
        // You've already visited this category.
      } else if (category4 == nil) {
        self.category4 = categoryIcon;
      } else if ([category4 compare:categoryIcon] == 0) {
        // You've already visited this category.
      } else {
        // You're no longer a zombie, congratulations!
        isZombie = false;
      }

      [self processMostRecent:controller checkin:result];
      
      NSLog(@"%@", categoryIcon);
    }
  }];
}

@end
