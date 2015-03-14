//
//  YoutubeVideo.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/5/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubeVideo : NSObject

@property (strong, nonatomic) NSString * videoID;
@property (strong, nonatomic) NSString * videoTitle;
@property (strong, nonatomic) NSString * publishedTime; // "publishedAt": "2015-01-31T23:58:29.000Z",
@property (strong, nonatomic) NSString * imgURL_120x90;
@property (strong, nonatomic) NSString * channelTitle;
@property (strong, nonatomic) NSString * channelID;

-(instancetype)initWithResponse:(NSDictionary *)json;
-(NSString *)videoURL; //convinience

@end
