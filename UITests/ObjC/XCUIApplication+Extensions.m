//
//  XCUIApplication+Extensions.m
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 18.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCUIApplication+Extensions.h"

@implementation XCUIApplication (Extensions)
    
+ (instancetype)eps_appWithBundleID:(NSString *)bundleID {
    XCUIApplication *app = [[XCUIApplication alloc] initPrivateWithPath:nil bundleID:bundleID];
    return app;
}
    
+ (instancetype)eps_iMessagesApp {
    static XCUIApplication *_iMessagesApp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iMessagesApp = [[XCUIApplication alloc] initPrivateWithPath:nil bundleID:@"com.apple.MobileSMS"];
    });
    [_iMessagesApp query];
//    [_iMessagesApp resolve];
    return _iMessagesApp;
}

+ (instancetype)eps_springboard
{
    static XCUIApplication *_springboardApp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _springboardApp = [[XCUIApplication alloc] initPrivateWithPath:nil bundleID:@"com.apple.springboard"];
    });
    [_springboardApp query];
    [_springboardApp resolve];
    return _springboardApp;
}
 
@end
