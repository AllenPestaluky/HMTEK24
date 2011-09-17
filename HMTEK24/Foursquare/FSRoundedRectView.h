//
//  RoundedRectView.h
//  Libraries
//
//  Created by iphonedev2 on 10-11-02.
//  Copyright 2010 Magmic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSRoundedRectView : UIView {
  UIColor *strokeColor;
  UIColor *fillColor;
  CGFloat strokeWidth;
  CGFloat cornerRadius;
}

@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) CGFloat cornerRadius;

@end
