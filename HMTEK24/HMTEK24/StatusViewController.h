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
  IBOutlet UIView *ZombieView;
  IBOutlet UIView *AliveView;
  
  UILabel* timeRemainingLabel1;
  UILabel* timeRemainingLabel2;
  //UILabel* timeRemainingLabel3;
    
  IBOutlet UIImageView *photoImage;
  IBOutlet UIImageView *photoOverlayImage;
  
  IBOutlet UITextView *venueStatusTextView;
  IBOutlet UITextView *zombieReasonTextView;
  IBOutlet UIImageView *venueType1Image;
  IBOutlet UIImageView *venueType2Image;
  IBOutlet UIImageView *venueType3Image;
  IBOutlet UIImageView *venueType4Image;
  IBOutlet UIImageView *venueType5Image;
  
  UIImage* defaultVenuIcon;
  
  PlayerStatus *status;
}

@property (nonatomic, retain) PlayerStatus *status;

- (void)applicationDidBecomeActive;
-(void) tick;
- (void)refreshStatusView;
- (IBAction)onCheckinAlive:(id)sender;
- (IBAction)onCheckinZombie:(id)sender;

@end
