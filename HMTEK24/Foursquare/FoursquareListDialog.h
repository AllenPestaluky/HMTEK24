//
//  FoursquareListDialog.h
//  Libraries
//
//  Created by iphonedev2 on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoursquareWebLogin.h"
#import "Foursquare2.h"

#define FLD_TITLE_HEIGHT 40
#define FLD_BUTTON_HEIGHT 40
#define FLD_BUTTON_PADDING 15
#define FLD_BUTTON_SIDE_PADDING 10
#define FLD_BUTTON_TOP_PADDING 5
#define FLD_TITLE_FONT_SIZE 20
#define FLD_SCROLLER_PADDING 10

@class FSRoundedRectView;

typedef enum {
	FoursquareDialogDismissToBottom,
	FoursquareDialogDismissToLeft,
	FoursquareDialogDismissToRight
} FoursquareDialogDismissDirection;


@interface FoursquareListDialog : UIView {
	NSArray* _list;
  
  FoursquareDialogDismissDirection backDismissDirection;
  
  FSRoundedRectView *dialogView;
  UIScrollView *scroller;
}

@property (nonatomic, assign) Foursquare2Callback checkinCallback;
@property (nonatomic, assign) id delegate;

- (id)initWithList:(NSArray*)list;

- (void)setupListButtons;

- (void)showFromBottom;
- (void)showFromRight;

- (void)dismissToBottom;
- (void)dismissToLeft;
- (void)dismissToRight;

- (NSString *)title;
- (NSString *)backButtonTitle;

@end
