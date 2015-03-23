//
//  TubulrVideoTableView.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TBRMultipleVideosTableView.h"
#import "TBRTableViewCell.h"
#import "TBRQueueManager.h"
#import "UIColor+TubulrColors.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "YoutubeVideo.h"
#import "VimeoVideo.h"

static NSString * const kCellIdentifier = @"cell";

// we base the overall size on how wide the cells will be
static CGFloat const kHorizontalMarginPercent = 0.10;

// we want 2.5 cells to be visible
static CGFloat const kNumberOfCellsToDisplay = 2.50;

// 16:9 ratio for cells
static CGFloat const kScalingWidth = 16.0;
static CGFloat const kScalingHeight = 9.0;

@interface TBRMultipleVideosTableView() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UIView * parentView;
@property (nonatomic) BOOL shouldAnimate;

@property (strong, nonatomic) NSMutableArray * videosArray;

@end

@implementation TBRMultipleVideosTableView

/**********************************************************************************
 *
 *                      INTIALIZERS
 *
 **********************************************************************************/

 /**  Instatiates and draws a multiple video table view in the view passed in
  *
  *      @brief Creates instance of TubulrVideoTableView
  *      @copyright Louis Tur 2015
  *
  */
+(instancetype)presentTableViewIn:(UIView*)view animated:(BOOL)animated{
    TBRMultipleVideosTableView * classObject = [[[TBRMultipleVideosTableView class] alloc] initWithFrame:view.frame inView:view animated:animated];
    return classObject;
}

/**     SEL initWithFrame:inView:animated: is the designated initializer
 *
 *      this will add an instance of TubulrTableView in the view passed
 */
-(instancetype)initWithFrame:(CGRect)frame inView:(UIView *)view animated:(BOOL)animated{
    self = [super initWithFrame:frame];
    if (self) {
        
        _shouldAnimate = animated ? YES : NO;
        _videosArray = [[NSMutableArray alloc] init];
        
        _alignmentView  = [[UIView alloc] init];
        _containerView  = [[UIView alloc] init];
        _videoTableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                       style:UITableViewStylePlain];
        [_videoTableView setAllowsMultipleSelection:YES];
        
        [_videoTableView registerClass:[TBRTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [_videoTableView setDataSource:self];
        [_videoTableView setDelegate:self];
        [_videoTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_videoTableView setSeparatorColor:[UIColor clearColor]];
        
        // if a view is passed, we will use this to setup constraints
        if (view) {
            _parentView = view;
            [_parentView addSubview:self];
        }
        
        [self setUpAllConstraints];
        [self registerForNotifications];
        
        if (_shouldAnimate) {
            [UIView animateWithDuration:.3 animations:^{
                [_alignmentView setAlpha:1.0];
            }];
        }
        
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame inView:nil animated:NO];
}


#pragma mark - SETUP CONSTRAINTS
-(void)setUpAllConstraints{
    
    if (self.shouldAnimate) {
       [_alignmentView setAlpha:0.0];
    }
    
    // basic setup
    [_alignmentView     setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_containerView     setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_videoTableView    setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self           addSubview:_alignmentView];
    [_alignmentView addSubview:_containerView];
    [_containerView addSubview:_videoTableView];
    
    [_alignmentView  setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.35]];
    [_containerView  setBackgroundColor:[UIColor srl_mainBackgroundDarkGrayColor]];
    [_videoTableView setBackgroundColor:[UIColor srl_textFieldLightGrayColor]];
    
    [_containerView.layer  setCornerRadius:15.0];
    [_videoTableView.layer setCornerRadius:10.0];
    
    [self setUpConstraintsForAlignmentView];
    [self setUpConstraintsForContainerView];
    [self setUpConstraintsForTableView];
    
    [super updateConstraints];

}

#pragma mark - NOTIFICATIONS
-(void) registerForNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustConstraintsForKeyboard:) name:UIKeyboardDidShowNotification object:nil];
}

