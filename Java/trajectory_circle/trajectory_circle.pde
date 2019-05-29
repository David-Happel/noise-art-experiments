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

int samplesPerFrame = 5;
int numFrames = 150;
float shutterAngle = 0.7;

boolean recording = true;

int n = 500;
float rad = 300;

PVector field(float x, float y){
  float amount = -1;
  float scale = 0.01;
  float radius = 0.7;
  PVector pos = new PVector(x,y);

  PVector vector = PVector.sub(pos, new PVector(width/2, height/2)).normalize();
  float rotation = (float)noise.eval(scale*x, scale*y, 100+radius*cos(t*TWO_PI), 100+radius*sin(t*TWO_PI));
  rotation = map(rotation, -1,1,-PI/1.5,PI/1.5);

  return vector.rotate(rotation).mult(amount);
}

OpenSimplexNoise noise;


void setup(){
  size(800, 800);
  result = new int[width*height][3];

  noise = new OpenSimplexNoise();
}

void draw_(){
  background(0);
  stroke(255);
  strokeWeight(1);

  for(int i = 0; i < n; i++){
    float angle = i*TWO_PI/n;
    float x = width/2 + rad*cos(angle);
    float y = height/2 + rad*sin(angle);
    point(x,y);
    for(int k = 0; k<400; k++){
      PVector field = field(x,y);
      x += field.x;
      y += field.y;
      point(x,y);
    }
  }

  // for(int x = 5; x < width ; x+=10){
  //   for(int y = 5; y < height; y+=10){
  //     PVector vector = field(x,y);
  //     line(x, y, x+vector.x, y+vector.y);
  //   }
  // }
}
