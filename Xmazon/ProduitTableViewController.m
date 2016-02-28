//
//  ProduitTableViewController.m
//  Xmazon
//
//  Created by Pierre on 27/02/2016.
//  Copyright © 2016 Pierre Boudon. All rights reserved.
//

#import "ProduitTableViewController.h"

@interface ProduitTableViewController ()

@end

@implementation ProduitTableViewController

// MARK: - Variables
@synthesize catName = catName_;
@synthesize catUid = catUid_;
@synthesize products = products_;
@synthesize selectedProduct = selectedProduct_;


// MARK: - IBOutlets


// MARK: - IBActions
- (IBAction)addToCart:(id)sender {
    UIButton *button = (UIButton*) sender;
    NSLog(@"ADD TO CART => %@", [[self.products objectAtIndex:button.tag] valueForKey:@"uid"]);
}


// MARK: - Méthodes de base
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self getProductListByCategorie:self.catUid];
    self.products = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

static NSString* const kCellReuseIdentifier = @"ProductCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    if (!cell) {
        //NSLog(@"CREATE Cell");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellReuseIdentifier];
    } else {
        //NSLog(@"REUSE Cell");
    }
    
    NSString* value = [[self.products objectAtIndex:indexPath.row] valueForKey:@"name"];
    cell.textLabel.text = value;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    NSNumber* price = [[self.products objectAtIndex:indexPath.row] valueForKey:@"price"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ €", [fmt stringFromNumber:price]];
    
    if ([[[self.products objectAtIndex:indexPath.row] valueForKey:@"available"] boolValue] == YES) {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self
                   action:@selector(addToCart:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"add-to-cart"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.tag = indexPath.row;
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            if ([[UIScreen mainScreen] bounds].size.width >= 375)
            {
                button.frame = CGRectMake(300, 0, 40.0, 40.0);
            }
            else
            {
                button.frame = CGRectMake(270, 0, 40.0, 40.0);
            }
        }
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [cell.contentView addSubview:button];
    } else {
        
        UILabel* label = [[UILabel alloc] init];
        [label setText:@"Indisponible"];
        [label setTextColor:[UIColor grayColor]];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            if ([[UIScreen mainScreen] bounds].size.width >= 375)
            {
                label.frame = CGRectMake(270, 0, 100.0, 40.0);
            }
            else
            {
                label.frame = CGRectMake(220, 0, 100.0, 40.0);
            }
        }
        
        [cell.contentView addSubview:label];
    }
    
    return cell;
}

//MARK: - Méthodes perso
- (void) getProductListByCategorie:(NSString*)categorieID {
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?category_uid=%@", categorieID]]];
    request.HTTPMethod = @"GET";
    
    if ([userDefaults valueForKey:@"user_token_type"] && [userDefaults valueForKey:@"user_access_token"] && [userDefaults valueForKey:@"user_refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"user_token_type"] capitalizedString], [userDefaults valueForKey:@"user_access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //NSLog(@"ENTER ?");
            if(!error) {
                //NSLog(@"And Now ?");
                NSLog(@"Response getProductList : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else if ([[jsonObjects valueForKey:@"error"] isEqualToString:@"invalid_token"]) {
                    [API getUserToken];
                    [self getProductListByCategorie:categorieID];
                } else {
                    NSLog(@"%@", jsonObjects);
                    NSArray* result = [jsonObjects valueForKey:@"result"];
                    
                    if (result == nil || [result count] == 0) {
                        NSLog(@"Rien");
                    } else {
                        for (int i = 0; i < result.count; i++) {
                            [self.products addObject:[result objectAtIndex:i]];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [self.tableView reloadData];
                        });
                    }
                }
            } else {
                //NSLog(@"HERE HERE : %@", error);
            }
        }] resume];
    } else {
        [API getUserToken];
        [self getProductListByCategorie:categorieID];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
