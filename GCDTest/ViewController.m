//
//  ViewController.m
//  GCDTest
//
//  Created by hu ping kang on 2018/4/22.
//  Copyright © 2018年 hu ping kang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testNSthreadFive];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fiveActionCancelled) name:NSThreadWillExitNotification object:nil];
    
    [self nsLockOne];
    [self nsConditionLock];
    [self initRecycle:5];
    [self synchronizedLock];
    
}

//一.NSThread创建线程，管理线程；
//1.NSThread 创建方式一：
-(void)testNSThreadOne{
    
    NSThread * threadOne = [[NSThread alloc]initWithTarget:self selector:@selector(oneAction) object:nil];
    threadOne.name = @"bigGuy";   //设置线程的名称；
    threadOne.threadPriority = 1; //线程执行的优先级
    [threadOne start];  //开启线程；执行线程任务
    
    //    [threadOne isFinished];      //判断线程是否执行结束
    //    [threadOne isExecuting];     //判断线程是否正在执行任务
    //    [threadOne isCancelled];     //判断线程是否取消
    //    [threadOne cancel];          //取消线程；
    
    //    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1000]];  //当前线程休眠到指定日期
    //    [NSThread mainThread];                //获取主线程
    //    [NSThread currentThread];             //获取当前线程
    //    [NSThread isMultiThreaded];           //判断当前线程是否是多线程
    //    [NSThread isMainThread];              //判断当前线程是否是主线程
    //    [NSThread sleepForTimeInterval:1000]; //当前线程休眠指定时长
    //    [NSThread exit];                      //强行退出当前线程
    //    [NSThread threadPriority];            //获取当前线程的优先级
    //    [NSThread setThreadPriority:1];       //设置当前线程优先级
    
    //callStackReturnAddress和callStackSymbols这两个函数可以同NSLog联合使用来跟踪线程的函数调用情况，是编程调试的重要手段
    //    NSArray * sys = [NSThread callStackSymbols];//返回的是该线程调用函数的名字数字
    //    NSArray * sys = [NSThread callStackReturnAddresses];//返回的是该线程中函数调用的虚拟地址的数组
    
}

-(void)oneAction{
    
    NSLog(@"excuted one action");
    NSLog(@"方式1：%@",[NSThread currentThread]);

}

//2.NSthread创建方式二：iOS 10 以后的方法，效果与1相同；
-(void)testNSthreadTwo{
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"excuted two action");
        NSLog(@"方式2：%@",[NSThread currentThread]);
    }];
    
}

//3.NSThread创建方式三：
-(void)testNSThreadThree{
    //自动创建线程，并马山开启线程执行任务：
    [NSThread detachNewThreadSelector:@selector(threeAction) toTarget:self withObject:nil];
}

-(void)threeAction{
    NSLog(@"excuted three action");
    NSLog(@"方式3：%@",[NSThread currentThread]);
}

//4.NSThread隐式创建线程：
-(void)testNSThreadFour{
    //1.在主线程上执行操作：wait表示是否阻塞该方法，等待主线程空闲再运行；
//    [self performSelectorOnMainThread:@selector(fourAction) withObject:self waitUntilDone:false];
    //2.在当前线程上执行操作：
//    [self performSelector:@selector(fourAction) withObject:self afterDelay:1];
    //3.在子线程上执行操作：本函数是隐式创建一个线程并执行
    [self performSelectorInBackground:@selector(fourAction) withObject:self];
    //4.在特定线程上执行操作：
//    self performSelector:<#(nonnull SEL)#> onThread:<#(nonnull NSThread *)#> withObject:<#(nullable id)#> waitUntilDone:<#(BOOL)#>
    
}

-(void)fourAction{
    NSLog(@"excuted four action");
    NSLog(@"方式4：%@",[NSThread currentThread]);
}
/**
 5.NSThread有三个线程相关的通知
 
 NSWillBecomeMultiThreadedNotification：由当前线程派生出第一个其他线程时发送，一般一个线程只发送一次
 NSDidBecomeSingleThreadedNotification：这个通知目前没有实际意义，可以忽略
 NSThreadWillExitNotification线程退出之前发送这个通知
 
 */

-(void)testNSthreadFive{
    
    [NSThread detachNewThreadWithBlock:^{
       
        NSLog(@"excuted five action");
        //调用cancel方法，当前线程会发送一个线程退出之前的通知；NSThreadWillExitNotification
        [[NSThread currentThread]cancel];
        
    }];
    
}

-(void)fiveActionCancelled{
    NSLog(@"five thread cancelled");
}

