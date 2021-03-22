import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons
final int buttonSize = 40; // width/height of buttons
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks

Rectangle rec1 = getButtonLocation(0);
Rectangle rec2 = getButtonLocation(4);
Rectangle rec3 = getButtonLocation(8);

int row1 = rec1.y + buttonSize + (padding/2);
int row2 = rec2.y + buttonSize + (padding/2);
int row3 = rec3.y + buttonSize + (padding/2);

int col1 = rec1.x + buttonSize + (padding/2);
int col2 = rec1.x + 2*buttonSize + (3*padding/2);
int col3 = rec1.x + 3*buttonSize + (5*padding/2);

Robot robot; //initalized in setup 
int delay = 100; //how long (ms) to flash the new target color 
int targetStartTime; //track when each new target appears

int numRepeats = 3; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  
  targetStartTime = millis();

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

  if (mouseY <= row1) changeBackground(0, 0, width, row1);
  else if (mouseY > row1 && mouseY <= row2) changeBackground(0, row1, width, row2 - row1);
  else if (mouseY > row2 && mouseY <= row3) changeBackground(0, row2, width, row3 - row2);
  else changeBackground(0, row3, width, height - row3);
  
  if (mouseX <= col1) changeBackground(0, 0, col1, height);
  else if (mouseX > col1 && mouseX <= col2) changeBackground(col1, 0, col2-col1, height);
  else if (mouseX > col2 && mouseX <= col3) changeBackground(col2, 0, col3-col2, height);
  else changeBackground(col3, 0, width-col3, height);

  for (int i = 0; i < 16; i++) {
    drawButton(i); //draw button
    drawFullButtonOnHover(i);
  }
  
  drawPath(trials.get(trialNum));

  cursor(CROSS);
}

void changeBackground(int x, int y, int w, int h) {
  fill(150, 150, 150, 30);
  rect(x, y, w, h);
}

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

Rectangle getButtonWithoutPadding(int i)
{
  int x = (i % 4) * (padding + buttonSize) + margin - padding / 2;
  int y = (i / 4) * (padding + buttonSize) + margin - padding / 2;
  return new Rectangle(x, y, buttonSize + padding, buttonSize + padding);
}

void drawPath(int i) {
  Rectangle bounds = getButtonLocation(i);

  int x = bounds.x + (bounds.width / 2);
  int y = bounds.y + (bounds.height / 2);

  stroke(255);
  strokeWeight(4);
  line(mouseX, mouseY, x, y);
  fill(255, 0, 0);
  strokeWeight(2);
  ellipse(x, y, 8, 8);
  noStroke();
}

void mousePressed()
{
  if (trialNum >= trials.size()) return;

  if (trialNum == 0) startTime = millis();

  if (trialNum == trials.size() - 1) {
    finishTime = millis();
    println("we're done!");
  }
  
  checkAll();

  trialNum++; //Increment trial number
  
  targetStartTime = millis();

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
    if (millis() - targetStartTime < delay) 
      fill(255, 165, 0);
    else
      fill(0, 255, 255); // if so, fill cyan
  else if (trialNum + 1 < trials.size() && trials.get(trialNum + 1) == i)
    fill(0, 255, 255, 80);
  else
    fill(200); // if not, fill gray

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void drawFullButtonOnHover(int i) {
  Rectangle bounds = getButtonWithoutPadding(i);

  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    drawButtonWithoutPadding(i);
  }
}

void drawButtonWithoutPadding(int i)
{
  Rectangle bounds = getButtonWithoutPadding(i);

  if (trials.get(trialNum) == i) { // see if current button is the target 
    if (millis() - targetStartTime < delay) 
      fill(255, 165, 0);
    else
      fill(0, 255, 255); // if so, fill cyan
  }
  else
    fill(200); // if not, fill gray

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void checkAll() {
  int squareNum = trials.get(trialNum);
  
  if (squareNum == 0) verify(0, col1, 0, row1);
  else if (squareNum == 1) verify(col1, col2, 0, row1);
  else if (squareNum == 2) verify(col2, col3, 0, row1);
  else if (squareNum == 3) verify(col3, width, 0, row1);
  else if (squareNum == 4) verify(0, col1, row1, row2);
  else if (squareNum == 5) verify(col1, col2, row1, row2);
  else if (squareNum == 6) verify(col2, col3, row1, row2);
  else if (squareNum == 7) verify(col3, width, row1, row2);
  else if (squareNum == 8) verify(0, col1, row2, row3);
  else if (squareNum == 9) verify(col1, col2, row2, row3);
  else if (squareNum == 10) verify(col2, col3, row2, row3);
  else if (squareNum == 11) verify(col3, width, row2, row3);
  else if (squareNum == 12) verify(0, col1, row3, height);
  else if (squareNum == 13) verify(col1, col2, row3, height);
  else if (squareNum == 14) verify(col2, col3, row3, height);
  else verify(col3, width, row3, height);
}

void verify(int lowerX, int upperX, int lowerY, int upperY) {
  if ((mouseX >= lowerX) && (mouseX <= upperX) && (mouseY >= lowerY) && (mouseY <= upperY)) hit();
  else miss();
}

void hit() {
  System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
  hits++;
}

void miss() {
  System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
  misses++;
}

void keyPressed() 
{
  if (key == ' ') {
    if (trialNum >= trials.size()) return;
    if (trialNum == 0) startTime = millis();
    if (trialNum == trials.size() - 1) {
      finishTime = millis();
      println("we're done!");
    }
    checkAll();
    trialNum++;
    targetStartTime = millis();
  }
}
