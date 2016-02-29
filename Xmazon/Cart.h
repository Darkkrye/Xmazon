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
    NSNumber* totalPrice_;
}

@property (strong, nonatomic) NSMutableArray<Product*>* products;
@property (strong, nonatomic) NSNumber* totalPrice;

@end
