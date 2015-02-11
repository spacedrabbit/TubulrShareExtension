//
//  TubularView.m
//  TubulrExtension
//
//  Created by Louis Tur on 1/22/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubularView.h"


@interface TubularViewOwner : NSObject
@property (weak, nonatomic) TubularView * ownedView;
@end
@implementation TubularViewOwner
@end

@interface TubularView ()
@property (nonatomic, weak) UIViewController<TubularViewDelegate> *delegateController;
@end

@implementation TubularView

-(id)initWithCoder:(NSCoder *)aDecoder{
    NSLog(@"Initing with Coder:");
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    return self;
}
/*
-(instancetype)initWithFrame:(CGRect)frame{
    NSLog(@"InitWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(instancetype)init{
    NSLog(@"Regular init");
    self = [super init];
    if (self) {
        
    }
    return self;
}*/

+(instancetype)presentInViewController:(UIViewController<TubularViewDelegate> *)viewController{
    
    // --------- MAGIC ENCAPSULATING CODE --------- //
    //      for the magic behind this code, see:    //
    //      http://eppz.eu/blog/uiview-from-xib/    //
    /*
     *  This method is not in use currently. This implementation
     *  doesn't make sense for this project. But it's nice to
     *  look at. 
     *
     *  The idea here is to create a really encapsulated
     *  view, that just gets called on an existing view controller.
     *  Then it's button actions are defined in this class, but
     *  just make a call to it's delegate. So, you can make a 
     *  single line call with: [TubularView presentInViewController:self]
     *  in (for example) a generic view controller. and then that view
     *  controller would adopt the <TubularViewDelegate> protocol 
     *  methods. In this way, tapping a button on the view simply
     *  redirects the action to the presenting view controller, which
     *  determines the appropriate actions depending on the button. 
     *
     *  Note that this arrangement doesn't allow for you to directly
     *  access the view itself from outside of this class,
     *  you can only manage it through your delegate methods
     *
     *  I'm also not entirely sure of the point of the owner here...
     *  but it works and I don't feel like changing it
     */
    TubularViewOwner * viewOwner = [[TubularViewOwner alloc] init];
    viewOwner.ownedView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                        owner:viewOwner
                                                       options:nil]     firstObject];
    viewOwner.ownedView.delegateController = viewController;
    [viewOwner.ownedView setFrame:viewController.view.frame];
    /**
     *  Update:
     *  This can work as long as in this class method, I specifically
     *  set the frame of the view equal to the viewController
     *
     *  This code is nice in that, there is nothing needed to 
     *  be called on an outside view controller, besides this class
     *  method and it's protocol
     **/
    
    [viewController.view addSubview:viewOwner.ownedView];
    
    return viewOwner.ownedView;
}

-(void)awakeFromNib{
    NSLog(@"Awake from nib");
    
    // ---------- CONTAINERS ---------- //
    
    [_alignmentView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.35]];
    [_saveDialogView setBackgroundColor:[UIColor colorWithRed:42.0/255.00 green:42.0/255.00 blue:42.0/255.00 alpha:1.0]];
    [_saveDialogView.layer setCornerRadius:10.0];
    [_buttonsView setBackgroundColor:[UIColor clearColor]];
    
    // ---------- LABELS / TEXT ------------ //
    
    _addAVideoTextLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0];
    _addVideoURLTextField.backgroundColor =[ UIColor whiteColor];
    _addVideoURLTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    [_addVideoURLTextField.layer setCornerRadius:7.0];
    [_addVideoURLTextField setClearsOnBeginEditing:NO];
    [_addVideoURLTextField setLayoutMargins:UIEdgeInsetsMake(0, 15.0, 0, 5.0)];
    
    _addVideoURLTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    // ------------ BUTTONS ---------- //
    
    _cancelButton.backgroundColor = [UIColor clearColor];
    _cancelButton.titleLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0];
    _heartButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    _heartButton.titleLabel.textColor = [UIColor whiteColor];
    _heartButton.titleLabel.text = @"Heart";
    _watchLaterButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    _watchLaterButton.titleLabel.text = @"Watch Later";
    _watchLaterButton.titleLabel.textColor = [UIColor whiteColor];

}

// buttons all just dismiss the view for now
-(void)heartButtonPressed:(UIButton *)sender{
    [self.delegateController didPressHeartHandler:^(BOOL success) {
        if (success) {
            [self removeFromSuperview];
        }
    }];
}
-(void)watchLaterButtonPressed:(UIButton *)sender{
    [self.delegateController didPressViewLaterHandler:^(BOOL success) {
        if (success) {
            [self removeFromSuperview];
        }
    }];
}
-(void)cancelButtonPressed:(UIButton *)sender{
    [self.delegateController didPressCancel:^{
        [self removeFromSuperview];
    }];
}

-(void) displayPasteBoardURL:(NSString *)url
{
    [self.delegateController displayPasteBoardURL:url];
}

// -- unused -- //
-(void)heartButtonPressedWithCompletion:(void (^)(BOOL))completion{
    NSLog(@"heartbutton pressed!");
    
}
-(void)watchLaterButtonPressedWithCompletion:(void (^)(BOOL))completion{
    NSLog(@"definted in awake from nibe");
    
}
-(void)cancelButtonPressedWithCompletion:(void (^)(BOOL))completion{
    
    
}


@end
