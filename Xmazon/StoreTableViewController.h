//
//  StoreTableViewController.h
//  Xmazon
//
//  Created by Pierre on 27/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "InscriptionViewController.h"
#import "CategoryTableViewController.h"

@interface StoreTableViewController : UITableViewController {
    NSUserDefaults* uD_;
    NSMutableArray* stores_;
}

@property (strong, nonatomic)NSUserDefaults* uD;
@property (strong, nonatomic)NSMutableArray* stores;

@end
