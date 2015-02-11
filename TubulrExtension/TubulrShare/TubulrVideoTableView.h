//
//  TubulrVideoTableView.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TubulrVideoTableView : UIView

@property (strong, nonatomic) UIView * alignmentView;
@property (strong, nonatomic) UIView * containerView;
@property (strong, nonatomic) UITableView * videoTableView;

+(void) presentTableViewIn:(UIView *)view;

@end