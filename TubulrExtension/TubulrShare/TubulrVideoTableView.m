//
//  TubulrVideoTableView.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubulrVideoTableView.h"
#import "TubulrTableViewCell.h"
#import "UIColor+TubulrColors.h"

static NSString * const kCellIdentifier = @"cell";

@interface TubulrVideoTableView() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UIView * parentView;
@property (nonatomic) BOOL shouldAnimate;

@end

@implementation TubulrVideoTableView

/**********************************************************************************
 *
 *                      INTIALIZERS
 *
 **********************************************************************************/

 /**     Something `Something`.
  *      @p presentTableViewIn:
  *      @brief Creates instance of TubulrVideoTableView
  *      @copyright Louis Tur 2015
  *
  */
+(instancetype)presentTableViewIn:(UIView*)view animated:(BOOL)animated{
    TubulrVideoTableView * classObject = [[[TubulrVideoTableView class] alloc] initWithFrame:view.frame inView:view animated:animated];
    return classObject;
}
+(instancetype)presentTableViewIn:(UIView *)view{
    return [TubulrVideoTableView presentTableViewIn:view animated:NO];
}

/**     initWithFrame:inView: is the designated initializer
 *
 *      this will add an instance of TubulrTableView in the view passed
 */
-(instancetype)initWithFrame:(CGRect)frame inView:(UIView *)view animated:(BOOL)animated{
    self = [super initWithFrame:frame];
    if (self) {
        
        _shouldAnimate = animated ? YES : NO;
        
        _alignmentView  = [[UIView alloc] init];
        _containerView  = [[UIView alloc] init];
        _videoTableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                       style:UITableViewStylePlain];
        
        [_videoTableView registerClass:[TubulrTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
            [UIView animateWithDuration:.6 animations:^{
                [_alignmentView setAlpha:1.0];
            }];
        }
        
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame inView:nil];
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TubulrTableViewCell * cell;
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    }
    cell.textLabel.text = @"Add a video:";

    
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120.0;
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
                                                                       constant:applicationFrame.size.width * .15],
                                         [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_alignmentView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:-(applicationFrame.size.width * .15)],
                                         [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:applicationFrame.size.height * .30],
                                         [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:-(applicationFrame.size.height * .30)]                              ];
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
+(BOOL)requiresConstraintBasedLayout{
    return YES;
    // Custom views should override this to return YES if they
    // can not layout correctly using autoresizing.
}
@end
