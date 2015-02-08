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
#import <TFHpple.h>
#import <AFNetworking/UIButton+AFNetworking.h>

#import "ServiceAPIManager.h"

#import "VimeoVideo.h"
#import "YoutubeVideo.h"
// ------------------------------------------------------------------------------------------//
// will need to get these from NSUserDefaults
static NSString * const kTubulrUser     = @"";
static NSString * const kTubulrSecret   = @"";

// -- URL Component/Constants -- //
static NSString * const kTubulrDomain   = @"group.SRLabs.sharedData";
static NSString * const kTubulrBaseURL  = @"https://tubulr.herokuapp.com/videos/";
static NSString * const kTubulrHeart    = @"submit?heart=";         //POST
static NSString * const kTubulrWatch    = @"submit?watchlater=";    //POST

// -- REGEX Strings -- //
/*  
 *  After some significant difficulty, I've been able to standardize how the regex is being performed on both
 *  Vimeo and Youtube URLs. At a very broad level, it splits the regex search into two parts: 1)the videoID and
 *  2) everything that comes before it (somewhat).
 
 *  Because I'm using the Hpple pod, I'm only pulling out "a" and "iframe" tags (using XPath convention)
 *  and looking at their "href" and "src" properties. Which makes sense, since I'm interested in links that
 *  are presumably live on a web page.
 *
 *  The significant problem was getting the ID's to line up in the same capture group (to make coding simpler)
 *  Compounding this was the fact that the official Youtube and Vimeo webpages use relative URLs rather than absolute
 *  (example, www.vimeo.com/channels/staffpicks/<VideoID> vs. /<VideoID> or clip_<VideoID> or /random/words/<VideoID>)
 *  And not only that, but there are over a dozen ways that youtube formats its URL's, depending on a number of factors.
 *
 *  But because obviously this is going to be easy to forget the intricacies of these expressions, here is a brief explanation:
 *
 *
 *              YOUTUBE
 *  (?:youtu\\.be|                              -- First non-capture group, matches youtu.be OR will match next expression
 *      (?:youtube[-nocookie]?\\.com)           -- Nested non-capture, matches youtube(-nocookie) if it exists, either way it will end in .com
 *      |/watch                                 -- Or will match just /watch
 *  )                                           -- Closes non-capture group
 *      \\S*                                    -- Matches any number of non-white space characters (for long strings of random words)
 *      [^\\w\\s-]                              -- This potentially long string is always ended by a NON-white space, NON-word character or '-'
 *      ([\\w-]{11})                            -- This change in the pattern signals that the video ID is next, and it is always 11 characters
 *                                              -- and/or a dash
 *
 *              VIMEO
 *  (?:                                         -- Start nested, non-capture group
 *      (?:vimeo.com/|                          -- Next non-capture group indicates that either vimeo.com/ or
 *          clip_|                              -- clip_ or
 *          href=\\\"|                          -- href=\\" or
 *          ^/                                  -- a single / at the start of a string will be encountered
 *      )                                       -- Closes innermost nested group
 *      (?:[A-Za-z:/]*)?                        -- After, you will expect to see any number of characters inclusive of a-z:/ .. but the
 *  )                                           -- ? at the end indicates this might not be here at all (in the case of /<VideoID). Closes group.
 *  ([\\d]+)                                    -- This is the second group that is looked for. Indicating that any number of numbers will be present
 *                                              -- There is one slight bug in this, in that this is a bit too loose a definition and sometimes random
 *                                              -- groupings of numbers are matched up. But there are other mechanisms in place to not make this an issue
*/
//https://regex101.com/r/gB0hM2/7   <-- version controlled
static NSString * const youtubeRegexTwoCaptures = @"(?:youtu\\.be|(?:youtube[-nocookie]?\\.com)|/watch)\\S*[^\\w\\s-]([\\w-]{11})";
//https://regex101.com/r/fB1eE7/2   <-- version controlled
static NSString * const vimeoTwoCaptures = @"(?:(?:vimeo.com/|clip_|href=\\\"|^/)(?:[A-Za-z:/]*)?)([\\d]+)";

// ------------------------------------------------------------------------------------------//



// ----------------------------------INTERFACE-------------------------------------------------//

@interface ShareViewController ()<TubularViewDelegate>

@property (strong, nonatomic) UIPasteboard      * sharedPasteBoard;

@property (strong, nonatomic) __block NSURL     * currentPageURL;

@property (strong, nonatomic) NSUserDefaults    * sharedTubulrDefaults;

@property (strong, nonatomic) TubularView       * shareVideoView;

@property (strong, nonatomic) NSMutableSet      * youtubeLinksSet;
@property (strong, nonatomic) NSMutableSet      * vimeoLinksSet;

