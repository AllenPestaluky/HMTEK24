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
}

@property long zombieTime;
@property int hours;
@property int minutes;
@property int seconds;
@property bool isZombie;

-(void)calculateZombieTime:(StatusViewController *)controller;
-(void)reset;
-(void)getZombieStatus:(StatusViewController *)controller;

@end
