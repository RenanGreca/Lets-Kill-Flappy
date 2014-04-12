//
//  Bullet.m
//  LetsKillFlappyBird
//
//  Created by joeykrug on 4/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet  {
 CCNode *_bullet;
}

- (void)didLoadFromCCB {
    _bullet.physicsBody.collisionType = @"bullet";
    _bullet.physicsBody.sensor = TRUE;
    _bullet.physicsBody.velocity = ccp(1000.f, 0.f);
}
@end
