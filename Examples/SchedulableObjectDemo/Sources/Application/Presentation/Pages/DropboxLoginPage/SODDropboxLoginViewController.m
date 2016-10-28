//
//  SODDropboxLoginViewController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 27.02.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODDropboxLoginViewController.h"
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@interface SODDropboxLoginViewController ()
@property (nonatomic, readonly) NSURL *authURL;
@property (nonatomic, weak, nullable) UIWebView *webView;
@end

@implementation SODDropboxLoginViewController

- (instancetype)initWithAuthURL:(NSURL *)authURL {
    POSRX_CHECK(authURL);
    if (self = [super init]) {
        _authURL = authURL;
    }
    return self;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Link to Dropbox";
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [self p_addWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_webView.canGoBack) {
        [self p_loadAuthPage];
    }
}

#pragma mark Private

- (UIWebView *)p_addWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    return webView;
}

- (void)p_loadAuthPage {
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:_authURL]];
}

@end

NS_ASSUME_NONNULL_END
