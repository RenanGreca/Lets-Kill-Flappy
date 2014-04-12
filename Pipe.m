//
//  Pipe.m
//  LetsKillFlappyBird
//
//  Created by Renan Greca on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Pipe.h"

@implementation Pipe {
    CCNode *_pipe;
}

- (void)didLoadFromCCB {
    _pipe.physicsBody.collisionType = @"level";
    _pipe.physicsBody.sensor = TRUE;
}


@end
