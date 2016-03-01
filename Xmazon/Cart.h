//
//  Cart.h
//  Xmazon
//
//  Created by Pierre on 29/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface Cart : NSObject {
    NSMutableArray<Product*>* products_;
    float totalPrice_;
}

@property (strong, nonatomic) NSMutableArray<Product*>* products;
@property (assign, nonatomic) float totalPrice;

- (instancetype) initWithCart:(Cart*)pCart;
- (NSMutableDictionary*) toDictionary;
- (void) saveCart;
+ (Cart*) retrieveCart;

@end
