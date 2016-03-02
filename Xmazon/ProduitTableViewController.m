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
@synthesize returned = returned_;


// MARK: - IBOutlets


// MARK: - IBActions
- (IBAction)addToCart:(id)sender {
    UIButton *button = (UIButton*) sender;
    NSString* productID = [[self.products objectAtIndex:button.tag] valueForKey:@"uid"];
    NSLog(@"ADD TO CART => %@", productID);
    
    self.returned = YES;
    [self addToCartWithProductId:[[self.products objectAtIndex:button.tag] valueForKey:@"uid"] andQuantity:1];
}

- (IBAction)addToCartDisabled:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"ERREUR"
                                  message:@"Vous avez déjà mis cet article dans votre panier !"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok !"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    UIAlertAction* cart = [UIAlertAction actionWithTitle:@"Voir Panier" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        PanierTableViewController* inscriptionVC = [[PanierTableViewController alloc] init];
        //[self.navigationController modalTransitionStyle];
        [self.navigationController pushViewController:inscriptionVC animated:YES];
    }];
    
    [alert addAction:okButton];
    [alert addAction:cart];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)addToCartLongPress:(id)sender {
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*) sender;
    self.returned = YES;
    [self showAlertForNumberWithName:[[self.products objectAtIndex:recognizer.view.tag] valueForKey:@"name"] andProductId:[[self.products objectAtIndex:recognizer.view.tag] valueForKey:@"uid"] andRetry:NO];
}

- (IBAction)cartButtonTapped:(id)sender {
    PanierTableViewController* inscriptionVC = [[PanierTableViewController alloc] init];
    [self.navigationController modalTransitionStyle];
    [self.navigationController pushViewController:inscriptionVC animated:YES];
}

-(IBAction)showOptions:(UIButton*) sender {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Options" message:@"Que souhaitez-vous faire ?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* search = [UIAlertAction actionWithTitle:@"Faire une recherche" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self searchButtonTapped];
    }];
    UIAlertAction* cart = [UIAlertAction actionWithTitle:@"Afficher le panier" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        PanierTableViewController* inscriptionVC = [[PanierTableViewController alloc] init];
        [self.navigationController modalTransitionStyle];
        [self.navigationController pushViewController:inscriptionVC animated:YES];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:search];
    [alertController addAction:cart];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}


// MARK: - Méthodes de base
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.catUid != nil) {
        [self getProductListByCategorie:self.catUid];
        self.products = [[NSMutableArray alloc] init];
    }
    
    self.navigationItem.title = self.catName;
    
    UIBarButtonItem* optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions:)];
    self.navigationItem.rightBarButtonItem = optionsButton;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTableView)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.products != nil) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"Une erreur de connexion est survenue ou aucun article n'est disponible dans cette categorie.\nTirez pour rafraichir.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return 0;
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
    
    BOOL exists = NO;
    Cart* cart = [API getCart];
    for (int i = 0; i < cart.products.count; i++) {
        if ([[cart.products objectAtIndex:i].name isEqualToString:cell.textLabel.text]) {
            exists = YES;
            break;
        }
    }
    
    if ([[[self.products objectAtIndex:indexPath.row] valueForKey:@"available"] boolValue] == YES) {
        UIButton *button = [[UIButton alloc] init];
        if (exists) {
            [button addTarget:self
                       action:@selector(addToCartDisabled:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:@"add-to-cart-disabled"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setTag:indexPath.row];
        } else {
            [button addTarget:self
                       action:@selector(addToCart:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:@"add-to-cart"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button setTag:indexPath.row];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addToCartLongPress:)];
            [button addGestureRecognizer:longPress];
        }
        
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
                        self.products = nil;
                        [self.tableView reloadData];
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

- (void) addToCartWithProductId:(NSString*)productID andQuantity:(int)quantity {
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/cart/add"]]];
    request.HTTPMethod = @"PUT";
    
    if ([userDefaults valueForKey:@"user_token_type"] && [userDefaults valueForKey:@"user_access_token"] && [userDefaults valueForKey:@"user_refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"user_token_type"] capitalizedString], [userDefaults valueForKey:@"user_access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
        
        NSString* body = [NSString stringWithFormat:@"product_uid=%@&quantity=%i", productID, quantity];
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //NSLog(@"ENTER ?");
            if(!error) {
                //NSLog(@"And Now ?");
                NSLog(@"Response getPCartroductList : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                NSMutableDictionary* jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                } else if ([[jsonObjects valueForKey:@"error"] isEqualToString:@"invalid_token"]) {
                    [API getUserToken];
                    NSLog(@"ERROR ADD CART 1");
                    //                    [self getProductListByCategorie:categorieID];
                } else {
                    NSLog(@"%@", jsonObjects);
                    if (self.returned) {
                        self.returned = NO;
                        [self addToCartWithProductId:productID andQuantity:quantity];
                    } else {
                        NSMutableArray<NSDictionary*>* productsCart = [[jsonObjects valueForKey:@"result"] valueForKey:@"products_cart"];
                        Cart* cart = [[Cart alloc] init];
                        [API setCart:cart];
                        for (int i = 0; i < productsCart.count; i++) {
                            Product* produit = [[Product alloc] init];
                            if ([[productsCart objectAtIndex:i] valueForKey:@"uid"]) {
                                produit.uidProductCart = [[productsCart objectAtIndex:i] valueForKey:@"uid"];
                            }
                            
                            if ([[productsCart objectAtIndex:i] valueForKey:@"quantity"]) {
                                produit.quantity = [[productsCart objectAtIndex:i] valueForKey:@"quantity"];
                            }
                            
                            if ([[productsCart objectAtIndex:i] valueForKey:@"product"]) {
                                produit.available = [[[[productsCart objectAtIndex:i] valueForKey:@"product"] valueForKey:@"available"] boolValue];
                                produit.name = [[[productsCart objectAtIndex:i] valueForKey:@"product"] valueForKey:@"name"];
                                produit.price = (NSNumber*)[[[productsCart objectAtIndex:i] valueForKey:@"product"] valueForKey:@"price"];
                                produit.uid = [[[productsCart objectAtIndex:i] valueForKey:@"product"] valueForKey:@"uid"];
                            }
                            
                            [[API getCart].products addObject:produit];
                            [API getCart].totalPrice = [API getCart].totalPrice + [produit.price floatValue] * [produit.quantity intValue];
                        }
                        
                        [[API getCart] saveCart];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        [self.tableView reloadData];
                    });
                }
            } else {
                //NSLog(@"HERE HERE : %@", error);
            }
        }] resume];
    } else {
        [API getUserToken];
        NSLog(@"ERROR ADD CART 2");
        //        [self getProductListByCategorie:categorieID];
    }
}

