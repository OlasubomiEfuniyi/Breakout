import processing.sound.SoundFile;

final int SCREEN_WIDTH = 500;
final int SCREEN_HEIGHT = 500;
final int BRICK_COLS = 10;
final int BRICK_ROWS = 4;
final int MAX_CHANCES = 3;

int ballX = 250;
int ballY = 445;
int ballWidth = 10;
int ballHeight = 10;
int ballDX = 0;
int ballDY = 0;

int platformX = 210;
int platformY = 450;
int platformWidth = 90;
int platformHeight = 20;
int platDX = 5;

int lineHeight = 20;
int lineStartX = 250;
float lineStartY = 442.5;
int lineEndX = 250;
float lineEndY = lineStartY - lineHeight;
int lineDX = 0;
int lineDY = 0;

boolean[][] brickArray = new boolean[BRICK_ROWS][BRICK_COLS]; 

int score = 0;
int maxScore = 0;
int numChances = MAX_CHANCES;

boolean isStarted = false;
boolean isRestart = false;

PImage background = null;
SoundFile sound = null;
SoundFile music = null;

int musicSpeed = 1;


void setup() {
  size(500, 500);
  
  music = new SoundFile(this, "themeSong.mp3");
  music.loop(musicSpeed);  //Start Music
  
  initializeBricks();
  background = loadImage("background.jpg");
  sound = new SoundFile(this, "blockSound.wav");
}

void draw() {
  background(background);

  //IF ball goes below the platform
  if ((ballY+(ballHeight/2)) >=500) {
    if (numChances == 1) {    //If the user has no more chances
      if (score > maxScore) {
        maxScore = score;
      }
      fill(255);
      textSize(50);
      text("Game Over", 130, 250);
      textSize(20);
      text("Max Score: " + maxScore, 200, 300);
      music.stop();
      noLoop();
    } else { 
      numChances--;
      if (score > maxScore) {
        maxScore = score;
      }
      reset();
    }
  } else if (score == BRICK_ROWS * BRICK_COLS) {
    fill(255);
    textSize(50);
    text("You Won the Round!", 0, 250);
    textSize(25);
    text("Press r to restart", 150, 280);
    noLoop();
  }

  drawPlatform();
  drawBricks();
  displayStats();

  if (!isStarted) {      //Draw the line that decides initial velocity if the game has  not started
    fill(255);
    textSize(20);
    text("Choose a direction and press Enter to start", 50, 250);
    drawLine();
  }
  if (isStarted) {       //Don't draw ball unless game is started
    drawBall();
  }

  //Change the direction of the ball depending on where it hits
  if ((ballX-(ballHeight/2)) <= 0 || (ballX+(ballHeight/2)) >= 500) {    //If the ball hits the left or right edge of the frame
    reverseBallX();
  } else if ((ballY - (ballHeight/2)) <=0) {  //If the ball hits the top of the frame
    reverseBallY();
  } else if (((ballY+(ballHeight/2)) == platformY && ballX >= platformX && ballX <= platformX + platformWidth)) {  //If the ball hits the platform
    if (ballDX == 0) {
       if(floor(random(0, 2)) == 0) {
         ballDX = -5;
       }
       else {
         ballDX = 5;
       }
      
    } else {
      if (int(random(0, 5)) == 0) {
        reverseBallX();
      }
    }
    reverseBallY();
  }
}


//This method draws the platform
void drawPlatform() {
  stroke(244, 137, 66);
  strokeWeight(5);
  line(platformX, platformY, platformX + platformWidth, platformY);

  if (keyPressed && isStarted) {        //Only move platform if the game has started    
    if (keyCode == LEFT) {
      if (platformX >= 5) {
        platformX -= platDX;
      }
    } else if (keyCode == RIGHT) {
      if (platformX <= 405) {
        platformX += platDX;
      }
    }
  }
}

//This method draws the line used to determine the begining velocity
void drawLine() {
  strokeWeight(5);
  stroke(255);
  line(lineStartX, lineStartY, lineEndX + lineDX, lineEndY);

  if (keyPressed) {
    if (keyCode == LEFT && lineDX > -5) {    //Restrict the beginning velocity -5 <= dx <= 5
      lineDX-=5;
      lineDY-=5;
    } else if (keyCode == RIGHT && lineDX < 5) {
      lineDX+=5;
      lineDY-=5;
    } else if (key == ENTER) {
      isStarted = true;
      lineDY = -5;
      ballDX = lineDX;
      ballDY = lineDY;
    }
  }
}

//This method draws the ball
void drawBall() {
  stroke(255);
  strokeWeight(2);
  fill(255);
  ellipse(ballX, ballY, ballWidth, ballHeight);

  ballX += ballDX;
  ballY += ballDY;
}

