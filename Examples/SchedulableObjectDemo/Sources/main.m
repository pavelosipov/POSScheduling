//
//  main.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 21.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "SODAppDelegate.h"
#import "SODLogging.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SODAppDelegate class]));
    }
}
