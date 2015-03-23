//
//  TBRContextParsingHelper.h
//  TubulrExtension
//
//  Created by Louis Tur on 3/22/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBRContextParsingHelper : NSObject

+(BOOL) currentURLIsYoutube:(NSURL *)url;
+(BOOL) currentURLIsVimeo:(NSURL *)url;

@end
