//
//  CategoryTableViewController.h
//  Xmazon
//
//  Created by Pierre on 27/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "ProduitTableViewController.h"

@interface CategoryTableViewController : UITableViewController {
    NSString* storeName_;
    NSString* storeUid_;
    NSMutableArray* categories_;
}

@property (strong, nonatomic) NSString* storeName;
@property (strong, nonatomic) NSString* storeUid;
@property (strong, nonatomic) NSMutableArray* categories;

@end
