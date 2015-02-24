//
//  TubulrTableViewCell.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/20/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubulrTableViewCell.h"
#import "UIColor+TubulrColors.h"

#import <FontAwesomeKit/FAKFontAwesome.h>

CGFloat const kIconSizes = 40.0;

@interface TubulrTableViewCell () <MCSwipeTableViewCellDelegate>

@end

@implementation TubulrTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpCellContentFormat];
        [self adjustViewConstraints];
    }
    return self;
}

-(void)setUpCellContentFormat{
    
    [self setSelectionStyle     : UITableViewCellSelectionStyleNone              ];
    [self setBackgroundColor    :[UIColor srl_mainBackgroundDarkGrayColor        ]];
    [self.textLabel setTextColor:[UIColor srl_closeButtonGrayColor               ]];
    [self.textLabel setFont     :[UIFont fontWithName:@"Helvetica-Neue" size:24.0]];
    [self.layer setCornerRadius :10.0];
    [self.layer setMasksToBounds:YES]; //clips the highlighted state to bounds of the cell
    
    FAKFontAwesome * heartIcon      = [FAKFontAwesome heartIconWithSize :kIconSizes];
    FAKFontAwesome * watchLaterIcon = [FAKFontAwesome clockOIconWithSize:kIconSizes];
    
    [heartIcon      addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [watchLaterIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    UIImage * heartIconImage        = [heartIcon        imageWithSize:CGSizeMake(40, 40)];
    UIImage * watchLaterIconImage   = [watchLaterIcon   imageWithSize:CGSizeMake(40, 40)];
    
    UIImageView * heartImageView        = [[UIImageView alloc] initWithImage:heartIconImage];
    UIImageView * watchLaterImageView   = [[UIImageView alloc] initWithImage:watchLaterIconImage];
    
    [heartImageView         setBackgroundColor:[UIColor srl_heartPinkColor]];
    [watchLaterImageView    setBackgroundColor:[UIColor srl_watchBlueColor]];

    [self setShouldDrag         :YES    ];
    [self setShouldAnimateIcons :YES    ];
    [self setDamping            :20.0   ];
    [self setDelegate           :self   ];
    
    [self setFirstTrigger       :0.0];
    [self setSecondTrigger      :.20];
    self.modeForState2 = MCSwipeTableViewCellModeSwitch;
    self.modeForState4 = MCSwipeTableViewCellModeSwitch;

    [self setSwipeGestureWithView:heartImageView
                            color:[UIColor srl_heartPinkColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState1
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
    {

        
    }];
    [self setSwipeGestureWithView:watchLaterImageView
                            color:[UIColor srl_watchBlueColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState3
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         
         
     }];
    
}

-(void)adjustViewConstraints{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell{
    
}

-(void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage{
    
}

@end
