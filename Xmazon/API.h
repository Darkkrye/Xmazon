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

@interface API : NSObject

+ (BOOL) getAppToken;
+ (BOOL) getUserToken;

+ (BOOL) subscribeUserWithEmail:(NSString*)pEmail andPassword:(NSString*)pPassword andFirstName:(NSString*)pFirstName andLastName:(NSString*)pLastName;

@end