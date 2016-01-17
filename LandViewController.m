//
//  LandViewController.m
//  Switch-40
//
//  Created by 罗玺 on 15/11/2.
//  Copyright © 2015年 罗玺. All rights reserved.
//

#import "LandViewController.h"
#import "Header.h"
#import "StudentViewController.h"
#import "TeacherViewController.h"
#import "TimeViewController.h"

#import "GCDAsyncUdpSocket.h"
#import "CC3xAPManager.h"

#import "Masonry.h"//适配
@interface LandViewController ()<GCDAsyncUdpSocketDelegate>
{
    int numberOfRows;
    NSString *modelTitle;
    NSString *accountText;
    NSString *passwordText;
    
    UIButton *headSecBtn;
    NSArray *array;
    
    NSMutableArray *informationArray;//存储的个人信息的数组
    
    GCDAsyncUdpSocket *udpSocket;
}

@end

@implementation LandViewController

#pragma mark 接收数据
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //监听的端口号6000
    [udpSocket bindToPort:6003 error:Nil];
    //在这里发送开始接受数据
    [udpSocket beginReceiving:nil];
    //开启广播包
    [udpSocket enableBroadcast:YES error:nil];
    
    [self searchIP];
    
}
#pragma mark 关闭Socket
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [udpSocket close];
}

-(void)viewWillAppear:(BOOL)animated
{
    //强制竖屏方法   UIInterfaceOrientationPortrait
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登陆界面";
    self.navigationController.navigationBar.barTintColor = TintColor;
    self.view.backgroundColor = MTGlobalBg;
    
    //创建udpSocket连接
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    informationArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Information"];
    
    modelTitle = informationArray[2];
    _accountTextField.delegate = self;
    _passwordTextField.delegate = self;
    _accountTextField.text = informationArray[0];
    _passwordTextField.text = informationArray[1];
    //_accountTextField.frame = CGRectMake(35, 110, 250, 44);
    _passwordTextField.frame = CGRectMake(35, 160, 250, 44);
    
    [_accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(100);
        make.left.equalTo(self.view).with.offset(30);
        make.right.equalTo(self.view).with.offset(-30);
        make.height.mas_equalTo(@45);
    }];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_accountTextField.mas_bottom).with.offset(20);
        make.left.equalTo(self.view).with.offset(30);
        make.right.equalTo(self.view).with.offset(-30);
        make.height.mas_equalTo(@45);
    }];
    
    self.tableView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    numberOfRows = 1;
    [self creatTable];
    self.tableView.layer.cornerRadius = 5;
    
    self.landButton.backgroundColor = TintColor;
    self.landButton.layer.cornerRadius = 5;
}

#pragma mark 页面登陆按钮事件
- (IBAction)pageLandingButton:(UIButton *)sender
{
    //故事版设置跳转
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    //存储个人信息
    accountText = _accountTextField.text;
    passwordText = _passwordTextField.text;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:accountText,passwordText,modelTitle, nil];
    [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:@"Information"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //老师登陆
    if ([_accountTextField.text isEqualToString:@"teacher"] && [_passwordTextField.text isEqualToString:@"123"] && [modelTitle isEqualToString:@"我是老师"])
    {
        TeacherViewController *teacherVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TeacherVC"];
        [self.navigationController pushViewController:teacherVC animated:YES];
    }
    
    //学生登陆
    if ([_accountTextField.text isEqualToString:@"student"] && [_passwordTextField.text isEqualToString:@"321"] && [modelTitle isEqualToString:@"我是学生"])
    {        
        TimeViewController *timeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TimeVC"];
        [self.navigationController pushViewController:timeVC animated:YES];
    }
}

#pragma mark  Return键盘消失
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 初始化tableView
- (void)creatTable{
    
    
    float aa;
    if (numberOfRows == 1) {
        self.tableView.frame = CGRectMake(35,220, 250, 44.1);
        aa = 44.1;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_passwordTextField.mas_bottom).with.offset(20);
            make.left.equalTo(self.view).with.offset(30);
            make.right.equalTo(self.view).with.offset(-30);
            make.height.mas_equalTo(aa);
        }];
    }else
    {
        self.tableView.frame = CGRectMake(35,220, 250, 132.1);
        aa = 132.1;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_passwordTextField.mas_bottom).with.offset(20);
            make.left.equalTo(self.view).with.offset(30);
            make.right.equalTo(self.view).with.offset(-30);
            make.height.mas_equalTo(aa);
        }];
    }
    
    [self.landButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).with.offset(20);
        make.left.equalTo(self.view).with.offset(30);
        make.right.equalTo(self.view).with.offset(-30);
        make.height.mas_equalTo(@45);
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
#pragma mark
// 这里写成固定值 实际要根据具体的数据而定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * ident = @"ident";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        
        array = @[@"",@"我是老师",@"我是学生"];
        
        if (indexPath.row == 0) {
            //modelTitle = @"请选择模式";
            headSecBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            headSecBtn.frame = CGRectMake(0, 0, 250, 44);
            [headSecBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
            //headSecBtn.backgroundColor = TintColor;
            headSecBtn.layer.cornerRadius = 5;
            [headSecBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [headSecBtn setTitle:informationArray[2] forState:UIControlStateNormal];
            [headSecBtn addTarget:self action:@selector(closeOrOpen:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:headSecBtn];
        }
    }
    
    cell.textLabel.text = array[indexPath.row];
 
    return cell;
}

- (void)closeOrOpen:(UIButton *)sender
{
    if (numberOfRows == 1) {
        numberOfRows = 3;
    }else
    {
        numberOfRows = 1;
    }
    
    [self creatTable];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!indexPath.row == 0) {
        numberOfRows = 1;
        [self creatTable];
        modelTitle = array[indexPath.row];
        [headSecBtn setTitle:array[indexPath.row] forState:UIControlStateNormal];
        accountText = _accountTextField.text;
        passwordText = _passwordTextField.text;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:accountText,passwordText,modelTitle, nil];
        [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:@"Information"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self.tableView reloadData];
    }

}

#pragma mark 发送搜索包
-(void)searchIP
{
    NSString *ipaddress=[[CC3xAPManager sharedInstance] getIPAddress];
    NSArray *iparray= [ipaddress componentsSeparatedByString:@"."];
    if ([iparray count]!=4)
    {
        return;
    }
    int ip1=[[iparray objectAtIndex:0] intValue];
    int ip2=[[iparray objectAtIndex:1] intValue];
    int ip3=[[iparray objectAtIndex:2] intValue];
    int ip4=[[iparray objectAtIndex:3] intValue];
    Byte data[9];
    data[0] = 0x50;
    data[1] = 0xec;
    data[2] = 0xa5;
    data[3] = ip4&0xff;
    data[4] = ip3&0xff;
    data[5] = ip2&0xff;
    data[6] = ip1&0xff;
    data[7] = 0x17;	//5000
    data[8] = 0x70;
    
    NSData *data0 = [[NSData alloc]initWithBytes:data length:9];
    [udpSocket sendData:data0 toHost:@"255.255.255.255" port:5000
            withTimeout:-1 tag:0];
}

//-(BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeRight;
//    //return UIInterfaceOrientationMaskPortrait;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return  UIInterfaceOrientationPortrait;
//}

@end
