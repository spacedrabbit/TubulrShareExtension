//
//  YoutubeVideo.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/5/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubeVideo : NSObject

@property (strong, nonatomic, readonly) NSString * videoID;
@property (strong, nonatomic, readonly) NSString * videoTitle;
@property (strong, nonatomic, readonly) NSString * publishedTime; // "publishedAt": "2015-01-31T23:58:29.000Z",
@property (strong, nonatomic, readonly) NSString * imgURL_120x90;
@property (strong, nonatomic, readonly) NSString * channelTitle;
@property (strong, nonatomic, readonly) NSString * channelID;
@property (strong, nonatomic, readonly) NSString * imgURL_320x180;
@property (strong, nonatomic, readonly) NSString * imgURL_480x360;

-(instancetype)initWithResponse:(NSDictionary *)json;
-(NSString *)videoURL; //convinience

@end
