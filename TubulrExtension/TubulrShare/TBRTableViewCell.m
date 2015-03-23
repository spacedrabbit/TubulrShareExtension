//
//  TubulrTableViewCell.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/20/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TBRTableViewCell.h"
#import "UIColor+TubulrColors.h"
#import "YoutubeVideo.h"
#import "VimeoVideo.h"

#import <UIImageView+AFNetworking.h>
#import <FontAwesomeKit/FAKFontAwesome.h>

CGFloat const kIconSizes    = 40.0;
CGFloat const kFontSizes    = 32.0;
CGFloat const kCornerRadius = 10.0;

NSString * const kTubulrHelveticaNeue = @"Helvetica-Neue Bold";

@interface TBRTableViewCell () <MCSwipeTableViewCellDelegate>

@property (strong, nonatomic) FAKFontAwesome * heartIcon;
@property (strong, nonatomic) FAKFontAwesome * watchIcon;

@end

@implementation TBRTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.defaultColor = [UIColor clearColor];
        _contentOverlayIsHidden = YES;
        [self setUpCellContentFormat];
        [self adjustViewConstraints];
        [self addSwipeIcons];
    }
    return self;
}

-(void) addSwipeIcons{
    
    // | heart <----> watch | //
    self.heartIcon      = [FAKFontAwesome heartIconWithSize :kIconSizes];
    self.watchIcon = [FAKFontAwesome clockOIconWithSize:kIconSizes];
    [self.heartIcon      addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [self.watchIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    // -- setting up icons in imageviews -- //
    UIImage     * heartIconImage        = [self.heartIcon   imageWithSize:CGSizeMake(60, 60)];
    UIImage     * watchLaterIconImage   = [self.watchIcon   imageWithSize:CGSizeMake(60, 60)];
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
    [self setFirstTrigger       :0.10 ];
    [self setSecondTrigger      :0.15];
    self.modeForState2 = MCSwipeTableViewCellModeSwitch;
    self.modeForState4 = MCSwipeTableViewCellModeSwitch;
    // TODO: Set a 3rd trigger for when swipe should snap back into place
    
    // each "mode" needs a color, 1&2 are left side, 3&4 right
    self.color1 = [UIColor srl_heartPinkColor];
    self.color2 = [UIColor srl_heartPinkColor];
    self.color3 = [UIColor srl_watchBlueColor];
    self.color4 = [UIColor srl_watchBlueColor];
    
    typeof(self) __weak weakSelf = self;
    [self setSwipeGestureWithView:heartImageView
                            color:[UIColor srl_heartPinkColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState1
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         TBRTableViewCell * currentCell = (TBRTableViewCell *)cell;
         currentCell.currentTubulrStatusLabel.attributedText = [weakSelf.heartIcon attributedString];
         NSLog(@"Swiped heart?");
         // handle "heart" swipe
     }];
    [self setSwipeGestureWithView:watchLaterImageView
                            color:[UIColor srl_watchBlueColor]
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState3
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         weakSelf.currentTubulrStatusLabel.attributedText = [weakSelf.watchIcon attributedString];
         NSLog(@"Swiped watch?");
         // handle "watch" swipe
     }];

    
}

-(void)setUpCellContentFormat{
    
    [self setSelectionStyle     : UITableViewCellSelectionStyleDefault              ];
    [self.contentView setBackgroundColor:[UIColor srl_mainBackgroundDarkGrayColor]] ;
    [self.layer setMasksToBounds:YES]; //clips the highlighted state to bounds of the cell
    
}

-(void)adjustViewConstraints{

    _thumbnailHolderView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _contentOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    _videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _videoLengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _currentTubulrStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [_thumbnailHolderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_contentOverlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_videoTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_videoLengthLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_currentTubulrStatusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_thumbnailHolderView setUserInteractionEnabled:YES];
    [_contentOverlayView setUserInteractionEnabled:YES];
    
    _contentOverlayIsHidden = YES;
    
    NSDictionary * cellViews = @{   @"thumbnailView" : _thumbnailHolderView,
                                    @"contentOverlay" : _contentOverlayView,
                                    @"videoTitleLabel" : _videoTitleLabel,
                                    @"videoLengthLabel" : _videoLengthLabel,
                                    @"tubulrStatus" : _currentTubulrStatusLabel,
                                    @"mainContentView" : self.contentView       };
    
    [self.contentView addSubview:_thumbnailHolderView];
    [self.contentView addSubview:_contentOverlayView];
    
    // -- Thumbnail view and content view -- //
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[thumbnailView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:cellViews ]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[thumbnailView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:cellViews ]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentOverlay]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:cellViews ]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentOverlay]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:cellViews ]];
    [_contentOverlayView addSubview:_videoLengthLabel];
    [_contentOverlayView addSubview:_videoTitleLabel];
    [_contentOverlayView addSubview:_currentTubulrStatusLabel];
    [_contentOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:.45]];
    
    // -- Content overlay, appears when tapping a video -- //
    [_contentOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[videoTitleLabel]-[videoLengthLabel]"
                                                                                options:NSLayoutFormatAlignAllLeading
                                                                                metrics:nil
                                                                                  views:cellViews ]];
    [_contentOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[videoTitleLabel]-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:cellViews ]];
    [_contentOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[videoLengthLabel]-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:cellViews ]];
    [_contentOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[tubulrStatus]-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:cellViews ]];
    [_contentOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tubulrStatus]-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:cellViews ]];
    // -- Adjusting labels/fonts for content overlay info -- //
    [_videoTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [_videoLengthLabel setTextAlignment:NSTextAlignmentLeft];
    [_currentTubulrStatusLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_videoTitleLabel setNumberOfLines:0];
    
    [_videoTitleLabel setFont:[UIFont fontWithName:kTubulrHelveticaNeue size:64.0]];
    [_videoTitleLabel setTextColor:[UIColor whiteColor]];
    
    [_videoLengthLabel setFont:[UIFont fontWithName:kTubulrHelveticaNeue size:24.0]];
    [_videoLengthLabel setTextColor:[UIColor whiteColor]];
    
    [_currentTubulrStatusLabel setFont:[UIFont fontWithName:kTubulrHelveticaNeue size:kFontSizes]];

}

