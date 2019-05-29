int width = 800;
int height = 800;

float noiseAmount = 6;
float morphspeed = 0.001;

int steps = 300;
int fps = 30;

boolean record = false;

NoiseLoop[] loops = new NoiseLoop[30];

void settings(){
    size(width,height);
}

void setup() {
  frameRate(fps);
  float z = 0;
  for(int i = 0; i < loops.length; i++){
    z+= 0.1;
    loops[i] = new NoiseLoop(noiseAmount, (i*15f),(float)(10+(i*30)+Math.sqrt(i)), 0,0,z);
  }
}

void draw(){
  background(0);
  translate(width/2, height/2);
  stroke(255);
  noFill();
  for(int i = 0; i < loops.length; i++){

    loops[i].addZ(0.002);
    beginShape();

    for(float a = 0; a < TWO_PI; a+=TWO_PI/steps) {
      float r = loops[i].valueAt(a);
      float x = r * cos(a);
      float y = r * sin(a);
      vertex(x,y);
    }
    endShape(CLOSE);
  }
  if(record &&frameCount < 600){
    saveFrame("output/frame-######.png");
  }
}

void mousePressed(){
  record = true;
}
