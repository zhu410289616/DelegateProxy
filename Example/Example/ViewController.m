//
//  ViewController.m
//  Example
//
//  Created by 十年之前 on 2024/6/13.
//

#import "ViewController.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <CCDBucket/CCDLogger.h>
#import <CCDDelegateProxy/CCDDelegateDispatcher.h>
#import <CCDDelegateProxy/CCDURLSessionLogger.h>
#import <Masonry/Masonry.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *statusButton;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    self.statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.statusButton.frame = CGRectMake(20, 160, 180, 40);
    [self.statusButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.statusButton setTitle:@"test url session" forState:UIControlStateNormal];
    [self.statusButton addTarget:self action:@selector(startOrStopClient) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.statusButton];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(150);
        make.size.mas_equalTo(CGSizeMake(180, 40));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CCDDelegateAddSubscriber(@"URLSession", [CCDURLSessionLogger sharedInstance]);
    
}

- (void)startOrStopClient
{
    //TODO: test proxy
    [self testDownloadProxy];
//    [self testSessionDelegateProxy];
}

#pragma mark - test session delegate proxy

- (void)testDownloadProxy
{
    static AFURLSessionManager *manager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    });

    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
    [manager.session finishTasksAndInvalidate];
}

- (void)testSessionDelegateProxy
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:20229/log"]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = nil;
    
    NSInteger rand = arc4random() % 2;
    
    if (rand == 0) {
//        CCDURLSessionProxy *proxy = [[CCDURLSessionProxy alloc] initWithOriginal:self];
//        CCDDelegateProxy *proxy = [[CCDDelegateProxy alloc] init];
//        proxy.delegate = self;
//        CCDDelegateSubscriber *sub = [[CCDDelegateSubscriber alloc] init];
//        sub.delegate = [CCDURLSessionLogger sharedInstance];
//        [proxy addSubscriber:sub];
        
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        /// 测试 delegate 形式
        task = [session dataTaskWithRequest:request];
    } else {
        session = [NSURLSession sessionWithConfiguration:configuration];
        /// 测试 block 形式
        task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                DDLogError(@"error: %@", error);
                return;
            }
            NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DDLogInfo(@"test: %@", text);
        }];
    }
    
    [task resume];
    [session finishTasksAndInvalidate];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    NSURLRequest *request = task.originalRequest;
    DDLogDebug(@"[VC] finished:%@:%@", request.HTTPMethod, request.URL.absoluteString);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSURLRequest *request = dataTask.originalRequest;
    DDLogInfo(@"[VC] received:%@:%@:%@", request.HTTPMethod, request.URL.absoluteString, data);
}

@end
