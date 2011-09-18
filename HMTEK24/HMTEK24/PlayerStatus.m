//
//  PlayerStatus.m
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import "PlayerStatus.h"
#import "Foursquare2.h"

@implementation PlayerStatus

@synthesize zombieTime;
@synthesize isZombie;
@synthesize hours;
@synthesize minutes;
@synthesize seconds;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
      [self reset];
    }
    
    return self;
}

- (void) reset {
  zombieTime = 0;
}

- (void) calculateZombieTime:(StatusViewController *)controller {
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

          [self getZombieStatus:controller];
        }
      }];
    }
  }];
}

- (void) getZombieStatus:(StatusViewController *)controller {
  if (zombieTime == 0) {
    [self calculateZombieTime:controller];
  } else {
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
  
    [controller refreshStatusView:self];
  }
}

@end
