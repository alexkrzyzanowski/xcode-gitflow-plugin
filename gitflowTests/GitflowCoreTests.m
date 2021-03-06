//
//  GitflowCoreTests.m
//  gitflow
//
//  Created by Alex Krzyżanowski on 12.04.16.
//  Copyright © 2016 Alex Krzyżanowski. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GitflowCore.h"
#import "ShellCore.h"


@interface GitflowCoreTests : XCTestCase

@property (nonatomic, strong, readwrite) GitflowCore *testableGitflowCore;
@end


@implementation GitflowCoreTests

- (void)setUp {
    [super setUp];
    
    self.testableGitflowCore = [GitflowCore sharedInstance];
    self.testableGitflowCore.projectDirectoryPath = [[NSBundle bundleForClass:[self class]] resourcePath];
    
    ShellCore *shellCore = [ShellCore sharedInstance];
    
    [shellCore executeCommand:@"git"
                withArguments:@[ @"init" ]
                  inDirectory:self.testableGitflowCore.projectDirectoryPath];
    
    [shellCore executeCommand:@"touch"
                withArguments:@[ @"file.txt" ]
                  inDirectory:self.testableGitflowCore.projectDirectoryPath];

    [shellCore executeCommand:@"git"
                withArguments:@[ @"add", @"file.txt" ]
                  inDirectory:self.testableGitflowCore.projectDirectoryPath];

    [shellCore executeCommand:@"git"
                withArguments:@[ @"commit", @"-m \"Initial commit\"" ]
                  inDirectory:self.testableGitflowCore.projectDirectoryPath];
    
    [self logBranches];
}

- (void)tearDown {
    [[ShellCore sharedInstance] executeCommand:@"rm"
                                 withArguments:@[ @"-rf", @".git" ]
                                   inDirectory:self.testableGitflowCore.projectDirectoryPath];
    
    [super tearDown];
}

- (void)testGitflowInitialization {
    [self.testableGitflowCore gitFlowInit];
    
    [self logBranches];
    
    NSString *branchesOutput = [[ShellCore sharedInstance] executeCommand:@"git"
                                                            withArguments:@[ @"branch" ]
                                                              inDirectory:self.testableGitflowCore.projectDirectoryPath];
    XCTAssertTrue([branchesOutput containsString:@"master"]);
    XCTAssertTrue([branchesOutput containsString:@"develop"]);
}

- (void)testShellArgumentsComposition {
    NSString *testAction = @"start";
    NSString *testEntity = @"release";
    NSString *testName = @"testRelease";
    NSArray *testParameters = @[ @"-m", @"some-message" ];
    
    NSArray *testShellArguments = @[ testEntity, testAction, testParameters[0], testParameters[1], testName ];
    
    NSArray *shellArguments = [self.testableGitflowCore shellArgumentsForAction:testAction
                                                                      forEntity:testEntity
                                                                       withName:testName
                                                       withAdditionalParameters:testParameters];
    
    XCTAssertEqualObjects(testShellArguments, shellArguments);
}

- (void)testFeatureStarting {
    NSString *testFeature = @"test-feature";
    NSString *testBranch = [NSString stringWithFormat:@"feature/%@", testFeature];
    [self.testableGitflowCore gitFlowInit];
    [self.testableGitflowCore doAction:kGitflowActionStart
                            withEntity:kGitflowEntityFeature
                              withName:testFeature
                  additionalParameters:nil];
    
    [self logBranches];
    
    NSString *branchesOutput = [[ShellCore sharedInstance] executeCommand:@"git"
                                                            withArguments:@[ @"branch" ]
                                                              inDirectory:self.testableGitflowCore.projectDirectoryPath];
    XCTAssertTrue([branchesOutput containsString:testBranch]);
    XCTAssertTrue([branchesOutput containsString:@"master"]);
    XCTAssertTrue([branchesOutput containsString:@"develop"]);
}

- (void)testFeatureListing {
    NSArray<NSString *> *testBranchList = @[ @"new-function", @"another-function" ];
    
    [self.testableGitflowCore gitFlowInit];
    [self.testableGitflowCore doAction:kGitflowActionStart
                            withEntity:kGitflowEntityFeature
                              withName:testBranchList[0]
                  additionalParameters:nil];
    [self.testableGitflowCore doAction:kGitflowActionStart
                            withEntity:kGitflowEntityFeature
                              withName:testBranchList[1]
                  additionalParameters:nil];
    
    [self logBranches];
    
    NSArray<NSString *> *branchList = [self.testableGitflowCore listEntity:kGitflowEntityFeature];
    
    for (NSString *testBranch in testBranchList) {
        XCTAssertTrue([branchList containsObject:testBranch]);
    }
}

- (void)testFeatureFinishing {
    NSString *testFeature = @"test-feature";
    NSString *testBranch = [NSString stringWithFormat:@"feature/%@", testFeature];
    [self.testableGitflowCore gitFlowInit];
    [self.testableGitflowCore doAction:kGitflowActionStart
                            withEntity:kGitflowEntityFeature
                              withName:testFeature
                  additionalParameters:nil];
    
    [self logBranches];
    
    NSString *branchesOutput = [[ShellCore sharedInstance] executeCommand:@"git"
                                                            withArguments:@[ @"branch" ]
                                                              inDirectory:self.testableGitflowCore.projectDirectoryPath];
    XCTAssertTrue([branchesOutput containsString:testBranch]);
    XCTAssertTrue([branchesOutput containsString:@"master"]);
    XCTAssertTrue([branchesOutput containsString:@"develop"]);
    
    [self.testableGitflowCore doAction:kGitflowActionFinish
                            withEntity:kGitflowEntityFeature
                              withName:testFeature
                  additionalParameters:nil];
    
    [self logBranches];
    
    branchesOutput = [[ShellCore sharedInstance] executeCommand:@"git"
                                                  withArguments:@[ @"branch" ]
                                                    inDirectory:self.testableGitflowCore.projectDirectoryPath];
    XCTAssertFalse([branchesOutput containsString:testBranch]);
    XCTAssertTrue([branchesOutput containsString:@"master"]);
    XCTAssertTrue([branchesOutput containsString:@"develop"]);
}

- (void)logBranches {
    NSString *branchList = [[ShellCore sharedInstance] executeCommand:@"git"
                                                        withArguments:@[ @"branch" ]
                                                          inDirectory:self.testableGitflowCore.projectDirectoryPath];
    NSLog(@"Testable branch list: %@", branchList);
}

@end
