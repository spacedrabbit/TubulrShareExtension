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

static NSString * const vimeoRegexString = @"(?:vimeo.com/(?:[A-Za-z:]*/?)*|clip_{1}|href=\"/?(?:[A-Za-z:]*/)*)([0-9]{1,})";
static NSString * const youtubeRegexString = @"https?://(?:[0-9A-Z-]+\\.)?(?:youtu\\.be/|youtube(?:-nocookie)?\\.com\\S*[^\\w\\s-])([\\w-]{11})(?=[^\\w-]|$)(?![?=&+%\\w.-]*(?:[\\'\"][^<>]*>| </a>))|(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)|(?<=embed/)([-a-zA-Z0-9_]+)|\\n(?<=videos/)([-a-zA-Z0-9_]+)";

// ------------------------------------------------------------------------------------------//



// ----------------------------------INTERFACE-------------------------------------------------//

@interface ShareViewController ()<TubularViewDelegate>

@property (strong, nonatomic) UIPasteboard      * sharedPasteBoard;

@property (strong, nonatomic) __block NSURL     * currentPageURL;

@property (strong, nonatomic) NSUserDefaults    * sharedTubulrDefaults;

@property (strong, nonatomic) TubularView       * shareVideoView;

@end



// --------------------------------IMPLEMENTATION---------------------------------------------//

@implementation ShareViewController

-(void)viewDidLoad{
    
    // --------- NSUSERDEFAULTS/UIPASTEBOARD --------- //
    self.sharedTubulrDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTubulrDomain];
    self.sharedPasteBoard     = [UIPasteboard generalPasteboard];
    
    
    // --------- SHARE EXTENTION VIEW --------- //
    [self presentTubularView];
    [self checkPasteBoardForURLs]; //this should really check if the URL is a valid video URL
    
    
    // --------- INSPECTING AND RETRIEVING VIDEO IDS --------- //
    [self beginLookingForVideoURLs];
    
    
}

-(void)presentTubularView
{
    // --------- LOADING NIB --------- //
    self.shareVideoView = [TubularView presentInViewController:self];
}

/**********************************************************************************
 *
 *                  CHECKING EXTENSION CONTEXT FOR URLS
 *
 ***********************************************************************************/
#pragma mark - INSPECTING EXTENSION CONTEXT -


-(void) beginLookingForVideoURLs
{
    [self inspectExtensionContext:self.extensionContext
                      WithSuccess:^(NSURL * url)
     {
         if (url) // success indicates a URL was found by the extension
         {
#pragma mark this method needs adjustment
             [self returnVideoURLsFoundIn:url];
             //NSLog(@"The videos found: %@", videos);
         }
         else
         {
             //check pasteboard
         }
     }
                            error:^(NSError * error)
     {
         //update display to indicate no sources found
         NSLog(@"Encountered an error in context inspection block: %@", error);
     }];
    
}

