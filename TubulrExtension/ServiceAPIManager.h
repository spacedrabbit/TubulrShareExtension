//
//  ServiceAPIManager.h
//  TubulrExtension
//
//  Created by Louis Tur on 2/4/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VimeoVideo;
@interface ServiceAPIManager : NSObject

+(instancetype) sharedVimeoManager;
-(VimeoVideo *) verifyVimeoForID:(NSString *)videoID;

@end