- (void) adjustContentOverlayVisibility{

    CGFloat alphaValue;
    if (self.contentOverlayIsHidden) {
        alphaValue = 0.0;
    }else{
        alphaValue = 1.0;
    }
    
    [UIView animateWithDuration:.3 animations:^{
        [_contentOverlayView setAlpha:alphaValue];
    }];
    
}

-(void)updateCellContentsForVimeoVideo:(VimeoVideo *)video{
    
    // TODO: to do
}

-(void)updateCellContentsForYoutubeVideo:(YoutubeVideo *)video{
    
    self.videoTitleLabel.text = video.videoTitle;
    self.videoLengthLabel.text = @"3:41";
    self.currentTubulrStatusLabel.attributedText = [self.heartIcon attributedString];
    
    NSURL * imageThumbnailURL = [NSURL URLWithString: video.imgURL_480x360];
    [self.thumbnailHolderView setContentMode:UIViewContentModeScaleAspectFill];
    [self.thumbnailHolderView setImageWithURL:imageThumbnailURL placeholderImage:[UIImage imageNamed:@"example-grid-100x100pt"]];
    
}

-(void)prepareForReuse{
    // im not entirely sure why, but the cells are constantly highlighted/selected
    // the only way to resolve a visual bug was to implement these calls in prepareForReuse
    // and to allow the tableview to allow multiple selections. needs further investigation.
    // And even with this, sometimes it still happens
    self.contentOverlayIsHidden = YES;
    [self setSelected:NO];
    [self adjustContentOverlayVisibility];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self adjustContentOverlayVisibility];
    self.contentOverlayIsHidden = !self.contentOverlayIsHidden;
}

/**     currently need this because if the default color isn't set, it defaults to white
 *      and after you release the cell from a swipe, it transitions back to the default color.
 *      so you end up with an unwanted transition to white unless you dynamically change this value
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