-(void) inspectExtensionContext:(NSExtensionContext *)context
                    WithSuccess:(void(^)(NSURL *))success
                          error:(void(^)(NSError *))error
{
    
    // --------- CONTEXT COMPLETION BLOCK ---------- //
    
    NSItemProviderCompletionHandler itemCompletionHandler = ^(id<NSSecureCoding> item, NSError * contextError){
        if (!contextError)
        {
            NSURL * currentPageURL = (NSURL *)item;
            success(currentPageURL); //bubble up the page URL found by the extension context
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




/**********************************************************************************
 *
 *
 *      HTML PARSING TO LOCATE VIDEO LINKS
 *
 *
 ***********************************************************************************/
#pragma mark - LINK PARSING -

-(void)returnVideoURLsFoundIn:(NSURL *)url
{
    // --------- SPECIFYING UTF8 ENCODING --------- //
    NSError * urlStringifyError = nil;
    NSString * fullPageHTML = [NSString stringWithContentsOfURL:url
                                                       encoding:NSUTF8StringEncoding
                                                          error:&urlStringifyError];
#pragma mark - need to restructure here to handle the addition of blocks
    // --------- GET YOUTUBE VIDEOS --------- //
    NSMutableArray * youtubeVideos = [NSMutableArray array];
    [self returnMatchesforPattern:youtubeRegexString inPage:fullPageHTML completetion:^(NSArray * results) {
        [youtubeVideos addObjectsFromArray:results];
    }];
    // --------- GET VIMEO VIDEOS   --------- //
    NSMutableArray * vimeoVideos = [NSMutableArray array];
    [self returnMatchesforPattern:vimeoRegexString inPage:fullPageHTML completetion:^(NSArray * results) {
        [vimeoVideos addObjectsFromArray:results];
    }];

}


-(void)returnMatchesforPattern:(NSString *)regexPattern inPage:(NSString *)htmlPage completetion:(void (^)(NSArray *)) matchedResults{
    
    __block NSMutableSet * regexMatchedResults = [[NSMutableSet alloc] init]; // prevent duplicates
    NSRange htmlRange = NSMakeRange(0, [htmlPage length]);
    NSError * regexError;
    
    NSRegularExpression * regexExpression =
                                    [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                              options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnixLineSeparators
                                                                                error:&regexError];
    
    [regexExpression enumerateMatchesInString:htmlPage
                                      options:NSMatchingReportProgress|NSMatchingReportCompletion
                                        range:htmlRange
                                   usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        NSRange rangeOfHTMLMatchingRegex = result.range;
        NSString * videoURLMatchingRegex = [htmlPage substringWithRange:rangeOfHTMLMatchingRegex];

        if ([videoURLMatchingRegex length])
        {
            [regexMatchedResults addObject:videoURLMatchingRegex];
            //NSLog(@"This splits up ranges based on capture groups!!");
    #pragma youtube correctly parses out just the ID, so Ill need to do this for vimeo or explicitly state to grab the rangeAtIndex:0
            //NSLog(@"Cap[0]: %@     Cap[1]:   %@", [htmlPage substringWithRange:[result rangeAtIndex:0]], [htmlPage substringWithRange:[result rangeAtIndex:1]]);
            //NSLog(@"Found URL: %@ in range (%lu, %lu)", videoURLMatchingRegex, rangeOfHTMLMatchingRegex.location, rangeOfHTMLMatchingRegex.length);
        }
        
        if (flags & NSMatchingCompleted )
        {
            //NSLog(@"It picks up completed");
            matchedResults((NSArray*)regexMatchedResults);
        }
    }];
    
}


#pragma mark -- PASTEBOARD-SPECIFIC --
-(void) checkPasteBoardForURLs{
    
    // containsPasteboardTypes: only checks first element in pasteboad
    BOOL firstItemInPasteboardIsValid = [self.sharedPasteBoard containsPasteboardTypes:[UIPasteboardTypeListString arrayByAddingObjectsFromArray:UIPasteboardTypeListURL]];
    
    if ( firstItemInPasteboardIsValid )
    {
        #pragma mark potential issue: string attribute will be nil if !UIPasteboardTypeListString
        NSString * copiedURL = self.sharedPasteBoard.string;
        [self isValidURL:copiedURL] ? [self displayPasteBoardURL:copiedURL] : @"URL not valid";
    }
    
}

-(BOOL) isValidURL:(NSString *)url{
    
    NSError * detectorError;
    NSDataDetector * urlDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&detectorError];
    NSTextCheckingResult * urlTypeCheck = [urlDetector firstMatchInString:url
                                                                  options:NSMatchingWithTransparentBounds
                                                                    range:NSMakeRange(0, [url length])];
    
    return urlTypeCheck.numberOfRanges; // returns 0 or 1 based on number of URL ranges found (firstMatch:)
}

-(BOOL) isContentValid{
    //update to include logic that verifies that at least 1 data source has valid URLs
    //whether that be the page URl, the pasteboard, or the content of the page itself.
    return YES;
}



/**********************************************************************************
 *
 *
 *      DELEGATE METHODS (BUTTON HANDLING)
 *
 *
 ***********************************************************************************/
#pragma mark - TUBULR DELEGATE METHODS -

-(void)didPressHeartHandler:(void (^)(BOOL))complete{
    
    if ([self isContentValid])
    {
        
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

-(void)displayPasteBoardURL:(NSString *)url
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.shareVideoView.addVideoURLTextField.text = url;
    }];
}

@end
