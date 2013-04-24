//
//  MOrderCreateController.m
//  ctrip-mobile
//
//  Created by caoguangyao on 13-4-24.
//  Copyright (c) 2013年 caoguangyao. All rights reserved.
//

#import "MOrderCreateController.h"
#import "NSString+URLEncoding.h"
#import "AFHTTPClient.h"
@interface MOrderCreateController ()

@end

@implementation MOrderCreateController
@synthesize order=_order;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) createOrder
{
    for (int i=0; i<3; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:1];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
        
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                
                UITextField *textField = (UITextField *)view;
                
                NSString *value = textField.text;
                NSString *field = textField.placeholder;
                
                if (value == nil ||[value isEqualToString:@""]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"请输入%@...",field] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    return;
                }
                
                switch (textField.tag) {
                    case 100:
                        if ([NSString NSStringIsValidEmail:value]) {
                            self.order.email = textField.text;
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入有效的Email..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                            [alert release];
                            return;
                        }
                        
                        break;
                    case 101:
                        self.order.mobile = textField.text;
                        break;
                    case 102:
                        self.order.quantity = textField.text;
                        break;
                    default:
                        break;
                }
                
            }
        }
    }
    
    
    
    NSString *url = [NSString stringWithFormat:@"http://ctrip.herokuapp.com/api/create_group_order/?product_id=%@&email=%@&price=%@&mobile=%@&quantity=%@",self.order.productID,self.order.email,self.order.price,self.order.mobile,self.order.quantity];
    
    NSLog(@"80,%@",url);
    
    [self.network getJsonDataWithURL:url];
}

-(void) setJson:(id)json
{
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)json;
        self.order.amount = [dic valueForKey:@"amount"];
        self.order.orderID = [dic valueForKey:@"order_id"];
        self.order.createTime = [dic valueForKey:@"create_time"];
        self.order.price = [dic valueForKey:@"price"];
        self.order.status = [dic valueForKey:@"status"];
        
        //NSString *url = [NSString stringWithFormat:@"http://ctrip.herokuapp.com/api/get_payment/?business_type=Tuan&order_type=6&description=%@&order_id=%@",[self.order.productName URLEncode],self.order.orderID];
        
        NSURL *url = [NSURL URLWithString:@"http://ctrip.herokuapp.com"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.order.description,@"description",
                                self.order.orderID,@"order_id",
                                @"Tuan",@"business_type",
                                @"6",@"order_type"
                                , nil];
        [httpClient postPath:@"/api/get_payment/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"Request Successful, response '%@'", responseStr);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }]; 
        
    }
    else{
        NSLog(@"99");
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"订单";
    
    UIBarButtonItem *btnDone = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(createOrder)] autorelease];
    
    self.navigationItem.rightBarButtonItem = btnDone;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentiy =[NSString stringWithFormat:@"cell%d%d",[indexPath section],[indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentiy];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentiy] autorelease];
        
        int section = [indexPath section];
        int row = [indexPath row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (section == 0 ) {
            if (row == 0) {
                cell.textLabel.text  = self.order.productName;
            }
            else{
                cell.textLabel.text  = [NSString stringWithFormat:@"单价：%@",self.order.price];
            }
        }
        else{
            
            UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(30, 10, 300, 30)]autorelease];
            
            
            if (row == 0) {
                textField.placeholder = @"Email";
                textField.tag = 100;
                textField.keyboardType = UIKeyboardTypeEmailAddress;
            }
            else if (row == 1){
                textField.placeholder =@"手机";
                textField.tag = 101;
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }
            else{
                textField.placeholder = @"数量";
                textField.tag = 102;
                textField.keyboardType = UIKeyboardTypeNumberPad;
                //textField.text = @"1";
            }
            
            [cell addSubview:textField];
        }
    }

    
    return cell;
    
}
@end