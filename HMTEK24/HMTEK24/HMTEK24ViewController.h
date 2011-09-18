//
//  HMTEK24ViewController.h
//  HMTEK24
//
//  Created by Allen Pestaluky on 11-09-17.
//  Copyright 2011 Magmic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"

@interface HMTEK24ViewController : UIViewController {
  StatusViewController* statusViewController;
}

@property (nonatomic, retain) StatusViewController* statusViewController;

- (void)applicationDidBecomeActive;

@end
