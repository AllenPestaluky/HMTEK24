//
//  FoursquareListDialog.m
//  Libraries
//
//  Created by iphonedev2 on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FoursquareListDialog.h"
#import "FSRoundedRectView.h"
#import "GlossyButton.h"
#import "FoursquareShoutList.h"

@interface FoursquareListDialog ()

- (void)loadView;
- (void)beginViewSetup;
- (void)finishViewSetup;

@end


@implementation FoursquareListDialog

@synthesize delegate;
@synthesize checkinCallback;

- (id)initWithList:(NSArray*)list {
	self = [super init];
	if (self != nil) {
		_list = [list retain];
    
    [self loadView];
	}
	return self;
}

- (void)dealloc {
  [_list release];
  [dialogView release];
  [scroller release];
  [super dealloc];
}

- (void)loadView {
  [self beginViewSetup];
  [self setupListButtons];
  [self finishViewSetup];
}

- (void)beginViewSetup {
  self.frame = [UIScreen mainScreen].bounds;
  
	[self setBackgroundColor:[UIColor clearColor]];
	[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
	
	int width = self.bounds.size.width;
	int height = self.bounds.size.height;
  
  int dialogWidth = width * 87 / 100;
  int maxDialogHeight = height * 80 / 100;
  
  int scrollerWidth = dialogWidth - FLD_SCROLLER_PADDING * 2;
  
  int dialogX = (width - dialogWidth) / 2;
  int dialogY = (height - maxDialogHeight) / 2;
	
  dialogView = [[FSRoundedRectView alloc] initWithFrame:CGRectMake(dialogX, dialogY, dialogWidth, maxDialogHeight)];
  
	scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(FLD_SCROLLER_PADDING, FLD_TITLE_HEIGHT, scrollerWidth, maxDialogHeight - FLD_TITLE_HEIGHT - FLD_SCROLLER_PADDING - FLD_BUTTON_HEIGHT - FLD_BUTTON_PADDING)];
	scroller.clipsToBounds = YES;
	scroller.scrollEnabled = YES;
  scroller.autoresizesSubviews = NO;
  [scroller setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
}

- (void)finishViewSetup {
	int width = self.bounds.size.width;
  
  int dialogWidth = width * 87 / 100;
  
  FSRoundedRectView *scrollerBackground = [[FSRoundedRectView alloc] initWithFrame:scroller.frame];
  scrollerBackground.fillColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5];
  scrollerBackground.strokeColor = [UIColor darkGrayColor];
  scrollerBackground.cornerRadius = 5.0;
  CGRect scrollerBackgroundFrame = scrollerBackground.frame;
  scrollerBackgroundFrame.origin.y -= scrollerBackground.strokeWidth;
  scrollerBackgroundFrame.size.height += scrollerBackground.strokeWidth * 2;
  scrollerBackground.frame = scrollerBackgroundFrame;
  
  [dialogView addSubview:scrollerBackground];
	[dialogView addSubview:scroller];
  
  UILabel *dialogTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dialogWidth, FLD_TITLE_HEIGHT)];
  dialogTitle.textColor = [UIColor whiteColor];
  dialogTitle.backgroundColor = [UIColor clearColor];
  dialogTitle.text = [self title];
  dialogTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:FLD_TITLE_FONT_SIZE];
  dialogTitle.textAlignment = UITextAlignmentCenter;
  [dialogTitle setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
  
  [dialogView addSubview:dialogTitle];
  
  GlossyButton *backButton = [[GlossyButton alloc] initWithFrame:CGRectMake(FLD_SCROLLER_PADDING, dialogView.frame.size.height - FLD_BUTTON_PADDING - FLD_BUTTON_HEIGHT, dialogWidth - FLD_SCROLLER_PADDING * 2, FLD_BUTTON_HEIGHT)];
  [backButton setTitle:[self backButtonTitle] forState:UIControlStateNormal];
  [backButton addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
  [dialogView addSubview:backButton];
  
  [self addSubview:dialogView];
  
  [backButton release];
  [scrollerBackground release];
  [dialogTitle release];
}

- (void)setupListButtons {
}

- (void)backPressed:(id)sender {
  switch (backDismissDirection) {
    case FoursquareDialogDismissToBottom:
      [self dismissToBottom];
      break;
    case FoursquareDialogDismissToLeft:
      [self dismissToLeft];
      break;
    case FoursquareDialogDismissToRight:
      [self dismissToRight];
      break;
  }
  
  checkinCallback(NO, nil);
  [checkinCallback release];
}

- (void)showFromBottom {
  CGRect dialogFrame = self.frame;
  dialogFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
  self.frame = dialogFrame;
  
  backDismissDirection = FoursquareDialogDismissToBottom;
  
  [UIView animateWithDuration:0.4
                   animations:^{
                     CGRect dialogFrame = self.frame;
                     dialogFrame.origin.y = 0;
                     self.frame = dialogFrame;
                   }];
}

- (void)showFromRight {
  CGRect dialogFrame = self.frame;
  dialogFrame.origin.x = [UIScreen mainScreen].bounds.size.width;
  self.frame = dialogFrame;
  
  backDismissDirection = FoursquareDialogDismissToBottom;
  
  [UIView animateWithDuration:0.4
                   animations:^{
                     CGRect dialogFrame = self.frame;
                     dialogFrame.origin.x = 0;
                     self.frame = dialogFrame;
                   }];
}

- (void)dismissToBottom {
  [UIView animateWithDuration:0.4
                   animations:^{
                     CGRect dialogFrame = self.frame;
                     dialogFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
                     self.frame = dialogFrame;
                   }
                   completion:^(BOOL finished){
                     [self removeFromSuperview];
                   }];
}

- (void)dismissToLeft {
  [UIView animateWithDuration:0.4
                   animations:^{
                     CGRect dialogFrame = self.frame;
                     dialogFrame.origin.x = -[UIScreen mainScreen].bounds.size.width;
                     self.frame = dialogFrame;
                   }
                   completion:^(BOOL finished){
                     [self removeFromSuperview];
                   }];
}

- (void)dismissToRight {
  [UIView animateWithDuration:0.4
                   animations:^{
                     CGRect dialogFrame = self.frame;
                     dialogFrame.origin.x = [UIScreen mainScreen].bounds.size.width;
                     self.frame = dialogFrame;
                   }
                   completion:^(BOOL finished){
                     [self removeFromSuperview];
                   }];
}

- (NSString *)title {
  return @"Default title";
}

- (NSString *)backButtonTitle {
  return @"Back";
}

@end
