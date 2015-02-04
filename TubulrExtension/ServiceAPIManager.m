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

// -- Unauthenticated Vimeo Requests -- //
static NSString * const kVimeoToken = @"bearer e8cd186f05e710c0af6c9a610b4b12b4";
static NSString * const kVimeoBaseVideoQueryURL = @"https://api.vimeo.com/videos/";

@interface ServiceAPIManager ()

@property (strong, nonatomic) AFHTTPSessionManager * sessionManager;

@end


@implementation ServiceAPIManager

+(instancetype) sharedVimeoManager{

    static ServiceAPIManager * _sharedVimeoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedVimeoManager = [[ServiceAPIManager alloc] init];
    });
    
    return _sharedVimeoManager;
    
 }

-(instancetype) init{
    self = [super init];
    if (self) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kVimeoBaseVideoQueryURL]
                                                   sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

-(void) verifyVimeoForID:(NSString *)videoID withHandler:(void(^)(VimeoVideo *))complete
{
    
    [self.sessionManager.requestSerializer setValue:kVimeoToken forHTTPHeaderField:@"Authorization"];
    [self.sessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/vnd.vimeo.video+json", @"application/vnd.vimeo.*+json;version=3.2",nil]];
    
    NSURLSessionDataTask * videoVerificationTask = [self.sessionManager GET:videoID
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

@end
