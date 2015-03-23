//
//  TubulrTableViewCell.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/20/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <MCSwipeTableViewCell/MCSwipeTableViewCell.h>
#import <UIKit/UIKit.h>
#import <RMSwipeTableViewCell/RMSwipeTableViewCell.h>
@class YoutubeVideo, VimeoVideo;

@interface TBRTableViewCell : MCSwipeTableViewCell

@property (strong, nonatomic) UIImageView * thumbnailHolderView;

@property (strong, nonatomic) UIView * contentOverlayView;
@property (strong, nonatomic) UILabel * videoTitleLabel;
@property (strong, nonatomic) UILabel * videoLengthLabel;
@property (strong, nonatomic) UILabel * currentTubulrStatusLabel;

@property (nonatomic) BOOL contentOverlayIsHidden;

-(void) adjustContentOverlayVisibility;
-(void) updateCellContentsForYoutubeVideo:(YoutubeVideo *)video;
-(void) updateCellContentsForVimeoVideo:(VimeoVideo *)video;

@end
