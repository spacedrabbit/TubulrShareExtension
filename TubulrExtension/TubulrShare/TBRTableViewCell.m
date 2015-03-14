//
//  TubulrTableViewCell.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/20/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TBRTableViewCell.h"
#import "UIColor+TubulrColors.h"

#import <FontAwesomeKit/FAKFontAwesome.h>

CGFloat const kIconSizes    = 40.0;
CGFloat const kFontSizes    = 32.0;
CGFloat const kCornerRadius = 10.0;

NSString * const kTubulrHelveticaNeue = @"Helvetica-Neue";

@interface TBRTableViewCell () <MCSwipeTableViewCellDelegate>

@end

@implementation TBRTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.defaultColor = [UIColor clearColor];
        [self setUpCellContentFormat];
        [self adjustViewConstraints];
        [self addSwipeIcons];
    }
    return self;
}

-(void) addSwipeIcons{
    
    // | heart <----> watch | //
    FAKFontAwesome * heartIcon      = [FAKFontAwesome heartIconWithSize :kIconSizes];
    FAKFontAwesome * watchLaterIcon = [FAKFontAwesome clockOIconWithSize:kIconSizes];
    [heartIcon      addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [watchLaterIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    // -- setting up icons in imageviews -- //
    UIImage     * heartIconImage        = [heartIcon        imageWithSize:CGSizeMake(60, 60)];
    UIImage     * watchLaterIconImage   = [watchLaterIcon   imageWithSize:CGSizeMake(60, 60)];
    UIImageView * heartImageView        = [[UIImageView alloc] initWithImage:heartIconImage];
    UIImageView * watchLaterImageView   = [[UIImageView alloc] initWithImage:watchLaterIconImage];
    
    [heartImageView         setBackgroundColor:[UIColor srl_heartPinkColor]];
    [watchLaterImageView    setBackgroundColor:[UIColor srl_watchBlueColor]];
    
    // -- MCSwipeTableViewCell subclassing setup -- //
    [self setShouldDrag         :YES    ];
    [self setShouldAnimateIcons :YES    ];
    [self setDamping            :1.0    ];  // how much "spring" effect.. not really working
    [self setDelegate           :self   ];
    
    /*  bit of a hack to get this to work as I wanted
        - set the first trigger to 0.0 and then the second to where I actually want the event to fire
        - set the mode for states 2 & 4, so that they work in tandem with states 1 & 3 that are being
        - set in setSwipeGestureWithView:color:mode:state:completionBlock:
     */
    [self setFirstTrigger       :0.0 ];
    [self setSecondTrigger      :0.20];
    self.modeForState2 = MCSwipeTableViewCellModeSwitch;
    self.modeForState4 = MCSwipeTableViewCellModeSwitch;
    // TODO: Set a 3rd trigger for when swipe should snap back into place
    
    // each "mode" needs a color, 1&2 are left side, 3&4 right
    self.color1 = [UIColor srl_heartPinkColor];
    self.color2 = [UIColor srl_heartPinkColor];
    self.color3 = [UIColor srl_watchBlueColor];
    self.color4 = [UIColor srl_watchBlueColor];
    
    [self setSwipeGestureWithView:heartImageView
                            color:[UIColor srl_heartPinkColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState1
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         
         // handle "heart" swipe
     }];
    [self setSwipeGestureWithView:watchLaterImageView
                            color:[UIColor srl_watchBlueColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState3
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         
         // handle "watch" swipe
     }];

    
}

-(void)setUpCellContentFormat{
    
    [self setSelectionStyle     : UITableViewCellSelectionStyleNone              ];
    [self setBackgroundColor    :[UIColor srl_mainBackgroundDarkGrayColor        ]];
    [self.textLabel setTextColor:[UIColor srl_closeButtonGrayColor               ]];
    [self.textLabel setFont     :[UIFont fontWithName:kTubulrHelveticaNeue size:kFontSizes]];
    //[self.layer setCornerRadius :kCornerRadius];
    [self.layer setMasksToBounds:YES]; //clips the highlighted state to bounds of the cell
    
    
}

-(void)adjustViewConstraints{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

/** currently need this because if the default color isn't set, it defaults to white
    and after you release the cell from a swipe, it transitions back to the default color.
    so you end up with an unwanted transition to white unless you dynamically change this value
 */
-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage{
    // checks direction of swipe based on %, which is just the offset
    if ( percentage < 0.0 ) {
        self.defaultColor = [UIColor srl_watchBlueColor]; // r->l
    }else{
        self.defaultColor = [UIColor srl_heartPinkColor]; // l->r
    }
}

@end
