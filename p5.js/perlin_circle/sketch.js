let width = 1000;
let height = 1000;

let noiseAmount = 2;
let morphspeed = 0.01;

let nz = 0;

function setup() {
  createCanvas(1000,1000)
}

function draw(){
  background(0);
  translate(width/2, height/2);
  stroke(255);
  noFill();
  beginShape();

  for(let a = 0; a < TWO_PI; a+=0.01) {
    let nx = map(cos(a),-1,1,0,noiseAmount);
    let ny = map(sin(a),-1,1,0,noiseAmount);
    let r = map(noise(nx, ny, nz),0,1,200,400);
    let x = r * cos(a);
    let y = r * sin(a);
    vertex(x,y);
  }
  endShape(CLOSE);
  nz += morphspeed;
}
