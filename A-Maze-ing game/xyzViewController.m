//
//  xyzViewController.m
//  A-Maze-ing game
//
//  Created by mac on 10/19/13.
//  Copyright (c) 2013 mac. All rights reserved.
//

#import "xyzViewController.h"

@interface xyzViewController ()

@end

@implementation xyzViewController
{
    bool m_frozen;
    int xpts[20];
    int ypts[20];
}

- (void)viewDidLoad
// Movement of pacman
{
    
    xpts[0]=30;
    ypts[0]=30;
    
    xpts[1]=300;
    ypts[1]=100;
    for(int i=2;i<20;++i)
    {
        xpts[i] = i*50-300;
        ypts[i]=i*50-300;
    }
    
    
    m_frozen=false;
    self.lastUpdateTime = [[NSDate alloc] init];
    
    self.currentPoint  = CGPointMake(0, 144);
    self.motionManager = [[CMMotionManager alloc]  init];
    self.queue         = [[NSOperationQueue alloc] init];
    
    self.motionManager.accelerometerUpdateInterval = kUpdateInterval;
    
    [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error) {
         [(id) self setAcceleration:accelerometerData.acceleration];
         [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
     }];

CGPoint origin1 = self.ghost1.center;
CGPoint target1 = CGPointMake(self.ghost1.center.x, self.ghost1.center.y-124);

CABasicAnimation *bounce1 = [CABasicAnimation animationWithKeyPath:@"position.y"];
bounce1.fromValue = [NSNumber numberWithInt:origin1.y];
bounce1.toValue = [NSNumber numberWithInt:target1.y];
bounce1.duration = 2;
bounce1.autoreverses = YES;
bounce1.repeatCount = HUGE_VALF;

[self.ghost1.layer addAnimation:bounce1 forKey:@"position"];

CGPoint origin2 = self.ghost2.center;
CGPoint target2 = CGPointMake(self.ghost2.center.x, self.ghost2.center.y+284);
CABasicAnimation *bounce2 = [CABasicAnimation animationWithKeyPath:@"position.y"];
bounce2.fromValue = [NSNumber numberWithInt:origin2.y];
bounce2.toValue = [NSNumber numberWithInt:target2.y];
bounce2.duration = 2;
bounce2.repeatCount = HUGE_VALF;
bounce2.autoreverses = YES;
[self.ghost2.layer addAnimation:bounce2 forKey:@"position"];

CGPoint origin3 = self.ghost3.center;
CGPoint target3 = CGPointMake(self.ghost3.center.x, self.ghost3.center.y-284);
CABasicAnimation *bounce3 = [CABasicAnimation animationWithKeyPath:@"position.y"];
bounce3.fromValue = [NSNumber numberWithInt:origin3.y];
bounce3.toValue = [NSNumber numberWithInt:target3.y];
bounce3.duration = 2;
bounce3.repeatCount = HUGE_VALF;
bounce3.autoreverses = YES;
[self.ghost3.layer addAnimation:bounce3 forKey:@"position"];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)update {
    
    NSTimeInterval secondsSinceLastDraw = -([self.lastUpdateTime timeIntervalSinceNow]);
    
    if(m_frozen!=true)
    {
        self.pacmanYVelocity = self.pacmanYVelocity - (self.acceleration.x * secondsSinceLastDraw);
        self.pacmanXVelocity = self.pacmanXVelocity - (self.acceleration.y * secondsSinceLastDraw);
    
        CGFloat xDelta = secondsSinceLastDraw * self.pacmanXVelocity * 500;
        CGFloat yDelta = secondsSinceLastDraw * self.pacmanYVelocity * 500;
    
        self.currentPoint = CGPointMake(self.currentPoint.x + xDelta,
                                        self.currentPoint.y + yDelta);
    }
    else
    {
        self.currentPoint  = self.previousPoint;
        self.pacmanXVelocity=0;
        self.pacmanXVelocity=0;
    }
    [self movePacman];
    self.lastUpdateTime = [NSDate date];
    
}
- (void)movePacman {
    
    [self collisionWithExit];
    
    [self collisionWithGhosts];
    
    [self collsionWithWalls];

    [self collisionWithBoundaries];

    self.previousPoint = self.currentPoint;
    
    CGRect frame = self.pacman.frame;
    frame.origin.x = self.currentPoint.x;
    frame.origin.y = self.currentPoint.y;
    
    self.pacman.frame = frame;
    // Rotate the sprite
    
    CGFloat newAngle = (self.pacmanXVelocity + self.pacmanYVelocity) * M_PI * 4;
    self.angle += newAngle * kUpdateInterval;
    
    CABasicAnimation *rotate;
    rotate                     = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue           = [NSNumber numberWithFloat:0];
    rotate.toValue             = [NSNumber numberWithFloat:self.angle];
    rotate.duration            = kUpdateInterval;
    rotate.repeatCount         = 1;
    rotate.removedOnCompletion = NO;
    rotate.fillMode            = kCAFillModeForwards;
    [self.pacman.layer addAnimation:rotate forKey:@"10"];
}
- (void)collisionWithBoundaries {
    
    if (self.currentPoint.x < 0) {
        _currentPoint.x = 0;
        self.pacmanXVelocity = -(self.pacmanXVelocity / 2.0);
    }
    
    if (self.currentPoint.y < 0) {
        _currentPoint.y = 0;
        self.pacmanYVelocity = -(self.pacmanYVelocity / 2.0);
    }
    
    if (self.currentPoint.x > self.view.bounds.size.width - self.pacman.image.size.width) {
        _currentPoint.x = self.view.bounds.size.width - self.pacman.image.size.width;
        self.pacmanXVelocity = -(self.pacmanXVelocity / 2.0);
    }
    
    if (self.currentPoint.y > self.view.bounds.size.height - self.pacman.image.size.height) {
        _currentPoint.y = self.view.bounds.size.height - self.pacman.image.size.height;
        self.pacmanYVelocity = -(self.pacmanYVelocity / 2.0);
    }
    
}
- (void)collisionWithExit {
    
    if (CGRectIntersectsRect(self.pacman.frame, self.exit.frame)) {

        self.currentPoint  = CGPointMake(0, 144);
        m_frozen=true;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                        message:@"You've won the game!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        int i=0;
       for (UIImageView *image in self.wall)
       {
           image.center=CGPointMake(xpts[i],ypts[i]);
           ++i;
       }
    
    }
    
}
- (void)collisionWithGhosts {
    
    CALayer *ghostLayer1 = [self.ghost1.layer presentationLayer];
    CALayer *ghostLayer2 = [self.ghost2.layer presentationLayer];
    CALayer *ghostLayer3 = [self.ghost3.layer presentationLayer];
    
    if (CGRectIntersectsRect(self.pacman.frame, ghostLayer1.frame)
        || CGRectIntersectsRect(self.pacman.frame, ghostLayer2.frame)
        || CGRectIntersectsRect(self.pacman.frame, ghostLayer3.frame) ) {

        self.currentPoint  = CGPointMake(0, 144);
        m_frozen=true;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Mission Failed!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        
    }


}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        [self.motionManager startAccelerometerUpdatesToQueue:self.queue withHandler:
         ^(CMAccelerometerData *accelerometerData, NSError *error) {
             [(id) self setAcceleration:accelerometerData.acceleration];
             [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
         }];
        m_frozen=false;
    }
}
- (void)collsionWithWalls {
    
    CGRect frame = self.pacman.frame;
    frame.origin.x = self.currentPoint.x;
    frame.origin.y = self.currentPoint.y;
    
    for (UIImageView *image in self.wall) {
        
        if (CGRectIntersectsRect(frame, image.frame)) {
            
            // Compute collision angle
            CGPoint pacmanCenter = CGPointMake(frame.origin.x + (frame.size.width / 2),
                                               frame.origin.y + (frame.size.height / 2));
            CGPoint imageCenter  = CGPointMake(image.frame.origin.x + (image.frame.size.width / 2),
                                               image.frame.origin.y + (image.frame.size.height / 2));
            CGFloat angleX = pacmanCenter.x - imageCenter.x;
            CGFloat angleY = pacmanCenter.y - imageCenter.y;
            
            if (abs(angleX) > abs(angleY)) {
                _currentPoint.x = self.previousPoint.x;
                self.pacmanXVelocity = -(self.pacmanXVelocity / 2.0);
            } else {
                _currentPoint.y = self.previousPoint.y;
                self.pacmanYVelocity = -(self.pacmanYVelocity / 2.0);
            }
            
        }
        
    }
    
}

@end