@property (strong, nonatomic) NSURL * youtubeHTML;
@property (strong, nonatomic) NSString * youtubeMainHTML;

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
    [self scrapeForAllLinks];
    
    // --------- REGEX FULL TESTING --------- //
    //[self testRegexPatternsForYoutubeAndVimeo];
    
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


-(void) scrapeForAllLinks
{
    [self inspectExtensionContext:self.extensionContext WithSuccess:^(NSURL * url)
     {
         if (url) // success means a URL was found by the share extension
         {
             NSData * urlDataToParse = [NSData dataWithContentsOfURL:url];
             TFHpple * parser = [TFHpple hppleWithHTMLData:urlDataToParse];
             NSArray * ahrefNodes = [parser searchWithXPathQuery:@"//a[@href]|//iframe[@src]"]; //array of all <a href>'s
             
             [self parseMediaURLsFrom:ahrefNodes];
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



/**********************************************************************************
 *
 *
 *      HTML PARSING TO LOCATE VIDEO LINKS
 *
 *
 ***********************************************************************************/

-(void) parseMediaURLsFrom:(NSArray *)ahrefList
{
    self.youtubeLinksSet = [NSMutableSet set];
    self.vimeoLinksSet = [NSMutableSet set];
    
    // adds KVO to run link verification as soon as one is found
    [self addObserver:self forKeyPath:@"youtubeLinksSet" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"vimeoLinksSet" options:NSKeyValueObservingOptionNew context:nil];

    for (TFHppleElement * linkElement in ahrefList)
    {
        NSString * currentLink;
        if ( [[linkElement.attributes allKeys] containsObject:@"href"] )
        {
            currentLink = [linkElement objectForKey:@"href"]; //  <a href>
        }
        else if ( [[linkElement.attributes allKeys] containsObject:@"src"]  )
        {
            currentLink = [linkElement objectForKey:@"src"]; //  <iframe src>
        }
        else
        {
            NSLog(@"Some other weird shit: %@", linkElement);
        }

        NSString * youtubeResult    = [self extractMediaLink:currentLink withRegex: youtubeRegexTwoCaptures ];
        NSString * vimeoResult      = [self extractMediaLink:currentLink withRegex: vimeoTwoCaptures        ];
        
        
        // -- KVO Update of Youtube Links -- //
        [self willChangeValueForKey:@"youtubeLinksSet"
                    withSetMutation:NSKeyValueUnionSetMutation
                       usingObjects:[NSSet setWithObjects:youtubeResult, nil ]];
        
        if ( youtubeResult.length )
        {
             [self.youtubeLinksSet addObject:youtubeResult];
        }
        
        [self didChangeValueForKey:@"youtubeLinksSet"
                   withSetMutation:NSKeyValueUnionSetMutation
                      usingObjects:[NSSet setWithObjects:youtubeResult, nil ]];
        // -- KVO Update of Youtube Links -- //
       
        
        
        // -- KVO Update of Vimeo Links -- //
        [self willChangeValueForKey:@"vimeoLinksSet"
                    withSetMutation:NSKeyValueUnionSetMutation
                       usingObjects:[NSSet setWithObjects:vimeoResult, nil ]];
        
        if ( vimeoResult.length ) {
            [self.vimeoLinksSet addObject:vimeoResult];
        }
        
        [self didChangeValueForKey:@"vimeoLinksSet"
                   withSetMutation:NSKeyValueUnionSetMutation
                      usingObjects:[NSSet setWithObjects:vimeoResult, nil ]];
        // -- KVO Update of Vimeo Links -- //
        
    }
    
    NSLog(@"The final: %@", self.youtubeLinksSet);
    
    for (NSString * link in self.youtubeLinksSet) {
        [[ServiceAPIManager sharedAPIManager] verifyYouTubeForID:link withHandler:^(YoutubeVideo * locatedVideo) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.shareVideoView.watchLaterButton setBackgroundImageForState:UIControlStateNormal
                                                                         withURL:[NSURL URLWithString:locatedVideo.imgURL_120x90]];
                
            }];
            
        }];
    }
    
    NSLog(@"The final: %@", self.vimeoLinksSet);
    
    NSCharacterSet * everythingExceptNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    for (NSString * link in self.vimeoLinksSet) {
        NSString * cleanedString = [link stringByTrimmingCharactersInSet:everythingExceptNumbers];
        NSLog(@"The link vimeo is checking: %@", cleanedString);
        [[ServiceAPIManager sharedAPIManager] verifyVimeoForID:cleanedString withHandler:^(VimeoVideo * locatedVideo) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.shareVideoView.heartButton setBackgroundImageForState:UIControlStateNormal
                                                                    withURL:[NSURL URLWithString:locatedVideo.imgURL_100x75] ];
                
            }];
            
        }];
        
    }
    
    
}

