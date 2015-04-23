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
}

static const CGFloat SHOOT_SPEED = 1000.0f;
static const CGFloat haloLowAngle = 200.0 * M_PI / 180.0;
static const CGFloat haloHighAngle = 340.0 * M_PI / 180.0;
static const CGFloat haloSpeed = 150.0;

static const uint32_t kCCHaloCategory = 0x1 << 0;
static const uint32_t kCCBallCategory = 0x1 << 1;
static const uint32_t kCCEdgeCategory = 0x1 << 2;

static inline CGVector radiansToVector(CGFloat radians)
{
    CGVector Vector;
    Vector.dx = cosf(radians);
    Vector.dy = sinf(radians);
    return Vector;
}

static inline CGFloat randomInRange(CGFloat low, CGFloat high)
{
CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
return value * (high - low) + low;
}
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    //add background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Starfield"];
    background.position = CGPointMake(self.size.width * 0.29, 0.0);
    background.anchorPoint = CGPointZero;
    background.blendMode = SKBlendModeReplace;
    background.size = CGSizeMake(429, 1136);
    [self addChild:background];
    
    
    // Add edges.
    SKNode *leftEdge = [[SKNode alloc] init];
    leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    leftEdge.position = background.position;
    leftEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
    [self addChild:leftEdge];
    
    SKNode *rightEdge = [[SKNode alloc] init];
    rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    rightEdge.position =  CGPointMake(730.0, 0.0);
    rightEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
    [self addChild:rightEdge];
    
    //add mainlayer
    _mainlayer = [[SKNode alloc] init];
    [self addChild:_mainlayer];
    
    //add cannon
    _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"Cannon"];
    _cannon.position = CGPointMake(self.size.width * 0.5, 0.0);
    [_mainlayer addChild:_cannon];
    
    //add cannon rotation
    SKAction *rotateCannon = [SKAction sequence:@[[SKAction rotateByAngle:M_PI duration:2],
                                                  [SKAction rotateByAngle:-M_PI duration:2]]];
    [_cannon runAction:[SKAction repeatActionForever:rotateCannon]];
    
    //create spawn halo actions
    SKAction *spawnhalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1],
                                               [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnhalo]];
    
}


-(void) shoot
{
    
    //create ball node
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"Ball"];
    CGVector rotationVector = radiansToVector(_cannon.zRotation);
    ball.position = CGPointMake (_cannon.position.x + (_cannon.size.width * 0.5 * rotationVector.dx),_cannon.position.y + (_cannon.size.width * rotationVector.dy));
    [_mainlayer addChild:ball];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotationVector.dx * SHOOT_SPEED, rotationVector.dy * SHOOT_SPEED);
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.friction = 0.0;
    ball.physicsBody.categoryBitMask = kCCBallCategory;
    ball.physicsBody.collisionBitMask = kCCEdgeCategory;
}
  
-(void)spawnHalo

    {
    //create halos
        SKSpriteNode *halo = [SKSpriteNode spriteNodeWithImageNamed:@"Halo"];
        halo.position = CGPointMake(randomInRange(halo.size.width * 0.5, self.size.width - (halo.size.width * 0.5)), self.size.              height + (halo.size.height * 0.5));
        halo.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:16.0];
        CGVector direction = radiansToVector(randomInRange(haloLowAngle, haloHighAngle));
        halo.physicsBody.velocity = CGVectorMake(direction.dx * haloSpeed, direction.dy * haloSpeed);
        halo.physicsBody.restitution = 1.0;
        halo.physicsBody.linearDamping = 0.0;
        halo.physicsBody.friction = 0.0;
        halo.physicsBody.categoryBitMask = kCCHaloCategory;
        halo.physicsBody.collisionBitMask = kCCEdgeCategory;
        halo.physicsBody.contactTestBitMask = kCCBallCategory;
        [_mainlayer addChild:halo];
    }
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCBallCategory){
        // Collision between halo and ball.
        if (firstBody.node != nil) {
            [self addExplosion:firstBody.node.position];
        }
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
        
}

-(void)addExplosion:(CGPoint)position
{
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"HaloExplosion" ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    explosion.position = position;
    [_mainlayer addChild:explosion];
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:1.5],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
}
    
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
    
        [self shoot];
    }
}

-(void)didSimulatePhysics
{
        
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

