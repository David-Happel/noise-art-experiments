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
int numFrames = 300;
float shutterAngle = 0.3;

boolean recording = true;


void setup(){
  size(800, 800, P3D);
  result = new int[width*height][3];
  camera(0, 0, 0, 0, 0, -400, 0, 1, 0);

}

void draw_(){
  background(0);
  fill(0);
  strokeWeight(3);
  noFill();
  beginShape();
  vertex(-400, -400, 0);
  vertex(-400, 400, 0);
  vertex(400, 400, 0);
  vertex(400, -400, 0);
  endShape();

  int amount = 100;


  for(int i = 1; i <= amount ; i++){
    float pos = (i + ((1-t) * amount)) % amount;
    float z = -(pos * 70);

    float opp = 1-(pos/amount);

    fill(0);
    stroke(0, 255*opp, 0);
    
    beginShape();
    vertex(400, -400, z);
    vertex(400, 400, z);
    vertex(-400, 400, z);
    vertex(-400, -400, z);

    float iLoop = i;
    if(i > amount/2){
      iLoop = amount-i;
    }
    
    NoiseLoop noise =  new NoiseLoop(2.5,100,300,iLoop*0.15,0,0);
    beginContour();
    float downward = 0;
      if(pos > amount/2){
        downward = (pos-(amount/2))*8;
      }
    float widthMult = -(z/100);
    for(float a = 0; a <= TWO_PI+0.01; a+= TWO_PI/100){
      float x = sin(a) * (noise.valueAt(a) - widthMult);
      float y = cos(a) * (noise.valueAt(a) - widthMult);
      
      vertex(x, y+downward, z);
    }
    endContour();
    endShape();
    
    
  }
  lights();


}