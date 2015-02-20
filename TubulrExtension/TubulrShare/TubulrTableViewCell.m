//
//  TubulrTableViewCell.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/20/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubulrTableViewCell.h"

@implementation TubulrTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpCellContentFormat];
    }
    return self;
}

-(void)setUpCellContentFormat{
    self.backgroundColor = [UIColor colorWithRed:42.0/255.00 green:42.0/255.00 blue:42.0/255.00 alpha:.60];
    
    [self.textLabel setTextColor:[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0]];
    [self.textLabel setFont:[UIFont fontWithName:@"Menlo" size:18.0]];
    
    [self.layer setCornerRadius:10.0];
    [self.layer setMasksToBounds:YES]; //clips the highlighted state to bounds of the cell
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

@end
