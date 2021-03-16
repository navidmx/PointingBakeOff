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
Robot robot; //initalized in setup

Rectangle rec0 = getButtonLocation(0);
Rectangle rec1 = getButtonLocation(4);
Rectangle rec2 = getButtonLocation(8);
Rectangle rec3 = getButtonLocation(12);
int region0 = rec0.y + buttonSize + (padding/2);
int region1 = rec1.y + buttonSize + (padding/2);
int region2 = rec2.y + buttonSize + (padding/2);

int numRepeats = 1; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

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

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button


  if (mouseY <= region0) {
    highlight(0, 0, width, region0);
    squareText(rec0.x, rec0.y);
  }
  else if (mouseY > region0 && mouseY <= region1) {
    highlight(0, region0, width, region1 - region0);
    squareText(rec0.x, rec1.y);
  }
  else if (mouseY > region1 && mouseY <= region2) {
    highlight(0, region1, width, region2 - region1);
    squareText(rec0.x, rec2.y);
  }
  else {
    highlight(0, region2, width, height - region2);
    squareText(rec0.x, rec3.y);
  }

  //fill(255, 0, 0, 200); // set fill color to translucent red
  //ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
  cursor(CROSS);
}

void highlight(int x, int y, int w, int h) {
  fill(255, 255, 0, 90);
  rect(x, y, w, h);
}

void squareText(int x, int y) {
  fill(0);
  text("1", x + 20, y + 27);
  text("2", x + 10 + (padding*2), y + 27);
  text("3", x + (padding*4), y + 27);
  text("4", x - 10 + (padding*6), y + 27);
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }

  trialNum++; //Increment trial number

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
    fill(0, 255, 255); // if so, fill cyan
  else
    fill(200); // if not, fill gray

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
    finishTime = millis();
  
  int target = trials.get(trialNum);

  Rectangle bounds = getButtonLocation(target);
  
  if (target < 4) {
    verify(0, region0, bounds.x);
  }
  else if (target < 8) {
    verify(region0, region1, bounds.x);
  }
  else if (target < 12) {
    verify(region1, region2, bounds.x);
  }
  else {
    verify(region2, height, bounds.x);
  }

  trialNum++;
}

void verify(int upper, int lower, int x) {
  if ((mouseY >= upper) && (mouseY <= lower)) {
    if ((x == margin) && ((key == '1') || (key == 'a'))) {
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++;
    }
    else if ((x == margin + buttonSize + padding) && ((key == '2') || (key == 's'))) {
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++;
    }
    else if ((x == margin + (buttonSize + padding)*2) && ((key == '3') || (key == 'd'))) {
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++;
    }
    else if ((x == margin + (buttonSize + padding)*3) && ((key == '4') || (key == 'f'))) {
      System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
      hits++;
    }
    else {
      System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
      misses++;
    }
  }
  else {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }
}
