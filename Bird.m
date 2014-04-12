//
//  Bird.m
//  LetsKillFlappyBird
//
//  Created by Renan Greca on 4/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bird.h"

@implementation Bird {
    CCNode *_bird;
}

- (void)didLoadFromCCB {
    NSLog(@"This is a bird");
    _bird.physicsBody.collisionType = @"bird";
    _bird.physicsBody.sensor = TRUE;
}


@end
