//
//  TimeManager.m
//  15-Puzzle
//

#import "TimeManager.h"

@interface TimeManager ()
@property (nonatomic, strong, nullable) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval accumulatedTime;
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation TimeManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _accumulatedTime = 0.0;
        _isRunning = NO;
    }
    return self;
}

- (void)startTimer {
    [self stopAndResetTimer];
    self.startTime = [NSDate date];
    self.isRunning = YES;
}

- (void)pauseTimer {
    if (!self.isRunning || !self.startTime) return;
    
    NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:self.startTime];
    self.accumulatedTime += timeSinceStart;
    
    self.startTime = nil;
    self.isRunning = NO;
}

- (void)resumeTimer {
    if (self.isRunning) return;
    self.startTime = [NSDate date];
    self.isRunning = YES;
}

- (void)stopAndResetTimer {
    self.startTime = nil;
    self.accumulatedTime = 0.0;
    self.isRunning = NO;
}

- (NSTimeInterval)totalElapsedTime {
    if (self.isRunning && self.startTime) {
        NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:self.startTime];
        return self.accumulatedTime + timeSinceStart;
    }
    return self.accumulatedTime;
}

@end
