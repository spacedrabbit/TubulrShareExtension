//
//  TBRQueueManager.h
//  TubulrExtension
//
//  Created by Louis Tur on 3/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kTBRYoutubeQueue;
extern NSString * const kTBRVimeoQueue;
extern NSString * const kTBRMainQueue;
extern NSString * const kTBRBackgroundQueue;

extern NSString * const kTBRYoutubeObserver;
extern NSString * const kTBRVimeoObserver;

@interface TBRQueueManager : NSObject

+(instancetype)sharedQueueManager;

+(NSOperationQueue *)youtubeQueue;
+(NSOperationQueue *)vimeoQueue;

+(NSOperationQueue *)backgroundTBRQueue;
+(NSOperationQueue *)mainTBRQueue;

@end
