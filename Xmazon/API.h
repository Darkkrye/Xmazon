//
//  API.h
//  Xmazon
//
//  Created by Pierre Boudon on 13/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AppDelegate.h"

@interface API : NSObject

+ (void) getAppToken;
+ (void) getUserToken:(NSString*)pEmail andPassword:(NSString*)pPassword;
+ (void) getStoreList;

@end