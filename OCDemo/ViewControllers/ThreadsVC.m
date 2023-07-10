//
//  ThreadsVC.m
//  OCDemo
//
//  Created by ByteDance on 2023/7/6.
//

#import "ThreadsVC.h"
#import "PlainTableViewCell.h"
#import <Masonry/Masonry.h>

@interface ThreadsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *data;

@end


@implementation ThreadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = @[
        @"NSThreadIsMain",
        @"useInvocationOperation",
        @"useBlockOperation",
        @"useBlockOperationAddExecutionBlock",
        @"useQueuedInvocationOperation",
        @"useOperationDependency",
        @"GCD_dispatch_sync",
        @"GCD_dispatch_async",
        @"GCD_dispatch_after",
        @"GCD_dispatch_group",
        @"GCD_dispatch_barrier",
        @"GCD_dispatch_once",
    ];
    
    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] init];
//    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlainTableViewCell *cell = [PlainTableViewCell cellWithTableView:tableView];
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 1. 调用字符串对应的方法
    SEL selector = NSSelectorFromString(self.data[indexPath.row]);
    if (![self respondsToSelector:selector]) {
        NSLog(@"Invalid selector: ", self.data[indexPath.row]);
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void*)imp;
    func(self, selector);
    
    // 使点击的高亮效果消失
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Button event handlers

- (void)NSThreadIsMain {
    NSLog(@"%d", [NSThread isMainThread]);
}

- (void)useInvocationOperation {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@1];
    // NSLog(@"%d", op.isAsynchronous);
    
    // 使用start直接启动NSInvocationOperation将导致其在当前线程上运行！！！
    [op start];
}

- (void)useBlockOperation {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self doTimeConsumingTask:@1];
    }];
    [op start];
}

- (void)useBlockOperationAddExecutionBlock {
    // 初始化的block将在主线程执行
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self doTimeConsumingTask:@1];
    }];
    // 添加的block将在其他线程执行
    [op addExecutionBlock:^{
        [self doTimeConsumingTask:@2];
    }];
    [op start];
}

- (void)useQueuedInvocationOperation {
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 可以设置并发执行的线程数量
    // [queue setMaxConcurrentOperationCount:2];
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@1];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@2];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@3];
    NSBlockOperation *op4 = [[NSBlockOperation alloc] init];
    [op4 addExecutionBlock:^{
        [self doTimeConsumingTask:@4];
    }];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue addOperation:op4];
}

- (void)useOperationDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@1];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@2];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doTimeConsumingTask:) object:@3];
    NSBlockOperation *op4 = [[NSBlockOperation alloc] init];
    [op4 addExecutionBlock:^{
        [self doTimeConsumingTask:@4];
    }];
    
    // 定义依赖，op2将在op1和op3之前执行
    [op1 addDependency:op2];
    [op3 addDependency:op2];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue addOperation:op4];
}

- (void)GCD_dispatch_sync {
    // 指定任务被放到哪个队列中
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        [self doTimeConsumingTask:@1];
        NSLog(@"123");
    });
}

- (void)GCD_dispatch_async {
    // 指定任务被放到哪个队列中
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 将耗时操作分派到其他线程，防止阻塞主线程
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@1];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在主线程更新UI
        });
    });
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@2];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在主线程更新UI
        });
    });
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@3];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在主线程更新UI
        });
    });
}

- (void)GCD_dispatch_after {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)2 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"After 2 seconds");
    });
}

- (void)GCD_dispatch_group {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        // 下载文件
        [self doTimeConsumingTask:@1];
        [self doTimeConsumingTask:@1];
    });
    dispatch_group_async(group, queue, ^{
        // 下载图片
        [self doTimeConsumingTask:@2];
    });
    // group内所有任务执行完毕后得到通知。
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 运行在主线程，处理下载后的东西
        NSLog(@"All tasks completed.");
    });
    NSLog(@"All tasks dispatched");
}

- (void)GCD_dispatch_barrier {
    dispatch_queue_t queue = dispatch_queue_create("com.hello", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"Start");
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@1];
    });
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@2];
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"Barrier");
    });
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@3];
    });
    dispatch_async(queue, ^{
        [self doTimeConsumingTask:@4];
    });
    
    NSLog(@"All tasks dispatched");
}

- (void)GCD_dispatch_once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"This block only runs once");
    });
}

#pragma mark Tasks used in threads.

- (void)doTimeConsumingTask:(NSNumber*)index {
    for (int i = 0; i < 2; ++i) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%d---%@", [index intValue], [NSThread currentThread]);
    }
}

@end
