//
//  TubulrShareTestsSpec.m
//  TubulrExtension
//
//  Created by Louis Tur on 1/27/15.
//  Copyright 2015 com.SRLabs. All rights reserved.
//

#define EXP_SHORTHAND

#import "ViewController.h"
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

SpecBegin(TubulrShareTests)

describe(@"TubulrShareTests", ^{
    
    __block ViewController * containingApp;
    
    
    beforeAll(^{
        
        containingApp = [[ViewController alloc] init];
        
    });

    beforeEach(^{
        

    });

    it(@"Tubulr Extension should not be nil", ^{
       
        expect(containingApp).notTo.beNil;
        expect(containingApp).to.beInstanceOf([ViewController class]);
        
       // expect(tubulrShareExtension).notTo.beNil;
       // expect(tubulrShareExtension).to.beInstanceOf([ShareViewController class]);
        
    });

    it(@"Should be able to find a share extension", ^{
    
        
    
    });
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
