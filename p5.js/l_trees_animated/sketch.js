let tree;

let brown;
let green;

const width = 900;
const height = 900;

const fps = 30;

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
  tree = new L_System(rules, actions, seed, color(0,255,0));
  angleMode(DEGREES);
  frameRate(fps);
}

function draw(){
  translate(width/2, height);
  tree.turtle.draw(0.2);
}

function mouseClicked(){
  tree.evolve();
}
