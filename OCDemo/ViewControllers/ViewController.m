//
//  ViewController.m
//  OCDemo
//
//  Created by ByteDance on 2023/7/6.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "ThreadsVC.h"

@interface ViewController ()

@property (nonatomic) UIButton *threadsBtn;
@property (nonatomic) UIButton *animationBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIStackView *stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisVertical;
        [self.view addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).with.offset(16);
        }];
        
        self.threadsBtn = [UIButton systemButtonWithPrimaryAction:nil];
        [self.threadsBtn setTitle:@"Threads" forState:self.threadsBtn.state];
        [self.threadsBtn addTarget:self action:@selector(onThreadsClicked) forControlEvents:UIControlEventTouchUpInside];
        [stackView addArrangedSubview:self.threadsBtn];
        
        self.animationBtn = [UIButton systemButtonWithPrimaryAction:nil];
        [self.animationBtn setTitle:@"Animation" forState:self.animationBtn.state];
        [self.animationBtn addTarget:self action:@selector(onThreadsClicked) forControlEvents:UIControlEventTouchUpInside];
        [stackView addArrangedSubview:self.animationBtn];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Hello";
        [stackView addArrangedSubview:label];
}

- (void)onThreadsClicked {
    UIViewController *threadsVC = [[ThreadsViewController alloc] init];
//    [self.navigationController showViewController:threadsVC sender:nil];
    [self.navigationController pushViewController:threadsVC animated:YES];
    
}


@end
