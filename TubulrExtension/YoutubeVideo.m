//
//  YoutubeVideo.m
//  TubulrExtension
//
//  Created by Louis Tur on 2/5/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import "YoutubeVideo.h"
#import "TBRQueueManager.h"

@interface YoutubeVideo ()

@property (strong, nonatomic) NSString * etag;
@property (strong, nonatomic) NSString * videoDescription;

@end

@implementation YoutubeVideo

-(instancetype)initWithResponse:(NSDictionary *)json{
    self = [super init];
    if (self) {
        
        //private
        _etag = json[@"etag"];
        _videoDescription = json[@"snippet"][@"description"];
        
        //public
        _videoID = json[@"id"];
        _videoTitle = json[@"snippet"][@"title"];
        _publishedTime = json[@"snippet"][@"publishedAt"]; // "publishedAt": "2012-12-10T17:06:28.000Z"
        _imgURL_120x90 = json[@"snippet"][@"thumbnails"][@"default"][@"url"];
        _channelID = json[@"snippet"][@"channelId"];
        _channelTitle = json[@"snippet"][@"channelTitle"];
        _imgURL_320x180 = json[@"snippet"][@"thumbnails"][@"medium"][@"url"];
        _imgURL_480x360 = json[@"snippet"][@"thumbnails"][@"high"][@"url"];
        
    }
    
    return self;
}

-(NSString *) videoURL{
    return [NSString stringWithFormat:@"http://youtube.com/%@", self.videoID];
}

@end
