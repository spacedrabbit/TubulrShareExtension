//
//  TubulrVideoTableView.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubulrVideoTableView.h"

@interface TubulrVideoTableView()

@property (strong, nonatomic) UIView * parentView;

@end

@implementation TubulrVideoTableView


-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        _alignmentView  = [[UIView alloc] init];
        _containerView  = [[UIView alloc] init];
        _videoTableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                       style:UITableViewStylePlain];
    }
    
    return self;
}

// Custom views should override this to return YES if they
// can not layout correctly using autoresizing.
+(BOOL)requiresConstraintBasedLayout{
    return YES;
}

-(void)updateConstraints{

    [_alignmentView     setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_containerView     setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_videoTableView    setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_alignmentView];
    [self addSubview:_containerView];
    [self addSubview:_videoTableView];
    
    [_containerView setBackgroundColor:[UIColor blueColor   ]];

    
     NSArray * constraints = @[
                               
                              [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[alignView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{ @"alignView": _alignmentView }],
                              [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[alignView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{ @"alignView": _alignmentView }],
                            
                              [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{ @"containerView" : _containerView }],
                              [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{ @"containerView" : _containerView }]
                            
                            
                            ] ;
    for (NSArray * constraint in constraints) {
        [self addConstraints:constraint];
    }
    
    [super updateConstraints];
}

@end
