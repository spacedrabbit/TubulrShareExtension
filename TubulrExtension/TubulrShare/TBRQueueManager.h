//
//  TBRQueueManager.h
//  TubulrExtension
//
//  Created by Louis Tur on 3/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBRQueueManager : NSObject

+(instancetype)sharedQueueManager;

+(NSOperationQueue *)youtubeQueue;
+(NSOperationQueue *)vimeoQueue;

+(NSOperationQueue *)backgroundTBRQueue;
+(NSOperationQueue *)mainTBRQueue;

@end
