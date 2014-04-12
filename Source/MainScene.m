//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "OALSimpleAudio.h"
static
CGFloat _scrollSpeed = 80.f;
static const CGFloat firstObstaclePosition = 580.f;
static const CGFloat distanceBetweenObstacles = 360.f;
static const CGFloat firstBirdPosition = 700.f;
static const CGFloat distanceBetweenBirds = 360.f;
typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderScore,
    DrawingOrderBirds,
    DrawingOrderButton,
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrderBuildings,
    DrawingOrdeHero
};
@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_bullet;
    CCNode *_ground2;
    BOOL _gameOver;
    CCButton *_restartButton;
    CCNode *_ground3;
    CCNode *_ground4;
    NSArray *_grounds;
    
    CCNode *_buildings1;
    CCNode *_buildings2;
    NSArray *_buildings;
    
    double _movement;
    
    NSMutableArray *_obstacles;
    NSMutableArray *_birds;
    NSMutableArray *_bullets;
    
}
- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;

    _grounds = @[_ground1, _ground2, _ground3, _ground4];
    for (CCNode *ground in _grounds) {
        ground.zOrder = DrawingOrderGround;
    }
    _buildings = @[_buildings1, _buildings2];
    /*for (CCNode *building in _buildings) {
        building.zOrder = DrawingOrderBuildings;
    }*/
    
    _physicsNode.collisionDelegate = self;
    
     _restartButton.zOrder = DrawingOrderButton;
    
    _hero.physicsBody.collisionType = @"hero";
    _hero.physicsBody.allowsRotation = FALSE;

    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    _birds = [NSMutableArray array];
    [self spawnNewBird];
    [self spawnNewBird];
    [self spawnNewBird];
    [self spawnNewBird];
 
    _bullets = [NSMutableArray array];
    
    [[OALSimpleAudio sharedInstance] playBg:@"MetalMario.mp3" volume:0.5f pan:0.0f loop:true];
}
- (void)update:(CCTime)delta{
    if(!_gameOver) {
    _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    /*for (CCNode *building in _buildings) {
        // get the world position of the buildings
        CGPoint buildingWorldPosition = [_physicsNode convertToWorldSpace:building.position];
        // get the screen position of the buildings
        CGPoint buildingScreenPosition = [self convertToNodeSpace:buildingWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (buildingScreenPosition.x <= (-1 * building.contentSize.width)) {
            building.position = ccp(building.position.x + 2 * building.contentSize.width, building.position.y);
        }
    }*/
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
    for (CCNode *bird in _birds) {
        if(!_gameOver) {
        //NSLog(@"%f", bird.position.y);
        if (bird.physicsBody.allowsRotation && bird.position.y <= 100) {
            [bird.physicsBody applyImpulse:ccp(0, 250.f)];
            [[OALSimpleAudio sharedInstance] playEffect:@"Flap.mp3" volume:5.0f pitch:1.0f pan:0.0f loop:false];
        }
        }
    }
        
    }
    
}


- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(!_gameOver) {
    
    // Left side of the screen
    if (touch.locationInWorld.x < 320) {
        NSLog(@"Left Touch");
        //[[OALSimpleAudio sharedInstance] playEffect:@"Flap.mp3" volume:5.0f pitch:1.0f pan:0.0f loop:false];
        
        [_hero.physicsBody applyImpulse:ccp(0, 300.f)];
        //[_hero.physicsBody applyAngularImpulse:10000.f];
        //_sinceTouch = 0.f;
        
        // clamp velocity
        //float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
        //_hero.physicsBody.velocity = ccp(0, yVelocity);
    }
    // Right side of the screen
    else {
        NSLog(@"Right Touch");
        CCNode *bullet = [CCBReader load:@"bullet"];
        bullet.position = ccp(_hero.position.x +10 ,_hero.position.y +7);
        //bullet.physicsBody.collisionType = @"bullet";
        [_physicsNode addChild:bullet];
        [_bullets addObject:bullet];
        //[bullet.physicsBody applyImpulse:ccp(1000.f, 0)];
        //while (bullet.position.x < 800) {
        //    [bullet.physicsBody applyImpulse:ccp(0, 10.f)];
        //}
    }
    
    
    }

}

- (void)spawnNewObstacle {
    if(!_gameOver){
    //if (arc4random_uniform(5) == 4) {
        CCNode *previousObstacle = [_obstacles lastObject];
        CGFloat previousObstacleXPosition = previousObstacle.position.x;
        if (!previousObstacle) {
            // this is the first obstacle
            previousObstacleXPosition = firstObstaclePosition;
        }
        CCNode *obstacle = [CCBReader load:@"Pipe"];
        obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 5);
        [_physicsNode addChild:obstacle];
        [_obstacles addObject:obstacle];
        //obstacle.zOrder = DrawingOrderPipes;

    //}
    }
}

- (void)spawnNewBird {
    if(!_gameOver) {
        //if (arc4random_uniform(5) == 4) {
        CCNode *previousBird = [_birds lastObject];
        CGFloat previousBirdXPosition = previousBird.position.x;
        if (!previousBird) {
            // this is the first bird
            previousBirdXPosition = firstBirdPosition;
        }
        CCNode *bird = [CCBReader load:@"purpleBird"];
        bird.position = ccp(previousBirdXPosition + distanceBetweenBirds, 300);
        bird.physicsBody.collisionType = @"bird";
        bird.contentSize = CGSizeMake(bird.contentSize.width*2, bird.contentSize.height*2);
        [_physicsNode addChild:bird];
        [_birds addObject:bird];
        //bird.zOrder = DrawingOrderBirds;
        
        //}
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet bird:(CCNode *)bird {
    
    bird.rotation = 90.f;
    bird.physicsBody.allowsRotation = FALSE;
    [bird stopAllActions];
    [bullet stopAllActions];
    bullet.visible = FALSE;
    [[OALSimpleAudio sharedInstance] playEffect:@"Dead.mp3" volume:5.0f pitch:1.0f pan:0.0f loop:false];

    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero bird:(CCNode *)bird {
    
    if (bird.physicsBody.allowsRotation) {
        _hero.physicsBody.allowsRotation = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        [[OALSimpleAudio sharedInstance] playEffect:@"Dead.mp3" volume:5.0f pitch:1.0f pan:0.0f loop:false];
        [[OALSimpleAudio sharedInstance] stopBg];
        [self gameOver];
    }
    
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)levelkj {
    
    _scrollSpeed = 0.f;
    _hero.rotation = 90.f;
    _hero.physicsBody.allowsRotation = FALSE;
    [_hero stopAllActions];
    [[OALSimpleAudio sharedInstance] playEffect:@"Dead.mp3" volume:5.0f pitch:1.0f pan:0.0f loop:false];
    [[OALSimpleAudio sharedInstance] stopBg];
    [self gameOver];
    
    
    return TRUE;

}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
    _scrollSpeed = 80.f;
}

-(void)gameOver {
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
        
    }
}

@end