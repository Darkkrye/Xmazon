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
#import "Cart.h"

@interface API : NSObject

+ (Cart*) getCart;
+ (void) setCart:(Cart*)pCart;

+ (void) getAppToken;
+ (void) getStoreList;
+ (void) getCategoryListWithStoreUID:(NSString*)storeUID;
+ (void) refreshUserToken;
+ (void) getUserToken;

@end