//
//  ProduitTableViewController.h
//  Xmazon
//
//  Created by Pierre on 27/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"

@interface ProduitTableViewController : UITableViewController {
    NSString* catName_;
    NSString* catUid_;
    NSMutableArray* products_;
    NSString* selectedProduct_;
}

@property (strong, nonatomic) NSString* catName;
@property (strong, nonatomic) NSString* catUid;
@property (strong, nonatomic) NSMutableArray* products;
@property (strong, nonatomic) NSString* selectedProduct;

@end
