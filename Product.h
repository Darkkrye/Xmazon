//
//  Product.h
//  Xmazon
//
//  Created by Pierre on 29/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject {
    BOOL available_;
    NSString* name_;
    NSNumber* price_;
    NSString* uid_;
    NSNumber* quantity_;
    NSString* uidProductCart_;
}

@property (assign, nonatomic) BOOL available;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSNumber* price;
@property (strong, nonatomic) NSString* uid;
@property (strong, nonatomic) NSNumber* quantity;
@property (strong, nonatomic) NSString* uidProductCart;

- (instancetype) initWithAvailability:(NSString*) pAvailable andName:(NSString*)pName andPrice:(NSString*)pPrice andUid:(NSString*)pUid andQuantity:(NSString*)pQuantity andUidProductCart:(NSString*)pUidProductCart;

@end
