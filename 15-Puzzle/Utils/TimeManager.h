//
//  TimeManager.h
//  15-Puzzle
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeManager : NSObject

@property (nonatomic, readonly) NSTimeInterval totalElapsedTime;
@property (nonatomic, readonly) BOOL isRunning;

- (void)startTimer;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)stopAndResetTimer;

@end

NS_ASSUME_NONNULL_END
