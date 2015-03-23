//
//  TBRQueueManager.m
//  TubulrExtension
//
//  Created by Louis Tur on 3/9/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "TBRQueueManager.h"

NSString * const kTBRYoutubeQueue = @"com.TBRQueue.youtube";
NSString * const kTBRVimeoQueue = @"com.TBRQueue.vimeo";
NSString * const kTBRMainQueue = @"com.TBRQueue.main";
NSString * const kTBRBackgroundQueue = @"com.TBRQueue.background";

NSString * const kTBRYoutubeObserver = @"youtube";
NSString * const kTBRVimeoObserver = @"vimeo";

@interface TBRQueueManager ()

@property (nonatomic, strong) NSOperationQueue * youtubeQueue;
@property (nonatomic, strong) NSOperationQueue * vimeoQueue;
@property (nonatomic, strong) NSOperationQueue * mainTBRQueue;
@property (nonatomic, strong) NSOperationQueue * backgroundTBRQueue;

@end

@implementation TBRQueueManager

+(instancetype)sharedQueueManager{
    __block TBRQueueManager * sharedQueueManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueueManager = [[TBRQueueManager alloc] init];
    });
    return sharedQueueManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _youtubeQueue       = [[NSOperationQueue alloc] init];
        _vimeoQueue         = [[NSOperationQueue alloc] init];
        _mainTBRQueue       = [[NSOperationQueue alloc] init];
        _backgroundTBRQueue = [[NSOperationQueue alloc] init];
        
        _youtubeQueue.name          = kTBRYoutubeQueue;
        _vimeoQueue.name            = kTBRVimeoQueue;
        _mainTBRQueue.name          = kTBRMainQueue;
        _backgroundTBRQueue.name    = kTBRBackgroundQueue;
        
        _youtubeQueue.qualityOfService          = NSOperationQualityOfServiceUtility;
        _vimeoQueue.qualityOfService            = NSOperationQualityOfServiceUtility;
        _mainTBRQueue.qualityOfService          = NSOperationQualityOfServiceUserInteractive;
        _backgroundTBRQueue.qualityOfService    = NSOperationQualityOfServiceBackground;
        
        _youtubeQueue.maxConcurrentOperationCount       = 10;
        _vimeoQueue.maxConcurrentOperationCount         = 10;
        _mainTBRQueue.maxConcurrentOperationCount       = 20;
        _backgroundTBRQueue.maxConcurrentOperationCount =  4;
    }
    return self;
}

+(NSOperationQueue *)youtubeQueue{
    return [self youtubeQueue];
}
+(NSOperationQueue *)vimeoQueue{
    return [self vimeoQueue];
}
+(NSOperationQueue *)mainTBRQueue{
    return [self mainTBRQueue];
}
+(NSOperationQueue *)backgroundTBRQueue{
    return [self backgroundTBRQueue];
}

@end
