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

// -- REGEX Strings -- //

static NSString * const vimeoRegexString = @"(?:vimeo.com/(?:[A-Za-z:]*/?)*|clip_|href=\\\"/?(?:[A-Za-z:]*/)*)([0-9]{1,})";
static NSString * const vimeoRegexHailMary = @"(?<=vimeo.com/|clip_|href=\\\"/)(?:[A-Za-z:]*/)*?([0-9]+)|(^|/)([0-9]+)[^\\s\"?\\\\/.*&^%$#@!)(&]*";
static NSString * const vimeoRegexHailMaryRefined = @"(?<=vimeo.com/(video/)|clip_|href=\\\"/)[A-Za-z:]*/*?([0-9]+)|(^|/)([0-9]+)[^\\s\"?\\\\/.*&^%$#@!)(&]*";

static NSString * const vimeoRegexRaw = @"(?:vimeo.com/(?:video/|[A-Za-z:]+/)*)([0-9]*)[^\"\\S\\W]*"; //works on non-vimeo sites...fml
static NSString * const vimeoRegexForVimeoSite = @"[href=\"]?/([0-9]*)\"";

static NSString * const youtubeRegexString = @"https?://(?:[0-9A-Z-]+\\.)?(?:youtu\\.be/|youtube(?:-nocookie)?\\.com\\S*[^\\w\\s-])([\\w-]{11})(?=[^\\w-]|$)(?![?=&+%\\w.-]*(?:[\\'\"][^<>]*>| </a>))|(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)|(?<=embed/)([-a-zA-Z0-9_]+)|\\n(?<=videos/)([-a-zA-Z0-9_]+)";

// ------------------------------------------------------------------------------------------//



// ----------------------------------INTERFACE-------------------------------------------------//

@interface ShareViewController ()<TubularViewDelegate>

@property (strong, nonatomic) UIPasteboard      * sharedPasteBoard;

@property (strong, nonatomic) __block NSURL     * currentPageURL;

@property (strong, nonatomic) NSUserDefaults    * sharedTubulrDefaults;

@property (strong, nonatomic) TubularView       * shareVideoView;

@property (strong, nonatomic) NSMutableSet      * youtubeLinksSet;
@property (strong, nonatomic) NSMutableSet      * vimeoLinksSet;

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
    [self inspectExtensionContext:self.extensionContext
                      WithSuccess:^(NSURL * url)
     {
         if (url) // success indicates a URL was found by the extension
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
        
        NSString * currentLink = linkElement.raw; //raw html following <a> tag
        //NSLog(@"THe raw: %@", currentLink);

        NSString * youtubeResult = [self extractMediaLink:currentLink withRegex:youtubeRegexString];
        NSString * vimeoResult = [self extractMediaLink:currentLink withRegex:vimeoRegexRaw];
        
        /*
        // -- KVO Update of Youtube Links -- //
        [self willChangeValueForKey:@"youtubeLinksSet"
                    withSetMutation:NSKeyValueUnionSetMutation
                       usingObjects:[NSSet setWithObjects:youtubeResult, nil ]];
        
        !youtubeResult ? : [self.youtubeLinksSet addObject:youtubeResult];
        [self didChangeValueForKey:@"youtubeLinksSet"
                   withSetMutation:NSKeyValueUnionSetMutation
                      usingObjects:[NSSet setWithObjects:youtubeResult, nil ]];
        // -- KVO Update of Youtube Links -- //
        */
       
        
        
        // -- KVO Update of Vimeo Links -- //
        [self willChangeValueForKey:@"vimeoLinksSet"
                    withSetMutation:NSKeyValueUnionSetMutation
                       usingObjects:[NSSet setWithObjects:vimeoResult, nil ]];
        !vimeoResult   ?    : [self.vimeoLinksSet   addObject:vimeoResult   ];
        [self didChangeValueForKey:@"vimeoLinksSet"
                   withSetMutation:NSKeyValueUnionSetMutation
                      usingObjects:[NSSet setWithObjects:vimeoResult, nil ]];
        // -- KVO Update of Vimeo Links -- //
        
    }
    
    NSLog(@"The final: %@", self.vimeoLinksSet);
    
    NSCharacterSet * everythingExceptNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    for (NSString * link in self.vimeoLinksSet) {
        NSString * cleanedString = [link stringByTrimmingCharactersInSet:everythingExceptNumbers];
        
        [[ServiceAPIManager sharedVimeoManager] verifyVimeoForID:cleanedString withHandler:^(VimeoVideo * locatedVideo) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.shareVideoView.heartButton setBackgroundImageForState:UIControlStateNormal
                                                                    withURL:[NSURL URLWithString:locatedVideo.imgURL_100x75] ];
                
            }];
            
        }];
        
    }
    
    
}

-(NSString *) extractMediaLink:(NSString *)link withRegex:(NSString *)regex
{
    NSString * utf8Link = [link stringByRemovingPercentEncoding];
    NSError * regexError = nil;
    
    NSRegularExpression * regexParser = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                   options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnixLineSeparators
                                                                                     error:&regexError];
    // finds 0 or 1 results in link node
    
    NSTextCheckingResult * regexResults =  [regexParser firstMatchInString:utf8Link
                                                                   options:0
                                                                     range:NSMakeRange(0, [utf8Link length])];

    NSString * matchedResults = [utf8Link substringWithRange:regexResults.range]; // nil or non-nil

    return matchedResults.length ? matchedResults : nil;
    
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

@end
