//
//  TBRContextParsingHelper.m
//  TubulrExtension
//
//  Created by Louis Tur on 3/22/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TBRContextParsingHelper.h"

@implementation TBRContextParsingHelper

+(BOOL)currentURLIsYoutube:(NSURL *)url{
    NSString * urlToTest = [url absoluteString];
    NSRange range1 = [urlToTest rangeOfString:@"youtube" options:NSCaseInsensitiveSearch];
    NSRange range2 = [urlToTest rangeOfString:@"youtu.be" options:NSCaseInsensitiveSearch];
    
    if ( (range1.location == NSNotFound)  &&  (range2.location == NSNotFound)) {
        return NO;
    }
    return YES;
}
// checks if the page is official Vimeo
+(BOOL)currentURLIsVimeo:(NSURL *)url{
    
    NSString * urlToTest = [url absoluteString];
    NSRange range1 = [urlToTest rangeOfString:@"vimeo" options:NSCaseInsensitiveSearch];
    
    if (range1.location == NSNotFound) {
        return NO;
    }
    return YES;
}

@end
