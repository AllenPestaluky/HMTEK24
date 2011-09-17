//
//  GlossyButton.h
//  Libraries
//
//  Created by iphonedev2 on 11-06-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlossyButton : UIButton {
  UIColor *normalColor;
  UIColor *highlightedColor;
}

@property (nonatomic, retain) UIColor *normalColor;
@property (nonatomic, retain) UIColor *highlightedColor;

@end
