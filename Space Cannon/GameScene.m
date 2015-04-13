//
//  GameScene.m
//  Space Cannon
//
//  Created by Samuel Peterson on 4/4/15.
//  Copyright (c) 2015 Samuel Peterson. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene
{
    SKNode *_mainlayer;
    SKSpriteNode *_cannon;
    //BOOL _didShoot;
}

static const CGFloat SHOOT_SPEED = 1000.0f;

static inline CGVector radiansToVector(CGFloat radians)
{
    CGVector Vector;
    Vector.dx = cosf(radians);
    Vector.dy = sinf(radians);
    return Vector;
}
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    //add background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"starfield"];
    //background.position = CGPointZero;
    //background.anchorPoint = CGPointZero;
    background.blendMode = SKBlendModeReplace;
    [self addChild:background];
    
    //add mainlayer
    _mainlayer = [[SKNode alloc] init];
    [self addChild:_mainlayer];
    
    //add cannon
    _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"cannon"];
    _cannon.position = CGPointMake(self.size.width * 0.5, 0.0);
    [_mainlayer addChild:_cannon];
    
    //add cannon rotation
    SKAction *rotateCannon = [SKAction sequence:@[[SKAction rotateByAngle:M_PI duration:2],
                                                  [SKAction rotateByAngle:-M_PI duration:2]]];
    [_cannon runAction:[SKAction repeatActionForever:rotateCannon]];
    
}


-(void) shoot
{
    
    //create ball node
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    ball.name = @"ball";
    CGVector rotationVector = radiansToVector(_cannon.zRotation);
    ball.position = CGPointMake (_cannon.position.x + (_cannon.size.width * 0.5 * rotationVector.dx),_cannon.position.y + (_cannon.size.width * rotationVector.dy));
    [_mainlayer addChild:ball];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotationVector.dx * SHOOT_SPEED, rotationVector.dy * SHOOT_SPEED);
    
}
    
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
//        _didShoot = YES;
        [self shoot];
    }
}

-(void)didSimulatePhysics
{
    /*if (_didShoot) {
        [self shoot];
        _didShoot = NO;
    }*/
        
    [_mainlayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
     if (CGRectContainsPoint(self.frame, node.position)) {
         [node removeFromParent];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end


