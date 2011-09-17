//
//  FSRoundedRectView.m
//  Libraries
//
//  Created by iphonedev2 on 10-11-02.
//  Copyright 2010 Magmic Inc. All rights reserved.
//

#import "FSRoundedRectView.h"

#define kDefaultStrokeColor  [UIColor whiteColor]
#define kDefaultFillColor    [UIColor blackColor]
#define kDefaultStrokeWidth  2.0
#define kDefaultCornerRadius 10.0

@implementation FSRoundedRectView

@synthesize strokeColor;
@synthesize fillColor;
@synthesize strokeWidth;
@synthesize cornerRadius;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    // Initialization code
    super.opaque = NO;
    super.backgroundColor = [UIColor clearColor]; // call super since we override to ignore background color changes
    self.contentMode = UIViewContentModeRedraw;
    self.strokeColor = kDefaultStrokeColor;
    self.fillColor = kDefaultFillColor;
    self.strokeWidth = kDefaultStrokeWidth;
    self.cornerRadius = kDefaultCornerRadius;
    
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
  }
  return self;
}

- (void)setBackgroundColor:(UIColor *)newBGColor {
  // Ignore any attempt to set background color - backgroundColor must stay set to clearColor
}

- (void)setOpaque:(BOOL)newIsOpaque {
  // Ignore attempt to set opaque to YES.
}

- (void)drawRect:(CGRect)rect {
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, self.strokeWidth);
  CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
  CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
  
  CGRect rrect = self.bounds;
  
  CGFloat radius = self.cornerRadius;
  CGFloat width = CGRectGetWidth(rrect);
  CGFloat height = CGRectGetHeight(rrect);
  
  // Make sure corner radius isn't larger than half the shorter side
  if (radius > width / 2.0) {
    radius = width / 2.0;
  }
  if (radius > height / 2.0) {
    radius = height / 2.0;
  }
  
  CGFloat minx = CGRectGetMinX(rrect);
  CGFloat midx = CGRectGetMidX(rrect);
  CGFloat maxx = CGRectGetMaxX(rrect);
  CGFloat miny = CGRectGetMinY(rrect);
  CGFloat midy = CGRectGetMidY(rrect);
  CGFloat maxy = CGRectGetMaxY(rrect);
  CGContextMoveToPoint(context, minx, midy);
  CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
  CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
  CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
  CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
  CGContextClosePath(context);
  CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)dealloc {
  [strokeColor release];
  [fillColor release];
  [super dealloc];
}

@end
