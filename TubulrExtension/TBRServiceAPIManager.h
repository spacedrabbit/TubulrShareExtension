//
//  ServiceAPIManager.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VimeoVideo, YoutubeVideo;
@interface TBRServiceAPIManager : NSObject

+(instancetype) sharedAPIManager;
-(void) verifyVimeoForID:(NSString *)videoID withHandler:(void(^)(VimeoVideo *))complete;
-(void) verifyYouTubeForID:(NSString *)videoID withHandler:(void(^)(YoutubeVideo *)) complete;
@end