-(void)addYoutubeVideoToTable:(YoutubeVideo *)video{
    [self addVideoToArray:video];
}
-(void)addVimeoVideoToTable:(VimeoVideo *)video{
    [self addVideoToArray:video];
}
-(void) addVideoToArray:(id)video{
    
    [self.videosArray addObject:video];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self.videoTableView reloadData];
    });
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TBRTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[TBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    if ([self.videosArray count]) {

        id currentVideo = [self.videosArray objectAtIndex:indexPath.row];
        if ([currentVideo isKindOfClass:[YoutubeVideo class]]) {
            
            YoutubeVideo * youtubeVideo = (YoutubeVideo *)currentVideo;
            [cell updateCellContentsForYoutubeVideo:youtubeVideo];

        }else if ([currentVideo isKindOfClass:[VimeoVideo class]]){
            
            VimeoVideo * vimeoVideo = (VimeoVideo *)currentVideo;
            [cell updateCellContentsForVimeoVideo:vimeoVideo];
        }
    }
 
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.videosArray count] > 0 ? self.videosArray.count : 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TBRMultipleVideosTableView maxCellHeightFor16x9Ratio];
}

/*---------------------------------------------------------------------------------------
 |
 |              CONSTRAINT SETUP
 |
 --------------------------------------------------------------------------------------- */
#pragma mark - CONSTRAINT METHODS
-(void)setUpConstraintsForAlignmentView{
    
    NSDictionary * viewsDictionary = @{     @"alignView": _alignmentView,
                                            @"containView" : _containerView,
                                            @"videoTableView" : _videoTableView     };
    
    NSArray * visualConstraints = @[    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[alignView]|" options:0 metrics:nil views:viewsDictionary],
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[alignView]|" options:0 metrics:nil views:viewsDictionary]   ];
    
    for (NSArray * constraint in visualConstraints) {
        [self addConstraints:constraint];
    }
    
}
-(void)setUpConstraintsForContainerView{
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSArray * contentConstraints = @[    [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_alignmentView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:applicationFrame.size.width * kHorizontalMarginPercent],
                                         [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_alignmentView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:-(applicationFrame.size.width * kHorizontalMarginPercent)],
                                         [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:applicationFrame.size.height * [TBRMultipleVideosTableView percentMarginForTopAndBottom]],
                                         [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:-(applicationFrame.size.height * [TBRMultipleVideosTableView percentMarginForTopAndBottom])]                              ];
    [self addConstraints:contentConstraints];
}
-(void)setUpConstraintsForTableView{
    
    NSArray * tableViewConstraints = @[ [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[table]-|" options:0 metrics:nil views:@{@"table":_videoTableView}],
                                        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[table]-|" options:0 metrics:nil views:@{@"table":_videoTableView}] ];
    
    for (NSArray * constraint in tableViewConstraints) {
        [self addConstraints:constraint];
    }
    
}

// TODO: Adjust for kb
#pragma mark Adjusting for KB
-(void)adjustConstraintsForKeyboard:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        NSLog(@"Did show KB");
    }
    
    if ([notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        NSLog(@"Did hide KB");
    }
    
}

// -- Convinience Methods -- //
+(CGFloat) maxCellHeightFor16x9Ratio{
    
    return [TBRMultipleVideosTableView scalingUnitForSize] * kScalingHeight;
}

+(CGFloat) maxCellWidthFor16x9Ratio{
    
    CGRect displaySize = [UIScreen mainScreen].applicationFrame;
    CGFloat tableWidth = displaySize.size.width - (displaySize.size.width * kHorizontalMarginPercent * 2);
    
    return tableWidth;
}

+(CGFloat) scalingUnitForSize{
    
    CGFloat cellWidth = [TBRMultipleVideosTableView maxCellWidthFor16x9Ratio];
    return ( cellWidth / kScalingWidth );
}

+(CGFloat) fullHeightOfVideoTable{
    return [TBRMultipleVideosTableView maxCellHeightFor16x9Ratio] * kNumberOfCellsToDisplay;
}

+(CGFloat) percentMarginForTopAndBottom{
    CGFloat screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    CGFloat unusedVerticalSpace = screenHeight - [TBRMultipleVideosTableView fullHeightOfVideoTable];
    
    return ( unusedVerticalSpace / screenHeight ) / 2.0;
}

+(BOOL)requiresConstraintBasedLayout{
    return YES; // custom views that use Autolayout return YES
}
@end
