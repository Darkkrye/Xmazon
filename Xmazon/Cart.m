//
//  Cart.m
//  Xmazon
//
//  Created by Pierre on 29/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "Cart.h"

@implementation Cart

@synthesize products = products_;
@synthesize totalPrice = totalPrice_;

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.products = [[NSMutableArray alloc] init];
        self.totalPrice = 0.00;
    }
    
    return self;
}

- (instancetype) initWithCart:(Cart*)pCart {
    self = [super init];
    
    if (self) {
        self.products = pCart.products;
        self.totalPrice = pCart.totalPrice;
    }
    
    return self;
}

- (NSMutableDictionary*) toDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSMutableArray* products = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.products.count; i++) {
        [products addObject:[[self.products objectAtIndex:i] toDictionary]];
    }
    
    [dict setObject:products forKey:@"products"];
    [dict setValue:[NSString stringWithFormat:@"%f", self.totalPrice] forKey:@"totalPrice"];
    
    return dict;
}

- (void) saveCart {
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:jsonString forKey:@"panier"];
}

+ (Cart*) retrieveCart {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [userDefaults valueForKey:@"panier"];
    
    NSError *jsonError = nil;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    Cart* cart = [[Cart alloc] init];
    
    if (objectData) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        if (!jsonError) {
            cart.totalPrice = [[json valueForKey:@"totalPrice"] floatValue];
            
            NSMutableArray<NSDictionary*>* productsCart = [json valueForKey:@"products"];
            for (int i = 0; i < productsCart.count; i++) {
                Product* produit = [[Product alloc] init];
                produit.uidProductCart = [[productsCart objectAtIndex:i] valueForKey:@"uidProductCart"];
                
                produit.quantity = [[productsCart objectAtIndex:i] valueForKey:@"quantity"];
                
                produit.available = [[[productsCart objectAtIndex:i] valueForKey:@"available"] boolValue];
                produit.name = [[productsCart objectAtIndex:i] valueForKey:@"name"];
                produit.price = (NSNumber*)[[productsCart objectAtIndex:i] valueForKey:@"price"];
                produit.uid = [[productsCart objectAtIndex:i] valueForKey:@"uid"];
                
                [cart.products addObject:produit];
            }
        }
    }
    
    return cart;
}

@end
