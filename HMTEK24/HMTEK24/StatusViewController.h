//
//  StatusViewController.h
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerStatus;
@class FontLabel;

@interface StatusViewController : UIViewController {
  IBOutlet UIImageView *zombieBackImage;
  IBOutlet UIImageView *aliveBackImage;
  
  UILabel* timeRemainingLabel1;
  UILabel* timeRemainingLabel2;
  UILabel* timeRemainingLabel3;
  IBOutlet UIButton *checkinZombieButton;
  IBOutlet UIButton *checkinAliveButton;
}
- (void)applicationDidBecomeActive;
- (void)refreshStatusView: (PlayerStatus*) status;
- (IBAction)onCheckinAlive:(id)sender;
- (IBAction)onCheckinZombie:(id)sender;

@end
