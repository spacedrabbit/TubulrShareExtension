//
//  ShareViewController.m
//  TubulrShare
//
//  Created by Louis Tur on 1/21/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TubularView.h"
#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


static NSString * const kTubulrDomain = @"group.SRLabs.sharedData";



@interface ShareViewController ()<TubularViewDelegate>

@property (strong, nonatomic) __block NSURL  * videoURLToSave;
@property (strong, nonatomic) NSUserDefaults * sharedTubulrDefaults;
@property (strong, nonatomic) TubularView * shareVideoView;

@end


@implementation ShareViewController

-(void)viewDidLoad{
    
    NSLog(@"View did load");
    self.sharedTubulrDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTubulrDomain];

    NSItemProviderCompletionHandler itemCompletionHandler = ^(id<NSSecureCoding> item, NSError * error){
        if (!error) {
            _videoURLToSave = (NSURL *)item;
        }else{
            NSLog(@"Encountered an error in item handler block: %@", error);
        }
    };

    [self presentationAnimationDidFinish];
    
    NSExtensionContext * extensionContext = self.extensionContext;
    NSExtensionItem * extensionItem = [extensionContext.inputItems firstObject];

    [extensionItem.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSItemProvider * currentItem = (NSItemProvider *)obj;
         if([currentItem hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL])
         {
             NSLog(@"Current Item: %@", currentItem);
             [currentItem loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL
                                            options:nil
                                  completionHandler:itemCompletionHandler];
         }
         
     }];
    
}

-(void)presentationAnimationDidFinish{
    
    NSLog(@"Presentation Animation Did finish");

    // --------- LOADING NIB  --------- //
    
    //NSBundle * extensionBundle = [NSBundle bundleForClass:[TubularView class]];
    //NSArray * nibContents = [extensionBundle loadNibNamed:@"TubularView" owner:nil options:nil];
    //self.shareVideoView = [nibContents firstObject];
    
    [TubularView presentInViewController:self];
    //self.shareVideoView
    //[self.shareVideoView setFrame:[UIScreen mainScreen].bounds];
    //[self.shareVideoView layoutIfNeeded];
    
    //[self.view addSubview:self.shareVideoView];
    
    // --------- BUTTON SETUP --------- //
    
//    [self.shareVideoView.cancelButton addTarget:nil
//                                         action:@selector(didPressCancel:)
//                               forControlEvents:UIControlEventTouchUpInside];
//    [self.shareVideoView.heartButton addTarget:nil
//                                        action:@selector(didPressHeartHandler:)
//                              forControlEvents:UIControlEventTouchUpInside];
//    [self.shareVideoView.watchLaterButton addTarget:nil
//                                             action:@selector(didPressViewLaterHandler:)
//                                   forControlEvents:UIControlEventTouchUpInside];
    
}

- (BOOL)isContentValid {
    NSLog(@"Called content valid");
    if (self.videoURLToSave) {
        NSLog(@"VIDEO URL VALID!");
        return YES;
    }else{
        NSLog(@"URL IS NOT VALID!");
        return NO;
    }
}

-(void)didPressHeartHandler:(void (^)(BOOL))complete{
    
    if ([self isContentValid]) {
        
        [self.sharedTubulrDefaults setURL:self.videoURLToSave
                                   forKey:self.videoURLToSave.absoluteString];
        
        if ([self.sharedTubulrDefaults synchronize]) {
            NSLog(@"Bookmark syncronized to NSUser");
            complete(YES);
        }
    }else{
        complete(NO);
    }
    
    
}
-(void)didPressViewLaterHandler:(void (^)(BOOL))complete{
    
}
-(void)didPressCancel:(void (^)(void))complete{
    
}


@end