//This method draws the grid of bricks
void drawBricks() { 
  int brickWidth = 50;
  int brickHeight = 25;
  int brickStartX = 0;
  int brickStartY = 0;
  int numBricks = BRICK_ROWS * BRICK_COLS;
  int row = 0;
  int col = 0;

  stroke(255);
  strokeWeight(5);
  fill(121, 66, 277);

  //Draw the brick grid
  for (int i=1; i <= numBricks; i++) {
    if (brickArray[brickStartY/brickHeight][brickStartX/brickWidth]) {
      rect(brickStartX, brickStartY, brickWidth, brickHeight);
    }

    brickStartX += brickWidth;

    if (i % BRICK_COLS == 0) {
      brickStartX = 0;
      brickStartY += brickHeight;
    }
  }

  if (ballY >=0 && ballY <= (brickHeight*BRICK_ROWS)-1) {
    if (ballY < brickHeight) {
      //If ball hits the top or bottom (ball's y > ball's height) for the purpose of successful modulus check
      if (brickHeight % ballY <= 5 || brickHeight % ballY >= brickHeight - 5) {
        row = ballY/brickHeight;

        col = ballX/brickWidth;
        if (col == numBricks) {
          col--;
        }
        if (brickArray[row][col]) {
          stroke(255, 0, 0);      //Highlight brick
          strokeWeight(5);
          rect(col*brickWidth, row*brickHeight, brickWidth, brickHeight);
          sound.play();

          reverseBallY();
          reverseBallY();
          brickArray[row][col] = false;
          score++;
        }
      } else {
        //If ball hits the side instead
        if (ballX < brickWidth) {
          if (brickWidth % ballX <=5 || brickWidth % ballX >= brickWidth - 5) {
            row = ballY/brickHeight;
            col = ballX/brickWidth;
            if (col == numBricks) {
              col--;
            }
            if (brickArray[row][col]) {
              stroke(255, 0, 0);
              strokeWeight(5);
              rect(col*brickWidth, row*brickHeight, brickWidth, brickHeight);
              sound.play();

              reverseBallY();
              reverseBallX();
              brickArray[row][col] = false;
              score++;
            }
          }
        } else {
          if (ballX % brickWidth <=5 || ballX % brickWidth >= brickWidth - 5) {
            row = ballY/brickHeight;
            col = ballX/brickWidth;
            if (col == numBricks) {
              col--;
            }
            if (brickArray[row][col]) {
              stroke(255, 0, 0);
              strokeWeight(5);
              rect(col*brickWidth, row*brickHeight, brickWidth, brickHeight);
              sound.play();

              reverseBallY();
              reverseBallX();
              brickArray[row][col] = false;
              score++;
            }
          }
        }
      }
    } else {
      //If ball hits the top or bottom (ball's y > ball's height) for the purpose of successful modulus check
      if (ballY % brickHeight<= 5 || ballY % brickHeight >= brickHeight - 5) {
        row = ballY/brickHeight;

        col = ballX/brickWidth;
        if (col == numBricks) {
          col--;
        }
        if (brickArray[row][col]) {
          stroke(255, 0, 0);
          strokeWeight(5);
          rect(col*brickWidth, row*brickHeight, brickWidth, brickHeight);
          sound.play();

          reverseBallY();
          brickArray[row][col] = false;
          score++;
        }
      } else {
        //If ball hits the side instead
        if (ballX < brickWidth) {
          if (brickWidth % ballX <=5 || brickWidth % ballX >= brickWidth - 5) {
            row = ballY/brickHeight;
            col = ballX/brickWidth;
            if (col == numBricks) {
              col--;
            }
            if (brickArray[row][col]) {
              stroke(255, 0, 0);
              strokeWeight(5);
              rect(col*brickWidth, row*brickHeight, brickWidth, brickHeight);
              sound.play();

              reverseBallY();
              reverseBallX();
              brickArray[row][col] = false;
              score++;
            }
          }
        } else {
          if (ballX % brickWidth <=5 || ballX % brickWidth >= brickWidth - 5) {
            row = ballY/brickHeight;
            col = ballX/brickWidth;
            if (col == numBricks) {
              col--;
            }
            if (brickArray[row][col]) {
              stroke(255, 0, 0);
              strokeWeight(5);
              rect(col*brickWidth, row*brickHeight, brickWidth, brickHeight);
              sound.play();

              reverseBallY();
              reverseBallX();
              brickArray[row][col] = false;
              score++;
            }
          }
        }
      }
    }
  }
}

//This method displays the players statistics
void displayStats() {
  String scoreMsg = "Score: ";
  String chancesMsg = "Chances: ";

  fill(255);
  textSize(20);
  text(scoreMsg+score, 10, 475);
  text(chancesMsg+numChances, 350, 475);
}

//This method reverses the the balls Vx
void reverseBallX() {
  ballDX = ballDX * -1;
}

//This method reverses the balls Vy
void reverseBallY() {
  ballDY = ballDY* -1;
}

void initializeBricks() {
  //Initialize all the bricks to true
  for (int i = 0; i < BRICK_ROWS; i++) {
    for (int j = 0; j < BRICK_COLS; j++) {
      brickArray[i][j] = true;
    }
  }
}

//Reset the game after each chance
void reset() {
  ballX = 250;
  ballY = 445;
  ballWidth = 10;
  ballHeight = 10;
  ballDX = 0;
  ballDY = 0;
  platformX = 210;
  platformY = 450;
  platformWidth = 90;
  platformHeight = 20;
  platDX = 5;

  lineHeight = 20;
  lineStartX = 250;
  lineStartY = 442.5;
  lineEndX = 250;
  lineEndY = lineStartY - lineHeight;
  lineDX = 0;
  lineDY = 0;


  score = 0;

  //Only reset the maxScore and numChances when restarting the game
  if (isRestart) {
    maxScore = 0;
    numChances = MAX_CHANCES;
    isRestart = false;
    music.loop(musicSpeed);
    loop();
  }

  isStarted = false;

  initializeBricks();
}

void keyPressed() {
  if (key == 'R' || key=='r') {
    isRestart = true;
    music.stop();
    reset();
  }
}