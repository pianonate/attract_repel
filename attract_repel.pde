int NUM_MOVERS = 1200;
boolean SHOWMOVER = true;
float MOVER_SIZE_MULT = .35;
boolean SHOWTRAIL = true;
int TRAIL_LENGTH = 6;
boolean FULLCOLOR = false;
float GRAVITATIONAL_CONSTANT = .007; // 0.01;
float GRAVITATIONAL_INCREMENT = .1;
boolean ATTRACT = true;
int FLIP_FRAME = int(random(300,500));
int FLIP_FRAME_COUNT = 0;

Mover[] movers = new Mover[NUM_MOVERS];

void setup() {
  //size(640,480, P2D);
  frameRate(60);
  colorMode(HSB, 100, 100, 100, 100);
  fullScreen(P2D);
  rectMode(CENTER);
  for (int i=0;i<movers.length;i++) {
    movers[i] = new Mover(random(20,80), random(width), random(height));
  }
  println("attract " + FLIP_FRAME);
}

void draw() {
  
  background(0);
  
  // flip to repel for a little bit and then attract for a longer time
  // when you go back to attract, reset velocity so you're not going too fast
  // as repel is a  hard repel
  if (frameCount == FLIP_FRAME) {
    ATTRACT = !ATTRACT;
    
    FLIP_FRAME_COUNT = 0;
    FLIP_FRAME = (ATTRACT) ? int(random(200, 600)) : int(random(60,120));
    FLIP_FRAME += frameCount;
    
    if (ATTRACT) println("attract: " + FLIP_FRAME); else println("repel " + FLIP_FRAME);
    
    //if (ATTRACT) {
      for (int i = 0;i<movers.length;i++) {
        movers[i].velocity = new PVector(0,0);
      }
    //}
  
}
  
  if (frameCount % 100 == 0 ) println(frameCount);
  
  FLIP_FRAME_COUNT += 1;

  for (int i = 0;i<movers.length;i++) { 
    for (int j=0;j<movers.length;j++) {
      if (i != j) {
        
        PVector force = (ATTRACT) ? movers[j].attract(movers[i]) : movers[j].repel(movers[i]);       
        movers[i].applyForce(force);
      }
    }
  
    movers[i].checkEdges();
    movers[i].update();
    movers[i].display();
  }
}

class Mover {
  
  int trailLength = TRAIL_LENGTH;
  
  ArrayList<PVector> locations = new ArrayList<PVector>();
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  float angle=0;
  float aVelocity=0;
  float aAcceleration=0;
  
  float mass;
  float G = GRAVITATIONAL_CONSTANT;
    
  Mover(float m, float x, float y) {
    mass = m;
    location = new PVector(x, y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0, 0);
  }
  
  PVector attract(Mover m) {
   return innerAttract(m.location, m.mass, true);
  }
  
  PVector repel(Mover m) {
    return innerAttract(m.location, m.mass, false);
  }
  
  PVector innerAttract(PVector loc, float locMass, boolean attract) {
    PVector force = PVector.sub(location, loc);
    float distance = force.mag();
    distance = constrain(distance, 5.0, 20.0);
    force.normalize();
    float strength = (G * mass * locMass) / (distance * distance);
    if (!attract) strength *= -10;
    force.mult(strength);
    return force;
  }
  
 
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }
  
  void update() {
    // used for trailer - currenty turned off
    locations.add(new PVector(location.x, location.y));
    
    
    velocity.add(acceleration);
    location.add(velocity);
   
    aAcceleration = acceleration.x / 10.0;
    
    aVelocity += aAcceleration;
    
    // uncomment for constant spinning

    //aVelocity = constrain(aVelocity, -0.3, 0.3);
    //angle += aVelocity;
    
    acceleration.mult(0);
  }
  
  void display() {
    stroke(0, 20);
   
    float hue = map(mass, 20, 80, 20, 100);
    
    if (FULLCOLOR)
      fill(hue,100,100,hue); 
    else
      fill(hue,hue);
    
    //ellipse(location.x, location.y, mass*2, mass*2);
    
    pushMatrix();
    // this code rotates the object in the direction of movement
    // float angle = atan2(velocity.y, velocity.x); // solve for angle by using atan
    // because tangent of an angle is velocity's y over velocity's x - and inverse 
    // atan is tangent(a) = b, then a = arctangent(b) - so we can get 
    // angle = arctangent(velocity.y/velocity.x);
    // atan2 accounts for the fact that equal but opposit vectors (-4,3), (4,-3)
    // result in the same angle.  
    
    // PVector makes all of this easier by giving you the heading as an angle
    float angle = velocity.heading();
    
    translate(location.x, location.y);
    rotate(angle);
    if (SHOWMOVER) 
      //rect(0,0,mass*MOVER_SIZE_MULT, mass*MOVER_SIZE_MULT);
      ellipse(0,0,mass*MOVER_SIZE_MULT, mass*MOVER_SIZE_MULT*.5);
    popMatrix();

    int size = locations.size();
    
    if (size > 1) {
      for (int i=1;i < size; i++) {
        PVector loc = locations.get(i);
        PVector locPrev = locations.get(i-1);

        //map(i, 1, size, 20, 100);
        float lineHue = map(frameCount % i, 0, size, 20, 100);
        
        if (FULLCOLOR)
          stroke(lineHue, 100, 100, lineHue);
         else
           stroke(lineHue, lineHue);

        if (SHOWTRAIL)
          line(loc.x, loc.y, locPrev.x, locPrev.y);
      }
    
      if (size > trailLength)
        locations.remove(0);
    }
  }
  
  void checkEdges() {
    // this didn't work (tryin to repel from edges);
    // think about why
   /* PVector north = new PVector(location.x, 0); //<>//
    PVector south = new PVector(location.x, height);
    PVector east = new PVector(width, location.y);
    PVector west = new PVector(0, location.y);
    PVector forceNorth = this.repel(north, this.mass);
    PVector forceSouth = this.repel(south, this.mass);
    PVector forceEast = this.repel(east, this.mass);
    PVector forceWest = this.repel(west, this.mass);
    this.applyForce(forceNorth);
    this.applyForce(forceSouth);
    this.applyForce(forceEast);
    this.applyForce(forceWest); */
    
    if (location.x > width) {
      location.x = width;
      velocity.x *= -1;
    } else if (location.x < 0) {
      location.x = 0;
      velocity.x *= -1;
  }
    
    if (location.y > height) {
      location.y = height;
      velocity.y *= -1;
    } else if (location.y < 0) {
      location.y = 0;
      velocity.y *= -1;
    }
  }
}