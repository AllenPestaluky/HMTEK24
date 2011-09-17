//
//  StatusViewController.h
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerStatus;

@interface StatusViewController : UIViewController {
  IBOutlet UIImageView *zombieBackImage;
  IBOutlet UIImageView *aliveBackImage;
}
- (void)applicationDidBecomeActive;
- (void)refreshStatusView: (PlayerStatus*) status;

@end
