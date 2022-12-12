//
// Changes since video:
//
// • Added some comments
// • Generalised obstacle-avoidance code
// • Added motion-blur
//
// You are free to modify or use this code however you would like!
//
// • Bird sprite is taken from "[LPC] Birds" by bluecarrot16, commissioned by castelonia: https://opengameart.org/content/lpc-birds
//
import processing.video.*;

PImage birdSpritesheet;

PVector seekPos = new PVector(600, 400);

ArrayList<Bird> birds = new ArrayList<Bird>();
ArrayList<PVector> obstacles = new ArrayList<PVector>();

enum DebugMode {
  OFF, ALL, SINGLE
};
DebugMode debugMode = DebugMode.OFF;

SpatialGrid grid;

// Declare a Capture object
Capture cam;

/*
 * Bird / flocking tuning parameters
 */
float BIRD_MAX_SPEED = 200;

float BIRD_MOUSE_FOLLOW_STRENGTH = 250;

float BIRD_SEPARATION_RADIUS = 65f;
float BIRD_SEPARATION_STRENGTH = 400f;

float BIRD_ALIGNMENT_RADIUS = 20f;
float BIRD_ALIGNMENT_STRENGTH = 200f;

float OBSTACLE_SIZE = 250;
float OBSTACLE_AVOID_STRENGTH = 3000f;


void setup() {
  // Create window
  size(1900, 1000, P3D);

  // Create a Capture object that represents the default webcam
  cam = new Capture(this, width, height);

  // Load bird image asset
  birdSpritesheet = loadImage("bird_sprite.png");

  // Create a bunch of birds, at random positions
  for (int i=0; i<1000; ++i) {
    PVector randomPosition = new PVector(random(100, width-100), random(100, height-100));
    Bird bird = new Bird(new Sprite(birdSpritesheet), randomPosition);
    bird.update(random(0, 1));
    birds.add(bird);
  }

  // Mark one bird arbitrarily (used for single-bird debug view)
  birds.get(0).isBirdZero = true;

  // Create an obstacle
  //obstacles.add(new PVector(453, 400));

  // Init spatial grid
  grid = new SpatialGrid(50);
}


int previousMillis;

void draw() {

  // Reassigning these here to allow them to be modified in Tweak Mode
  BIRD_MAX_SPEED = 200;
  BIRD_MOUSE_FOLLOW_STRENGTH = 100;
  BIRD_SEPARATION_RADIUS = 35;
  BIRD_SEPARATION_STRENGTH = 200;
  BIRD_ALIGNMENT_RADIUS = 75;
  BIRD_ALIGNMENT_STRENGTH = 300;
  OBSTACLE_SIZE = 250;
  OBSTACLE_AVOID_STRENGTH = 3000;

  // Calculate delta time since last frame
  int millisElapsed = millis() - previousMillis;
  float secondsElapsed = millisElapsed / 1000f;
  previousMillis = millis();

  // If a new frame is available from the webcam, draw it to the screen
  if (cam.available() == true) {
    cam.read();
    background(cam);
  } else
  {
    // Draw the sky
    // NOTE: using alpha to create a motion-blur effect
    fill(145, 189, 203, 30);
    rect(-5, -5, width+5, height+5);
  }

  // Populate spatial grid
  grid.empty();
  for (Bird bird : birds) {
    grid.add(bird, bird.position.x, bird.position.y);
  }

  if (debugMode != DebugMode.OFF) {
    grid.debugDraw();
  }

  if (mousePressed) {
    seekPos.set(mouseX, mouseY);
  }

  // Draw obstacles
  fill(255, 200, 0);
  noStroke();
  for (PVector obstacle : obstacles) {
    ellipse(obstacle.x, obstacle.y, 100, 100);
  }

  // Calculate forces on birds
  for (Bird bird : birds) {
    bird.calculateAcceleration(grid);
  }

  // Update + draw every bird
  for (Bird bird : birds) {
    bird.update(secondsElapsed);

    // Figure out if we should enable debug drawing for this particular bird
    boolean debugDraw = debugMode == DebugMode.ALL || (debugMode == DebugMode.SINGLE && bird.isBirdZero);

    bird.draw(debugDraw);
  }
}

// Cycling debug mode when 'd' key pressed
void keyPressed() {
  //toggle debug modes
  if (key == 'd') {
    if      (debugMode == DebugMode.OFF) {
      debugMode = DebugMode.SINGLE;
    } else if (debugMode == DebugMode.SINGLE) {
      debugMode = DebugMode.ALL;
    } else if (debugMode == DebugMode.ALL) {
      debugMode = DebugMode.OFF;
    }
  }

  //clear obstacles
  if (key == 'o')
  {
    obstacles.clear();
  }

  //Toggle camera on or off
  if (key == 'c')
  {
    if (cam.available())
    {
      cam.stop();
    } else
    {
      cam.start();
    }
  }
}

void mousePressed()
{
  //Add an obstacle where mouse clicked
  obstacles.add(new PVector(mouseX, mouseY));
}
