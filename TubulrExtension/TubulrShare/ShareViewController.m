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
    
    // --------- TESTING REGEX ONLY --------- //
    //[self testingYoutubeURLVariations];
    
}

-(void)presentTubularView
{
    // --------- LOADING NIB --------- //
    self.shareVideoView = [TubularView presentInViewController:self];
}


-(void) testingYoutubeURLVariations{
    
    NSArray * youtubeURLs = @[  @"http://youtu.be/NLqAF9hrVbY",
                                @"http://www.youtube.com/embed/NLqAF9hrVbY",
                                @"https://www.youtube.com/embed/NLqAF9hrVbY",
                                @"http://www.youtube.com/v/NLqAF9hrVbY?fs=1&hl=en_US",
                                @"http://www.youtube.com/v/NLqAF9hrVbY?fs=1&hl=en_US",
                                @"http://www.youtube.com/watch?v=NLqAF9hrVbY",
                                @"http://www.youtube.com/user/Scobleizer#p/u/1/1p3vcRhsYGo",
                                @"http://www.youtube.com/ytscreeningroom?v=NRHVzbJVx8I",
                                @"http://www.youtube.com/sandalsResorts#p/c/54B8C800269D7C1B/2/PPS-8DMrAn4",
                                @"http://gdata.youtube.com/feeds/api/videos/NLqAF9hrVbY",
                                @"http://www.youtube.com/watch?v=spDj54kf-vY&feature=g-vrec",
                                @"http://www.youtube.com/watch?v=spDj54kf-vY&feature=youtu.be",
                                @"http://www.youtube-nocookie.com"                                  ];
    
    NSString * stringOfURLs = [youtubeURLs componentsJoinedByString:@""];
    NSLog(@"Full html string: %@", stringOfURLs);
    NSArray * regexTestResults = [self extractYouTubeLinks:stringOfURLs];
    
    NSLog(@"The extracted URLs: %@", regexTestResults);
    
    
    
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
             NSArray * videos = [self returnVideoURLsFoundIn:url];
             NSLog(@"The videos found: %@", videos);
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


// If the context finds a URL, this will return all valid video links on the page
-(NSArray *)returnVideoURLsFoundIn:(NSURL *)url
{
    // --------- EXTRACT HTML FROM PAGE --------- //
    NSError * urlStringifyError = nil;
    NSString * fullPageHTML = [NSString stringWithContentsOfURL:url
                                                   encoding:NSUTF8StringEncoding
                                                      error:&urlStringifyError];
    
    // --------- GET YOUTUBE VIDEOS --------- //
    NSArray * youtubeVideoIDs = [self extractYouTubeLinks:fullPageHTML];
    
    
    // --------- GET VIMEO VIDEOS --------- //
    NSArray * vimeoVideos = [self extractVimeoLinks:fullPageHTML];

    
    
    return [youtubeVideoIDs arrayByAddingObjectsFromArray:vimeoVideos];
}


// Looks for youtube videos by their unique IDs
-(NSArray *)extractYouTubeLinks:(NSString *)html
{
    NSMutableSet * uniqueVideoIDs = [[NSMutableSet alloc] init];
    NSError * regexError = nil;
    NSRange htmlRange = NSMakeRange(0, [html length]);
    
    
    // ------- REGEX - YOUTUBE ----------- //
    //NSString * youtubeRegexString = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
    NSString * youtubeRegexString = @"https?://(?:[0-9A-Z-]+\\.)?(?:youtu\\.be/|youtube(?:-nocookie)?\\.com\\S*[^\\w\\s-])([\\w-]{11})(?=[^\\w-]|$)(?![?=&+%\\w.-]*(?:[\\'\"][^<>]*>| </a>))|(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)|(?<=embed/)([-a-zA-Z0-9_]+)|\\n(?<=videos/)([-a-zA-Z0-9_]+)";

    #pragma mark * refactor with enumerateMatchesInString: *
    NSRegularExpression * youtubeRegex = [NSRegularExpression regularExpressionWithPattern:youtubeRegexString
                                                                                   options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                                                                     error:&regexError];
    NSArray * rangesOfVideoIDs = [youtubeRegex matchesInString:html
                                                    options:NSMatchingWithTransparentBounds
                                                      range:htmlRange]; //an array of NSTextCheckingResults
    
    for (NSTextCheckingResult * checkingResults in rangesOfVideoIDs)
    {
        NSRange videoIDRange = checkingResults.range;                   // gets range from NSTextCheckingResult
        NSString * videoID = [html substringWithRange:videoIDRange];    // gets substring from html
        //([videoID length] < 10) ? : [uniqueVideoIDs addObject:videoID]; // if length > 10, adds to set
        [uniqueVideoIDs addObject:videoID];
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

// Looks for Vimeo videos
-(NSArray *)extractVimeoLinks:(NSString *)html{
    
    return nil;
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
