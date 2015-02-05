//
//  VimeoVideo.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VimeoVideo : NSObject

@property (strong, nonatomic) NSString * fullURI;
@property (strong, nonatomic) NSString * videoTitle;
@property (strong, nonatomic) NSString * modifiedTime; // "modified_time" = "2015-02-04T11:05:53+00:00";
@property (strong, nonatomic) NSString * imgURL_100x75;
@property (strong, nonatomic) NSString * videoID; // need to add this in
@property (strong, nonatomic) NSString * videoOwner;

-(instancetype)initWithResponse:(NSDictionary *)json;

@end