//6.线程锁：
/**
 
 线程锁的使用，主要是为了防止多个线程对同一个对象做操作，造成混乱和错误。
 NSLock / NSConditionLock / NSRecursiveLock /  @synchronized
 线程锁大都遵循NSLocking协议，这个协议提供了两个线程锁的基本函数
 - (void)lock;//加锁
 - (void)unlock;//解锁
 
 */

//6.1 NSLock;
/**
 
 - (BOOL)tryLock;//尝试加锁，成功返回YES ；失败返回NO ，但不会阻塞线程的运行
 - (BOOL)lockBeforeDate:(NSDate *)limit;
 //在指定的时间以前得到锁。YES:在指定时间之前获得了锁；NO：在指定时间之前没有获得锁。
 该线程将被阻塞，直到获得了锁，或者指定时间过期。
 @property (nullable, copy) NSString *name;线程锁名称
 
 */

//线程锁的作用：保证多个线程访问操作一个对象属性时，每一次访问操作这个属性的线程只有一个，下一个线程必须等到上一个线程访问操作结束才能访问；
-(void)nsLockOne{
    
    NSLock * myLock = [[NSLock alloc]init];
    __block NSString * str = @"hello";
    myLock.name = @"lockString";
    [NSThread detachNewThreadWithBlock:^{
       
        [myLock lock];
        NSLog(@"%@",str);
        str = @"world";
        [myLock unlock];
        
    }];
    
    [NSThread detachNewThreadWithBlock:^{
        [myLock lock];
        NSLog(@"%@",str);
        str=@"变化了";
        [myLock unlock];
    }];
}

//6.2 NSConditionLock
/**
 
 使用此锁，在线程没有获得锁的情况下，阻塞，即暂停运行，典型用于生产者／消费者模型。
 - (instancetype)initWithCondition:(NSInteger)condition;//初始化条件锁
 - (void)lockWhenCondition:(NSInteger)condition;//加锁 （条件是：锁空闲，即没被占用；条件成立）
 - (BOOL)tryLock; //尝试加锁，成功返回TRUE，失败返回FALSE
 - (BOOL)tryLockWhenCondition:(NSInteger)condition;//在指定条件成立的情况下尝试加锁，成功返回TRUE，失败返回FALSE
 - (void)unlockWithCondition:(NSInteger)condition;//在指定的条件成立时，解锁
 - (BOOL)lockBeforeDate:(NSDate *)limit;//在指定时间前加锁，成功返回TRUE，失败返回FALSE，
 - (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;//条件成立的情况下，在指定时间前加锁，成功返回TRUE，失败返回FALSE，
 @property (readonly) NSInteger condition;//条件锁的条件
 @property (nullable, copy) NSString *name;//条件锁的名称
 
 */

-(void)nsConditionLock{
    
    NSConditionLock * myLock = [[NSConditionLock alloc]init];
    [NSThread detachNewThreadWithBlock:^{
       
        for (int i=0; i<5; i++) {
            [myLock lock];
            NSLog(@"当前解锁条件：%d",i);
            sleep(2);
            [myLock unlockWithCondition:i];
            BOOL isLocked = [myLock tryLockWhenCondition:2];
            if (isLocked) {
                NSLog(@"加锁成功");
                [myLock unlock];
            }
            
        }
        
    }];
    
}

//6.3 NSRecursiveLock
/**
 
 此锁可以在同一线程中多次被使用，但要保证加锁与解锁使用平衡，多用于递归函数，防止死锁。
 - (BOOL)tryLock;//尝试加锁，成功返回TRUE，失败返回FALSE
 - (BOOL)lockBeforeDate:(NSDate *)limit;//在指定时间前尝试加锁，成功返回TRUE，失败返回FALSE
 @property (nullable, copy) NSString *name;//线程锁名称
 
 */

-(void)initRecycle:(int)value
{
    NSRecursiveLock * myRecursive = [[NSRecursiveLock alloc]init];
    [myRecursive lock];
    if(value>0)
    {
        NSLog(@"当前的value值：%d",value);
        sleep(2);
        [self initRecycle:value-1];
    }
    [myRecursive unlock];
}

//6.4 @synchronized
/**

 @synchronized指令做和其他互斥锁一样的工作（它防止不同的线程在同一时间获取同一个锁）
 @synchronized(线程共同使用的对象){
 多个线程使用同一个Obj，都会判断Obj是否已被占用，Obj空闲则用，繁忙则等待
 }

 */

-(void)synchronizedLock{
    
    __block NSString *str=@"hello";
    
    for(int i=0;i<2;i++)
    {
        [NSThread detachNewThreadWithBlock:^{
            @synchronized (str) {
                NSLog(@"thread.name:%@------str:%@",[NSThread currentThread],str);
                str=@"world";
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
