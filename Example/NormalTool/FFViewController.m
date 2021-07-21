//
//  FFViewController.m
//  NormalTool
//
//  Created by 冯振伟 on 07/21/2021.
//  Copyright (c) 2021 冯振伟. All rights reserved.
//

#import "FFViewController.h"
#import "KKTool.h"
#import "FFLanguageConfig.h"

@interface FFViewController ()

@end

@implementation FFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    FFLanguageConfig.userLanguage = @"en";
    KKTool *tool = KKTool.new;
    [tool say];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
