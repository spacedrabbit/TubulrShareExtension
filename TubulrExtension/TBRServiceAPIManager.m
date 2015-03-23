//
//  ServiceAPIManager.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AFNetworking/AFNetworking.h>
#import "TBRServiceAPIManager.h"
#import "VimeoVideo.h"
#import "YoutubeVideo.h"

// -- Unauthenticated/Public Vimeo Requests -- //
static NSString * const kVimeoToken = @"bearer e8cd186f05e710c0af6c9a610b4b12b4";
static NSString * const kVimeoBaseVideoQueryURL = @"https://api.vimeo.com/videos/";

// -- Unauthenticated/Public Youtube Requests -- //
static NSString * const kYoutubeKey = @"AIzaSyDJ_x5uyoKi_D7mEOpTlj_iHiFznXrwbZk"; // server service
static NSString * const kYoutubeiOSKey = @"AIzaSyBlLSmK672BOmM1IlCamiD27R-RNRjuV_k"; // ios-specific
static NSString * const kYoutubeBaseVideoQueuryURL = @"https://www.googleapis.com/youtube/v3/videos";

@interface TBRServiceAPIManager ()

@property (strong, nonatomic) AFHTTPSessionManager * vimeoSessionManager;
@property (strong, nonatomic) AFHTTPSessionManager * youtubeSessionsManager;

@end


@implementation TBRServiceAPIManager

+(instancetype) sharedAPIManager{

    static TBRServiceAPIManager * _sharedAPIManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAPIManager = [[TBRServiceAPIManager alloc] init];
    });
    
    return _sharedAPIManager;
    
 }

-(instancetype) init{
    self = [super init];
    if (self)
    {
        _vimeoSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kVimeoBaseVideoQueryURL]
                                                   sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        _youtubeSessionsManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kYoutubeBaseVideoQueuryURL]
                                                           sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

-(void) verifyVimeoForID:(NSString *)videoID withHandler:(void(^)(VimeoVideo *))complete
{
    
    [self.vimeoSessionManager.requestSerializer  setValue:kVimeoToken forHTTPHeaderField:@"Authorization"];
    [self.vimeoSessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/vnd.vimeo.video+json", @"application/vnd.vimeo.*+json;version=3.2", @"application/vnd.vimeo.error+json", nil]];
    
    NSURLSessionDataTask * videoVerificationTask = [self.vimeoSessionManager GET:videoID
                                                                 parameters:nil
                                                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse * videoResponse = (NSHTTPURLResponse *)task.response;
        if (videoResponse.statusCode == 200) {
            
            DDLogDebug(@"Response received for Vimeo check");
            
            VimeoVideo * locatedVideo = [[VimeoVideo alloc] initWithResponse:responseObject];
            complete(locatedVideo);
        }
        else if (videoResponse.statusCode == 404){
            DDLogError(@"404'd on Vimeo");
        }
    }
                                                                    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        DDLogError(@"Failure on Vimeo Query: %@", error);
    }];
    [videoVerificationTask resume];
}

-(void) verifyYouTubeForID:(NSString *)videoID withHandler:(void(^)(YoutubeVideo *)) complete{
    
    [self.youtubeSessionsManager.responseSerializer setAcceptableContentTypes:[NSSet setWithArray:@[@"application/json"]]];
    
    NSURLSessionDataTask * videoVerificationTask = [self.youtubeSessionsManager GET:@""
                                                                         parameters:@{ @"key"   : kYoutubeKey,
                                                                                       @"part"  : @"snippet,id,contentDetails,player",
                                                                                       @"id"    : videoID   }
                                                                            success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse * videoResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary * jsonResponse = (NSDictionary *)responseObject;
        NSNumber * numberOfResults = jsonResponse[@"pageInfo"][@"totalResults"];
        
        DDLogDebug(@"Number of results found: %@", numberOfResults);
        
        if ( (videoResponse.statusCode == 200) && [numberOfResults integerValue] ){
            DDLogDebug(@"YouTube 200 code");
            
            YoutubeVideo * locatedVideo = [[YoutubeVideo alloc] initWithResponse:jsonResponse[@"items"][0]];
            complete(locatedVideo);
        }
        else if (videoResponse.statusCode == 404) {
            DDLogDebug(@"Youtube 404: Video not found");
        }
        else
        {
            DDLogDebug(@"Status code: %lu", videoResponse.statusCode);
            DDLogDebug(@"Number of results: %li", [numberOfResults integerValue]);
        }
        
        complete(nil);
    }
                                                                            failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        DDLogError(@"Failure in Youtube Query: %@", error);
        complete(nil);
    }];
    
    [videoVerificationTask resume];
}

@end
