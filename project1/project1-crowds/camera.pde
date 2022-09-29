// Created for CSCI 5611 by Liam Tyler

// WASD keys move the camera relative to its current orientation
// Arrow keys rotate the camera's orientation
// Holding shift boosts the move speed

boolean centerMode = false;

class Camera
{
  Camera()
  {
    position      = new PVector( 600, -600, 600 ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 60;
    turnSpeed     = 1.7; // radians/sec
    boostSpeed    = 5;  // extra speed boost for when you press shift
    
    // dont need to change these
    shiftPressed = false;
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    verticalMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1;
    farPlane         = 10000;
  }

  void Update(float dt)
  {
    if (cameraFollowAgent) {
      camera( 
        agentPos.x+backDir.x*2,-150, agentPos.z+backDir.y*2,
        agentPos.x,agentPos.y, agentPos.z,
        0, 1, 0 
      );
      return;
    }
    theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
    
    // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    float maxAngleInRadians = 85 * PI / 180;
    phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    if (negativeMovement.mag() > 0) negativeMovement.normalize();
    if (positiveMovement.mag() > 0) positiveMovement.normalize();
    if (verticalMovement.mag() > 0) verticalMovement.normalize();

    if (shiftPressed){
      positiveMovement.mult(boostSpeed);
      negativeMovement.mult(boostSpeed);
      verticalMovement.mult(boostSpeed);
    }

    PVector velocity   = new PVector( 
      negativeMovement.x + positiveMovement.x + verticalMovement.x, 
      negativeMovement.y + positiveMovement.y + verticalMovement.y, 
      negativeMovement.z + positiveMovement.z 
    );

    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( 
      position.x, position.y, position.z,
      position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
      upDir.x, upDir.y, upDir.z 
    );
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyPressed()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 1;
    if ( key == 's' || key == 'S' ) negativeMovement.z = -1;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = -1;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 1;
    if ( key == 'q' || key == 'Q' ) positiveMovement.y = 1;
    if ( key == 'e' || key == 'E' ) negativeMovement.y = -1;
    if ( key == ' ' ) verticalMovement.y = -1;
    if ( key == 'R' ){
      Camera defaults = new Camera();
      position = defaults.position;
      theta = defaults.theta;
      phi = defaults.phi;
    }
    if ( key == 'v' ) cameraFollowAgent = true;
    
    if ( keyCode == LEFT )  negativeTurn.x = 1;
    if ( keyCode == RIGHT ) positiveTurn.x = -0.5;
    if ( keyCode == UP )    positiveTurn.y = 0.5;
    if ( keyCode == DOWN )  negativeTurn.y = -1;
    if ( keyCode == CONTROL ) verticalMovement.y = 1;
    if ( keyCode == BACKSPACE ) goalSpeed = 200;
    if ( keyCode == SHIFT ) shiftPressed = true; 
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyReleased()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 0;
    if ( key == 'q' || key == 'Q' ) positiveMovement.y = 0;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 0;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = 0;
    if ( key == 's' || key == 'S' ) negativeMovement.z = 0;
    if ( key == 'e' || key == 'E' ) negativeMovement.y = 0;
    if ( key == ' ' ) verticalMovement.y = 0;
    if ( key == 'v' ) cameraFollowAgent = false;
    
    if ( keyCode == LEFT  ) negativeTurn.x = 0;
    if ( keyCode == RIGHT ) positiveTurn.x = 0;
    if ( keyCode == UP    ) positiveTurn.y = 0;
    if ( keyCode == DOWN  ) negativeTurn.y = 0;
    if ( keyCode == CONTROL ) verticalMovement.y = 0;
    if ( keyCode == BACKSPACE ) goalSpeed = 100;
    
    if ( keyCode == SHIFT ){
      shiftPressed = false;
      positiveMovement.mult(1.0/boostSpeed);
      negativeMovement.mult(1.0/boostSpeed);
    }
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  float boostSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector verticalMovement;
  PVector negativeTurn;
  PVector positiveTurn;
  boolean shiftPressed;
};




// ----------- Example using Camera class -------------------- //
// Camera camera;

// void setup()
// {
//   size(600, 600, P3D);
//   camera = new Camera();
// }

// void keyPressed()
// {
//   camera.HandleKeyPressed();
// }

// void keyReleased()
// {
//   camera.HandleKeyReleased();
// }

// void draw() {
//   background(255);
//   noLights();

//   camera.Update(1.0/frameRate);
  
//   // draw six cubes surrounding the origin (front, back, left, right, top, bottom)
//   fill( 0, 0, 255 );
//   pushMatrix();
//   translate( 0, 0, -50 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 0, 0, 50 );
//   box( 20 );
//   popMatrix();
  
//   fill( 255, 0, 0 );
//   pushMatrix();
//   translate( -50, 0, 0 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 50, 0, 0 );
//   box( 20 );
//   popMatrix();
  
//   fill( 0, 255, 0 );
//   pushMatrix();
//   translate( 0, 50, 0 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 0, -50, 0 );
//   box( 20 );
//   popMatrix();
// }
