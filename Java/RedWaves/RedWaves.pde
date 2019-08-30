int[][] result;
float t, c;

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5)
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

float mn = .5*sqrt(3), ia = atan(sqrt(.5));

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

void draw() {

  if (!recording) {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
    if (mousePressed)
      println(c);
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 |
        int(result[i][0]*1.0/samplesPerFrame) << 16 |
        int(result[i][1]*1.0/samplesPerFrame) << 8 |
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();

    saveFrame("output/fr###.png");
    println(frameCount,"/",numFrames);
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////

int samplesPerFrame = 1;
int numFrames = 200;
float shutterAngle = 0.7;

boolean recording = true;

Line[] lines = new Line[50];

void setup(){
  size(800, 800, P3D);
  result = new int[width*height][3];
  for(int l = 0; l < lines.length; l++){
    lines[l] = new Line();
  }
  camera(400, 0, 0, 400, 400, 0, 1, 0, 1);

}

void draw_(){
  background(0);
  translate(400, 0, 0);
  rotateY(TWO_PI*t);

  //noFill();
  //stroke(0,100,0);
  //rect(-400,0,400,800);

  for(int l = 0; l < lines.length; l++){
    lines[l].drawAt(t);
  }
  rotateY(-TWO_PI*t);
  strokeWeight(3);

  translate(-400,0,0);
  //noFill();
  //stroke(0,100,0);
  //rect(0,0,800,800);

}

class Line {
  NoiseLoop rNoise;
  NoiseLoop zNoise;
  float speed;
  float thickness;
  float opp;
  float rotation;

  Line(){
    float r = random(-10000, 10000);
    speed = random(0.5,1.5);
    thickness = random(10,40);
    opp = random(100,255);
    rNoise = new NoiseLoop(1,-1,1,r,0,0);
    zNoise = new NoiseLoop(1.5,-100,100,r+200,0,0);
    rotation = random(0,1);    
  }

  void drawAt(float t){
    strokeWeight(thickness);
    for(int i = 0; i < 1200; i++){
      // float xOff = xNoise.valueAt(i/400f*TWO_PI);
      // float zOff = zNoise.valueAt(i/400f*TWO_PI);  
      float rOff = rNoise.valueAt((i/400f)+(TWO_PI*t)); 
      float r = rotation + rOff;
      float closeness = map(i,0,1200,1,0);
      float x = sin(TWO_PI*r)*200*closeness;
      float y = cos(TWO_PI*r)*200*closeness;
      strokeWeight(thickness*closeness*closeness*closeness);
      if(closeness<0.4){
        stroke(opp*map(closeness,0,0.4,0,1),0,0);
      }else{
        stroke(opp,0,0);
      }
      
      point(x, 800f/200f*i, y);
    }
  }
}
