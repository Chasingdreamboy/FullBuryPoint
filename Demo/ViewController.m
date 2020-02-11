//
//  ViewController.m
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//

#import "ViewController.h"
#import "EWTapGestureRecognizer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EWTapGestureRecognizer *tap = [[EWTapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [self.view addGestureRecognizer:tap];
    
    

    // Do any additional setup after loading the view.
}

- (void)click:(UITapGestureRecognizer *)tap {
    NSLog(@"status == %@", @(tap.state));

    

}


- (IBAction)buttonClick:(id)sender {
    NSLog(@"here!!");
    
}



@end
