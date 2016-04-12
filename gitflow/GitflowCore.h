//
//  GitflowCore.h
//  gitflow
//
//  Created by Alex Krzyżanowski on 11.04.16.
//  Copyright © 2016 Alex Krzyżanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@interface GitflowCore : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readwrite) NSString *projectDirectoryPath;

- (void)gitFlowInit;

- (void)startFeature:(NSString *)featureName;
- (NSArray<NSString *> *)listFeatures;
- (void)finishFeature:(NSString *)featureName;
- (void)publishFeature:(NSString *)featureName;
- (void)pullFeature:(NSString *)featureName;
@end