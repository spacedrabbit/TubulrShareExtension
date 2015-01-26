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

// ------------------------------------------------------------------------------------------//
// will need to get these from NSUserDefaults
static NSString * const kTubulrUser     = @"";
static NSString * const kTubulrSecret   = @"";

// -- URL Component/Constants -- //
static NSString * const kTubulrDomain   = @"group.SRLabs.sharedData";
static NSString * const kTubulrBaseURL  = @"https://tubulr.herokuapp.com/videos/";
static NSString * const kTubulrHeart    = @"submit?heart=";         //POST
static NSString * const kTubulrWatch    = @"submit?watchlater=";    //POST

static NSString * const kYoutubeBaseURL = @"https://www.youtube.com/watch?v=";
// ------------------------------------------------------------------------------------------//



// ----------------------------------INTERFACE-------------------------------------------------//

@interface ShareViewController ()<TubularViewDelegate>

@property (strong, nonatomic) __block NSURL     * currentPageURL;
@property (strong, nonatomic) NSUserDefaults    * sharedTubulrDefaults;
@property (strong, nonatomic) TubularView       * shareVideoView;

@end



// --------------------------------IMPLEMENTATION---------------------------------------------//

@implementation ShareViewController

-(void)viewDidLoad{
    
    NSLog(@"View did load");
    
    // --------- NSUSERDEFAULTS --------- //
    self.sharedTubulrDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTubulrDomain];
    
    
    [self presentTubularView];
    [self inspectExtensionContext:self.extensionContext
                      WithSuccess:^(NSURL * url)
    {
        if (url) {
            NSArray * videos = [self returnVideoURLsFoundIn:url];
            NSLog(@"The videos found: %@", videos);
        }
    }
                            error:^(NSError * error)
    {
        NSLog(@"Encountered an error in context inspection block: %@", error);
    }];
}

-(void) inspectExtensionContext:(NSExtensionContext *)context
                    WithSuccess:(void(^)(NSURL *))success
                          error:(void(^)(NSError *))error
{
    
    // --------- COMPLETION BLOCK ---------- //
    
    NSItemProviderCompletionHandler itemCompletionHandler = ^(id<NSSecureCoding> item, NSError * contextError){
        if (!contextError)
        {
            NSURL * currentPageURL = (NSURL *)item;
            success(currentPageURL);
        }
        else
        {
            error(contextError);
        }
    };

    // --------- INSPECTING EXTENSION CONTEXT --------- //
    
    NSExtensionContext * extensionContext = context;
    NSExtensionItem * extensionItem = [extensionContext.inputItems firstObject];
    
    [extensionItem.attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         //loops through and tries to find a URL in the context
         NSItemProvider * currentItem = (NSItemProvider *)obj;
         if([currentItem hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL])
         {
             //NSLog(@"Current Item: %@", currentItem);
             
             //if an URL is found, its loaded and passed to the completionHandler
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

// not actually implemented anymore, self.currentPageURL isn't used
- (BOOL)isContentValid {
    NSLog(@"Called content valid");
//    if (self.currentPageURL) {
//        NSLog(@"VIDEO URL VALID!");
//        return YES;
//    }else{
//        NSLog(@"URL IS NOT VALID!");
//        return NO;
//    }
    
    return YES;
}




/**********************************************************************************
 *
 *
 *      HTML PARSING TO LOCATE VIDEO LINKS
 *
 *
 ***********************************************************************************/
#pragma mark - LINK PARSING -

-(NSArray *)returnVideoURLsFoundIn:(NSURL *)url{
    
    NSError * urlStringifyError = nil;
    NSString * fullPageHTML = [NSString stringWithContentsOfURL:url
                                                   encoding:NSUTF8StringEncoding
                                                      error:&urlStringifyError];
    
    NSArray * youtubeVideoIDRanges = [self extractYouTubeLinks:fullPageHTML];

    return youtubeVideoIDRanges;
}

-(NSArray *)extractYouTubeLinks:(NSString *)html{
    
    NSMutableSet * uniqueVideoIDs = [[NSMutableSet alloc] init];
    NSError * regexError = nil;
    NSRange htmlRange = NSMakeRange(0, [html length]);
    
    // ------- PATTERN 1 ------ seems to work the best, returns video ID's ----------- //
    NSString * youtubeRegexString = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
    
    //
    //  refactor here
    //
    #pragma _ mark all of the following should be re-written with enumerateMatchesInString:
    NSRegularExpression * youtubeRegex = [NSRegularExpression regularExpressionWithPattern:youtubeRegexString
                                                                                   options:NSRegularExpressionCaseInsensitive error:&regexError];
    //an array of NSTextCheckingResults
    NSArray * rangesOfVideoIDs = [youtubeRegex matchesInString:html
                                                    options:NSMatchingWithTransparentBounds
                                                      range:htmlRange];
    
    for (NSTextCheckingResult * checkingResults in rangesOfVideoIDs)
    {
        NSRange videoIDRange = checkingResults.range;   // gets range from NSTextCheckingResult
        NSString * videoID = [html substringWithRange:videoIDRange];    // gets substring from html
        ([videoID length] < 10) ? : [uniqueVideoIDs addObject:videoID]; // if length > 10, adds to set
    }
    /*
    // Uncomment to check regex results
    // ------------------------------------------------------------------------------------------//
    //    for (NSTextCheckingResult * checkedResult in youtubeVideos)
    //    {
    //        NSRange currentResultRange = checkedResult.range;
    //        NSLog(@"String found: %@", [pageHTML substringWithRange:currentResultRange]);
    //    }
    // ------------------------------------------------------------------------------------------//
    
    // ------- PATTERN 2 ----- doesn't work so well, keeping for reference ----------------------//
    // ------------------------------------------------------------------------------------------//
    //    NSString *pattern = [NSString stringWithUTF8String:@"(?:(?:\\.be\\/|embed\\/|v\\/|\\?v=|\\&v=|\\/videos\\/)|(?:[\\w+]+#\\w\\/\\w(?:\\/[\\w]+)?\\/\\w\\/))([\\w-_]+)".UTF8String];
    //
    // ------------------------------------------------------------------------------------------//
    */
    
    return [uniqueVideoIDs allObjects];
}

-(NSArray *)extractVimeoLinks:(NSString *)html{
    
    return nil;
}



/**********************************************************************************
 *
 *
 *      DELEGATE METHODS (BUTTON HANDLING)
 *
 *
 ***********************************************************************************/
#pragma mark - Tubulr View Delegate Methods -

-(void)didPressHeartHandler:(void (^)(BOOL))complete{
    
    if ([self isContentValid]) {
        
        [self.sharedTubulrDefaults setURL:self.currentPageURL
                                   forKey:self.currentPageURL.absoluteString];
        
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