- (void) showAlertForNumberWithName:(NSString*)pName andProductId:(NSString*)pUid andRetry:(BOOL)pRetry {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Ajouter au panier" message:[NSString stringWithFormat:@"Combien d'unité du produit %@ souhaitez vous ajouter au panier ?", pName] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        if (pRetry) {
            textField.placeholder = @"Supérieur à 0 et inférieur à 10!";
        } else {
            textField.placeholder = @"Entrez un nombre";
        }
        
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ajouter" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        //NSLog(@"Nombre de produits : %@", [alertController.textFields objectAtIndex:0].text);
        
        int quantity = [[alertController.textFields objectAtIndex:0].text intValue];
        
        if (quantity < 1 || quantity > 9) {
            [self showAlertForNumberWithName:pName andProductId:pUid andRetry:YES];
        } else {
            [self addToCartWithProductId:pUid andQuantity:quantity];
        }
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) searchButtonTapped {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Rechercher" message:@"Rechercher un produit" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Recherche";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Limit";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Offset";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Rechercher" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        NSLog(@"Recherche : %@", [alertController.textFields objectAtIndex:0].text);
        [self getProductListByResearch:[alertController.textFields objectAtIndex:0].text andLimit:[alertController.textFields objectAtIndex:1].text andOffset:[alertController.textFields objectAtIndex:2].text];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) getProductListByResearch:(NSString*)research andLimit:(NSString*)pLimit andOffset:(NSString*)pOffset {
    __block NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURL* url;
    if ([pLimit isEqualToString:@""] && [pOffset isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&offset=%@", research, pOffset]];
    } else if ([pOffset isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&limit=%@", research, pLimit]];
    } else if ([pLimit isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&offset=%@", research, pOffset]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://xmazon.appspaces.fr/product/list?search=%@&limit=%@&offset=%@", research, pLimit, pOffset]];
    }
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    if ([userDefaults valueForKey:@"user_token_type"] && [userDefaults valueForKey:@"user_access_token"] && [userDefaults valueForKey:@"user_refresh_token"]) {
        NSMutableDictionary* headers = [request.allHTTPHeaderFields mutableCopy];
        NSString* authorization = [[NSString alloc] initWithFormat:@"%@ %@", [[userDefaults valueForKey:@"user_token_type"] capitalizedString], [userDefaults valueForKey:@"user_access_token"]];
        [headers setObject:authorization forKey:@"Authorization"];
        request.allHTTPHeaderFields = headers;
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
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
                    [self getProductListByResearch:research andLimit:pLimit andOffset:pOffset];
                } else {
                    NSLog(@"%@", jsonObjects);
                    /*NSArray* result = [jsonObjects valueForKey:@"result"];
                     
                     if (result == nil || [result count] == 0) {
                     NSLog(@"Rien");
                     } else {
                     for (int i = 0; i < result.count; i++) {
                     [self.products addObject:[result objectAtIndex:i]];
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^() {
                     [self.tableView reloadData];
                     });
                     }*/
                }
            } else {
                //NSLog(@"HERE HERE : %@", error);
            }
        }] resume];
    } else {
        [API getUserToken];
        [self getProductListByResearch:research andLimit:pLimit andOffset:pOffset];
    }
}

- (void) refreshTableView {
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d MMM H:mm"];
        NSString *title = [NSString stringWithFormat:@"Dernière MAJ : %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
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
