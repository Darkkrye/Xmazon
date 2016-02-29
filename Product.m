//
//  Product.m
//  Xmazon
//
//  Created by Pierre on 29/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "Product.h"

@implementation Product

@synthesize available = available_;
@synthesize name = name_;
@synthesize price = price_;
@synthesize uid = uid_;
@synthesize quantity = quantity_;
@synthesize uidProductCart = uidProductCart_;

- (instancetype) initWithAvailability:(NSString*) pAvailable andName:(NSString*)pName andPrice:(NSString*)pPrice andUid:(NSString*)pUid andQuantity:(NSString*)pQuantity andUidProductCart:(NSString*)pUidProductCart {
    self = [super init];
    
    if (self) {
        self.available = [pAvailable boolValue];
        self.name = pName;
        self.uid = pUid;
        self.uidProductCart = pUidProductCart;
        
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setPositiveFormat:@"0.##"];
        self.price = [fmt numberFromString:pPrice];
        
        NSNumberFormatter* quantityFmt = [[NSNumberFormatter alloc] init];
        [quantityFmt setPositiveFormat:@"0"];
        self.quantity = [fmt numberFromString:pQuantity];
    }
    
    return self;
}

@end
