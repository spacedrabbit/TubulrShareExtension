//
//  ServiceAPIManager.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//


#import <AFNetworking/AFNetworking.h>
#import "ServiceAPIManager.h"
#import "VimeoVideo.h"
#import "YoutubeVideo.h"

// -- Unauthenticated/Public Vimeo Requests -- //
static NSString * const kVimeoToken = @"bearer e8cd186f05e710c0af6c9a610b4b12b4";
static NSString * const kVimeoBaseVideoQueryURL = @"https://api.vimeo.com/videos/";

// -- Unauthenticated/Public Youtube Requests -- //
static NSString * const kYoutubeKey = @"AIzaSyDJ_x5uyoKi_D7mEOpTlj_iHiFznXrwbZk"; // server service
static NSString * const kYoutubeiOSKey = @"AIzaSyBlLSmK672BOmM1IlCamiD27R-RNRjuV_k"; // ios-specific
static NSString * const kYoutubeBaseVideoQueuryURL = @"https://www.googleapis.com/youtube/v3/videos";

@interface ServiceAPIManager ()

@property (strong, nonatomic) AFHTTPSessionManager * vimeoSessionManager;
@property (strong, nonatomic) AFHTTPSessionManager * youtubeSessionsManager;

@end


@implementation ServiceAPIManager

+(instancetype) sharedAPIManager{

    static ServiceAPIManager * _sharedAPIManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAPIManager = [[ServiceAPIManager alloc] init];
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
    
    [self.vimeoSessionManager.requestSerializer setValue:kVimeoToken forHTTPHeaderField:@"Authorization"];
    [self.vimeoSessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/vnd.vimeo.video+json", @"application/vnd.vimeo.*+json;version=3.2",nil]];
    
    NSURLSessionDataTask * videoVerificationTask = [self.vimeoSessionManager GET:videoID
                                                                 parameters:nil
                                                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse * videoResponse = (NSHTTPURLResponse *)task.response;
        if (videoResponse.statusCode == 200) {
            VimeoVideo * locatedVideo = [[VimeoVideo alloc] initWithResponse:responseObject];
            complete(locatedVideo);
        }
        else if (videoResponse.statusCode == 404){
            
        }
        //NSLog(@"The response: %@", videoResponse);
    }
                                                                    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"Failure: %@", error);
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
        NSUInteger numberOfResults = (NSInteger)jsonResponse[@"pageInfo"][@"totalResults"];
        
        
        if (videoResponse.statusCode == 200 && numberOfResults > 0) // you can have a 200 with 0 results
        {
            NSLog(@"200 code");
            YoutubeVideo * locatedVideo = [[YoutubeVideo alloc] initWithResponse:responseObject];
            complete(locatedVideo);
        }
        else if (videoResponse.statusCode == 404)
        {
            NSLog(@"404: Video not found");
        }
        else
        {
            NSLog(@"Status code: %lu", videoResponse.statusCode);
            NSLog(@"Number of results: %li", numberOfResults);
        }
    }
                                                                            failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"Failure: %@", error);
    }];
    
    [videoVerificationTask resume];
}

@end
