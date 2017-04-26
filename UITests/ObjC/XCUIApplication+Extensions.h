//
//  XCUIApplication+Extensions.h
//  PhotoStickers
//
//  Created by Jochen Pfeiffer on 18.04.17.
//  Copyright © 2017 Jochen Pfeiffer. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCUIApplication (Private)
- (id)initPrivateWithPath:(NSString *)path bundleID:(NSString *)bundleID;
- (void)resolve;
- (void)query;
@end

@interface XCUIApplication (Extensions)
+ (instancetype)eps_appWithBundleID:(NSString *)bundleID;
+ (instancetype)eps_iMessagesApp;
+ (instancetype)eps_springboard;
@end
