//
//  TubulrVideoTableView.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

@import UIKit;
@import Foundation;
@class YoutubeVideo, VimeoVideo;

@interface TBRMultipleVideosTableView : UIView

@property (strong, nonatomic) UIView * alignmentView;
@property (strong, nonatomic) UIView * containerView;
@property (strong, nonatomic) UITableView * videoTableView;


+(instancetype) presentTableViewIn:(UIView*)view animated:(BOOL)animated;
-(instancetype) initWithFrame:(CGRect)frame inView:(UIView *)view animated:(BOOL)animated;
-(void) addYoutubeVideoToTable:(YoutubeVideo *)video;
-(void) addVimeoVideoToTable:(VimeoVideo *)video;

@end
