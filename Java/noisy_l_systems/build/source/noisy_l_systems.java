import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class noisy_l_systems extends PApplet {



int[][] result;
float t, c;

public float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

public float ease(float p, float g) {
  if (p < 0.5f)
    return 0.5f * pow(2*p, g);
  else
    return 1 - 0.5f * pow(2*(1 - p), g);
}

float mn = .5f*sqrt(3), ia = atan(sqrt(.5f));

public void push() {
  pushMatrix();
  pushStyle();
}

public void pop() {
  popStyle();
  popMatrix();
}

public void draw() {

  if (!recording) {
    t = mouseX*1.0f/width;
    c = mouseY*1.0f/height;
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
        PApplet.parseInt(result[i][0]*1.0f/samplesPerFrame) << 16 |
        PApplet.parseInt(result[i][1]*1.0f/samplesPerFrame) << 8 |
        PApplet.parseInt(result[i][2]*1.0f/samplesPerFrame);
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
float shutterAngle = 0.2f;

boolean recording = true;

String[][] rules = {{"X", "F+[[X]-X]-F[-FX]+X"},{"F", "FF"}};
String[][] actions = {{"F", "forward"}, {"-","turn -25"},{"+", "turn 25"}, {"[", "push"}, {"]","pop"}};
//const seed = "X";
String seed = "X";

float size = 10;

LSystem tree;


OpenSimplexNoise noise;


public void setup(){
  
  result = new int[width*height][3];

  tree = new LSystem(rules, actions, seed, size);

  noise = new OpenSimplexNoise();
}

public void draw_(){
  background(0);
  strokeWeight(2);
  stroke(255, 15);

}

class LSystem {
  String[][] rules;
  String[][] actions;
  String treeString;
  float sizeUnit;

  Deque<ArrayList<Line>> stages;

  LSystem(String[][] rules, String[][] actions,String initial, float size) {
    this.rules = rules;
    this.actions = actions;
    this.treeString = initial;
    this.sizeUnit = size;
  }

  public void evolve(){
    String evolved = "";
    for(char c : treeString.toCharArray()){
      evolved += evolveChar(c);
    }
    treeString = evolved;
    //Instructions();
    println("new String: ", evolved);
  }

  public String evolveChar(char c){
    for(int ruleI = 0; ruleI < rules.length; ruleI++){
      String[] rule = rules[ruleI];
      if(c == rule[0].toCharArray()[0]){
        return rule[1];
      }
    }
    return String.valueOf(c);
  }

  public void interpretInstructions(){
    PVector pos = new PVector(0,0);
    PVector dir = new PVector(0,-sizeUnit);
    Deque<PVector> posStack = new ArrayDeque<PVector>(1);
    Deque<PVector> dirStack = new ArrayDeque<PVector>(1);
    ArrayList<ArrayList<Line>> newStages = new ArrayList<ArrayList<Line>>();
    newStages.add(new ArrayList<Line>());
    int currentStage = 0;

    Line prevLine = new Line(new PVector(), new PVector());
    String prevInstruction = "";

    for(char c : treeString.toCharArray()){
      String instr = decode(c);
      String[] ins = instr.split(" ");
      switch(ins[0]) {
        case "forward":

          PVector oldPos = pos.copy();
          float amount;
          pos.add(dir);

          if(prevInstruction == "forward"){
            prevLine.p2 = pos.copy();
          }else{
            Line newLine = new Line(oldPos, pos.copy());
            newStages.get(currentStage).add(newLine);
            prevLine = newLine;
          }
          break;
        case "push":
          posStack.addFirst(pos.copy());
          dirStack.addFirst(dir.copy());
          currentStage++;
          if(currentStage > stages.size()-1){
            newStages.add(new ArrayList<Line>());
          }
          break;
        case "pop":
          pos = posStack.pollFirst();
          dir = dirStack.pollFirst();
          currentStage--;
          break;
        case "turn":
          dir.rotate(Integer.parseInt(ins[1]));
          break;
      }
      prevInstruction = ins[0];
    }
  }

  public String decode(char c){
    for(String[] action : actions){
      if(action[0].toCharArray()[0] == c){
        return action[1];
      }
    }
    return " ";
  }
}

class Line{
  String type;
  PVector p1;
  PVector p2;
  Line(PVector p1, PVector p2){
    this.p1 = p1;
    this.p2 = p2;
    this.type = "line";
  }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "noisy_l_systems" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