-(NSString *) extractMediaLink:(NSString *)link withRegex:(NSString *)regex
{
    NSString * utf8Link = [link stringByRemovingPercentEncoding]; //any last clean up of the string
    NSError * regexError = nil;
    
    NSRegularExpression * regexParser = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                   options: NSRegularExpressionCaseInsensitive
                                                                                            |NSRegularExpressionUseUnixLineSeparators
                                                                                     error:&regexError];
    NSTextCheckingResult * regexResults =  [regexParser firstMatchInString:utf8Link
                                                                   options:0
                                                                     range:NSMakeRange(0, [utf8Link length])];
    
    NSString * matchedResults = [utf8Link substringWithRange:[regexResults rangeAtIndex:1]]; // the second group will always have the ID
    
    return matchedResults.length ? matchedResults : @"";
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //return to run code as a result of the KVO
    if ([keyPath isEqualToString:@"youtubeLinksSet"]) {
       // NSLog(@"Found equal");
    }
    
    //NSLog(@"%@", change);
    
}


-(void) inspectExtensionContext:(NSExtensionContext *)context WithSuccess:(void(^)(NSURL *))success error:(void(^)(NSError *))error
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
             
             //if an URL is found, its loaded and passed to the completionHandler
             [currentItem loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL
                                            options:nil
                                  completionHandler:itemCompletionHandler];
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

/**********************************************************************************
 *
 *
 *      REGEX TESTING --- REMOVE BEFORE DEPLOYING
 *
 *
 ***********************************************************************************/
#pragma mark - Regex testing REMOVE ME LATER -

-(void)testRegexPatternsForYoutubeAndVimeo
{
    NSURL * youtubeBuzzFeed = [[NSBundle mainBundle] URLForResource:@"YoutubeTest_buzzfeed" withExtension:@"html"];
    NSURL * youtubeMain = [[NSBundle mainBundle] URLForResource:@"YoutubeTest_mainpage" withExtension:@"html"];
    NSURL * vimeoMain = [[NSBundle mainBundle] URLForResource:@"VimeoTest_mainpage" withExtension:@"html"];
    NSURL * vimeoCat = [[NSBundle mainBundle] URLForResource:@"VimeoTest_catthoughts" withExtension:@"html"];
    
    NSLog(@"\n\n\n  -------------- YOUTUBE MAIN --------------  \n\n\n");
    [self testParsingForURL:youtubeMain withRegex:youtubeRegexTwoCaptures];
    
    NSLog(@"\n\n\n  -------------- YOUTUBE BUZZFEED --------------  \n\n\n");
    [self testParsingForURL:youtubeBuzzFeed withRegex:youtubeRegexTwoCaptures];
    
    NSLog(@"\n\n\n  -------------- VIMEO MAIN --------------  \n\n\n");
    [self testParsingForURL:vimeoMain withRegex:vimeoTwoCaptures];
    
    NSLog(@"\n\n\n  -------------- VIMEO CATS --------------  \n\n\n");
    [self testParsingForURL:vimeoCat withRegex:vimeoTwoCaptures];
}
-(void)testParsingForURL:(NSURL *)url withRegex:(NSString *)regex
{
    NSData * urlDataToParse = [NSData dataWithContentsOfURL:url];
    TFHpple * parser = [TFHpple hppleWithHTMLData:urlDataToParse];
    NSArray * ahrefNodes = [parser searchWithXPathQuery:@"//a[@href]|//iframe[@src]"]; //array of all <a href>'s
    
    NSArray * results = [self testParseMediaFrom:ahrefNodes withRegex:regex];
    
    NSLog(@"\n\n\n -------- RESULTS FOUND ------- \n\n\n%@",results);
    
}
-(NSArray *)testParseMediaFrom:(NSArray*)ahrefList withRegex:(NSString *)regex
{
    
    NSMutableSet * setOfMatches = [[NSMutableSet alloc] init];
    NSString * currentLink;
    for (TFHppleElement * linkElement in ahrefList)
    {
        if ( [[linkElement.attributes allKeys] containsObject:@"href"] )
        {
            currentLink = [linkElement objectForKey:@"href"]; //  <a href>
        }
        else if ( [[linkElement.attributes allKeys] containsObject:@"src"]  )
        {
            currentLink = [linkElement objectForKey:@"src"]; //  <iframe src>
        }
        else
        {
            NSLog(@"Some other weird shit: %@", linkElement);
        }
        
        NSString * results = [self extractMediaLink:currentLink withRegex:regex];
        if ( results.length ) {
            [setOfMatches addObject:results];
        }
        
    }
    return [setOfMatches allObjects];
}

@end
