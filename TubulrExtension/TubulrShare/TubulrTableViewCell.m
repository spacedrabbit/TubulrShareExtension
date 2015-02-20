//
//  TubulrTableViewCell.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/20/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubulrTableViewCell.h"
#import <FontAwesomeKit/FAKFontAwesome.h>

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
    // TODO: Create UIColor Category
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.backgroundColor = [UIColor colorWithRed:42.0/255.00 green:42.0/255.00 blue:42.0/255.00 alpha:1.0];
    [self.textLabel setTextColor:[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0]];
    [self.textLabel setFont:[UIFont fontWithName:@"Helvetica-Neue" size:18.0]];
    [self.layer setCornerRadius:10.0];
    [self.layer setMasksToBounds:YES]; //clips the highlighted state to bounds of the cell
    
    FAKFontAwesome * heartIcon = [FAKFontAwesome heartIconWithSize:24.0];
    FAKFontAwesome * watchLaterIcon = [FAKFontAwesome closeIconWithSize:24.0];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [watchLaterIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [watchLaterIcon addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:93.0/255.0 green:192.0/255.0 blue:210.0/255.0 alpha:1.0]];

    
    UIImage * heartIconImage = [heartIcon imageWithSize:CGSizeMake(40, 40)];
    UIImage * watchLaterIconImage = [watchLaterIcon imageWithSize:CGSizeMake(40, 40)];
    
    UIImageView * heartImageView = [[UIImageView alloc] initWithImage:heartIconImage];
    UIImageView * watchLaterImageView = [[UIImageView alloc] initWithImage:watchLaterIconImage];
    
    [self setShouldDrag:YES];
    [self setShouldAnimateIcons:YES];
    [self setDamping:.5];
    [self setDefaultColor:[UIColor clearColor]];
    [self setColor1:[UIColor colorWithRed:250.0/255.0 green:127.0/255.0 blue:146.0/255.0 alpha:1.0]];
    [self setColor2:[UIColor colorWithRed:93.0/255.0 green:192.0/255.0 blue:210.0/255.0 alpha:1.0]];
    [self setSwipeGestureWithView:heartImageView
                            color:[UIColor colorWithRed:250.0/255.0 green:127.0/255.0 blue:146.0/255.0 alpha:1.0]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState1
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
    {
        
        
    }];
    [self setSwipeGestureWithView:watchLaterImageView
                            color:[UIColor colorWithRed:93.0/255.0 green:192.0/255.0 blue:210.0/255.0 alpha:1.0]
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

@end
