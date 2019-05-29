let tree;

let width = 800;
let height = 800;

let moveUnit = 10;

//const rules = [["1","11"], ["0", "1[0]0"]];
//const actions = [["0", "forward"], ["1", "forward"], ["[", "push", "turn 45"], ["]", "pop", "turn -45"]]
//const seed = "0"
const rules = [["X", "F+[[X]-X]-F[-FX]+X"],["F", "FF"]];
const actions = [["F", "forward"], ["-","turn -25"],["+", "turn 25"], ["[", "push"], ["]","pop"]];
//const seed = "X";
const seed = "X"

function setup() {
  let canvas = createCanvas(width,height);
  tree = new L_System(rules, actions, seed);
  angleMode(DEGREES);
  frameRate(30);
  noLoop();
}

function draw(){
  background(0)
  translate(width/2, height);
  tree.draw();
  translate(-(width/2), -height);
}

function mouseClicked(){
  tree.evolve();
  redraw();
}
