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

    [self presentTubularView];
    
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

-(void)presentTubularView{
    NSLog(@"Present Tubular View Did finish");
    [TubularView presentInViewController:self];
    
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
            [self dismissShareExtension];
            complete(YES);
        }
    }else{
        complete(NO);
    }
    
    
}
-(void)didPressViewLaterHandler:(void (^)(BOOL))complete{
    [self dismissShareExtension];
    complete(YES);
}
-(void)didPressCancel:(void (^)(void))complete{
    [self dismissShareExtension];
    complete();
}

-(void)dismissShareExtension{
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}


@end
