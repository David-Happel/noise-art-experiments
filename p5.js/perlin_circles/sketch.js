const width = 1000;
const height = 1000;

let noiseAmount = 2;
let morphspeed = 0.001;

const steps = 300;
const fps = 30;

let loops = [];

function setup() {
  createCanvas(1000,1000);
  frameRate(fps);
  let z = 0;
  for(let i = 0; i < 100; i++){
    z+= 0.035;
    loops[i] = new NoiseLoop(noiseAmount, (i*10),10+(i*30)+Math.sqrt(i), 0,0,z);
  }
}

function draw(){
  background(0);
  translate(width/2, height/2);
  stroke(255);
  noFill();
  for(let i = 0; i < 100; i++){
    loops[i].addZ(0.001);
    beginShape();

    for(let a = 0; a < TWO_PI; a+=TWO_PI/steps) {

      let r = loops[i].valueAt(a);
      let x = r * cos(a);
      let y = r * sin(a);
      vertex(x,y);
    }
    endShape(CLOSE);
  }
}
