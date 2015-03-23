//
//  TBRHTMLRegexTester.m
//  TubulrExtension
//
//  Created by Louis Tur on 3/22/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <TFHpple.h>
#import "TBRHTMLRegexTester.h"

//https://regex101.com/r/gB0hM2/7   <-- version controlled
static NSString * const youtubeRegexTwoCaptures = @"(?:youtu\\.be|(?:youtube[-nocookie]?\\.com)|/watch)\\S*[^\\w\\s-]([\\w-]{11})";
//https://regex101.com/r/fB1eE7/2   <-- version controlled
static NSString * const vimeoTwoCaptures = @"(?:(?:vimeo.com/|clip_|href=\\\"|^/)(?:[A-Za-z:/]*)?)([\\d]+)";

@implementation TBRHTMLRegexTester

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
    
    NSLog(@" -------- RESULTS FOUND ------- \n\n\n%@",results);
    
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

/** Uses the passed regex string to determine if there is a video ID
 @param (NSString*)link FQDN URL extracted from HTML/iFrame tag
 @param (NSString*)regex regex query string
 
 @return The extracted video ID, or empty string if none found
 */
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


@end
