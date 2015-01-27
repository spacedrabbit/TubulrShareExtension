//
//  TubularView.h
//  TubulrExtension
//
//  Created by Louis Tur on 1/22/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TubularView;

@protocol TubularViewDelegate <NSObject>

-(void)didPressHeartHandler:(void(^)(BOOL success))complete;
-(void)didPressViewLaterHandler:(void(^)(BOOL success))complete;
-(void)didPressCancel:(void(^)(void))complete;

@optional

-(void) displayPasteBoardURL:(NSString *)url;

@end

@interface TubularView : UIView

@property (weak, nonatomic) IBOutlet UIView *alignmentView;

@property (weak, nonatomic) IBOutlet UIView *saveDialogView;
@property (weak, nonatomic) IBOutlet UITextField *addVideoURLTextField;
@property (weak, nonatomic) IBOutlet UILabel *addAVideoTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UIButton *watchLaterButton;

+(instancetype)presentInViewController:(UIViewController *)viewController;

-(IBAction)heartButtonPressed:(UIButton *)sender;
-(IBAction)watchLaterButtonPressed:(UIButton *)sender;
-(IBAction)cancelButtonPressed:(UIButton *)sender;

// -- not used. functions currently handled by buttons themselves
-(void)heartButtonPressedWithCompletion:(void(^)(BOOL))completion;
-(void)watchLaterButtonPressedWithCompletion:(void(^)(BOOL))completion;
-(void)cancelButtonPressedWithCompletion:(void(^)(BOOL))completion;

@end
