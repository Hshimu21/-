import processing.sound.*;

SoundFile sound;

PImage tamago1, tamago2, tamago3, hiyoko1, hiyoko2, tobi, niwatori;
PImage[] currentImages;
float[] x, y;
float speedX;
float[] speedY;  // Y方向の速度を追加
int[] states;  // 0: tamago1, 1: tamago2, 2: tamago3, 3: hiyoko1, 4: hiyoko2, 5: tobi, 6: niwatori
int imgWidth = 100;
int imgHeight = 100;
int niwatoriWidth = 200;  // 鶏の幅
int niwatoriHeight = 200; // 鶏の高さ
int numEggs = 5;
int numChickens = 0;  // ひよこの数をカウント
boolean showNiwatori = false;
int niwatoriX, niwatoriY;
int niwatoriStartTime;
int niwatoriDuration = 2000; // 鶏が画面に表示される時間

boolean showCircle = false;
int circleDisplayTime = 500; // 0.5秒（ミリ秒）
int circleStartTime;
float circleX, circleY;
float maxCircleSize = 200;

void setup() {
  size(800, 800);
  tamago1 = loadImage("tamago.png");
  tamago2 = loadImage("tamago3.png");
  tamago3 = loadImage("tamago4.png");
  hiyoko1 = loadImage("hiyoko1.png");
  hiyoko2 = loadImage("hiyoko.png");
  tobi = loadImage("tobi.png");
  niwatori = loadImage("niwatori.png");
  sound = new SoundFile(this, "p.mp3");
  
  currentImages = new PImage[numEggs];
  x = new float[numEggs];
  y = new float[numEggs];
  speedY = new float[numEggs];  // Y方向の速度を追加
  states = new int[numEggs];
  
  for (int i = 0; i < numEggs; i++) {
    currentImages[i] = tamago1;
    x[i] = random(-imgWidth, width); // 初期位置をランダムに設定
    y[i] = height / 2 + random(-300, 300); // 垂直位置を中央付近のランダム位置に設定
    speedY[i] = 0; // 初期速度は0
    states[i] = 0;
  }
  
  speedX = 2; // 水平方向の移動速度を設定
  numChickens = numEggs; // 初期のひよこの数
  niwatoriX = width / 2 - niwatoriWidth / 2;
  niwatoriY = height / 2 - niwatoriHeight / 2;
}

void draw() {
  background(100, 200, 0);
  
  boolean allGone = true; // すべてのひよこがいなくなったかどうかをチェック
  
  for (int i = 0; i < numEggs; i++) {
    if (states[i] != 6) { // 鶏状態ではない場合
      allGone = false;
    }
    
    if (states[i] == 5) { // tobiの状態
      y[i] -= speedY[i];
      if (y[i] + imgHeight < 0) {  // 画面の上端に到達したら消える
        currentImages[i] = null;
        states[i] = 6; // 状態を消えたに設定
        numChickens--; // ひよこの数を減らす
      }
    } else if (states[i] < 5) { // tobi以外の状態
      x[i] += speedX;
      if (x[i] > width) {
        x[i] = -imgWidth;
      }
    }
    
    if (currentImages[i] != null) {
      image(currentImages[i], x[i], y[i], imgWidth, imgHeight);
    }
  }
  
  // すべてのひよこがいなくなった場合
  if (allGone && numChickens == 0) {
    showNiwatori = true;
    niwatoriStartTime = millis();
    numChickens = numEggs;
  }
  
  // 鶏を表示し、たまごを産み落とす
  if (showNiwatori) {
    image(niwatori, niwatoriX, niwatoriY, niwatoriWidth, niwatoriHeight);
    if (millis() - niwatoriStartTime > niwatoriDuration) {
      showNiwatori = false;
      for (int i = 0; i < numEggs; i++) {
        currentImages[i] = tamago1;
        x[i] = random(-imgWidth, width);
        y[i] = height / 2 + random(-300, 300);
        speedY[i] = 0;
        states[i] = 0;
      }
    }
  }
  
  // Display expanding circle if needed
  if (showCircle) {
    float elapsed = millis() - circleStartTime;
    float alpha = map(elapsed, 0, circleDisplayTime, 255, 0);
    float size = map(elapsed, 0, circleDisplayTime, 0, maxCircleSize);
    
    noFill();
    stroke(255, alpha);
    strokeWeight(5);
    ellipse(circleX, circleY, size, size);
    
    if (elapsed > circleDisplayTime) {
      showCircle = false;
    }
  }
}

void mousePressed() {
  showCircle = true;
  circleStartTime = millis();
  circleX = mouseX;
  circleY = mouseY;
  
  if (sound.isPlaying()) {
    sound.stop(); // 再生中の場合は停止してから再生する
  }
  sound.play();

  for (int i = 0; i < numEggs; i++) {
    if (mouseX > x[i] && mouseX < x[i] + imgWidth && mouseY > y[i] && mouseY < y[i] + imgHeight) {
      if (states[i] == 0) {
        currentImages[i] = tamago2;
        states[i] = 1;
      } else if (states[i] == 1) {
        currentImages[i] = tamago3;
        states[i] = 2;
      } else if (states[i] == 2) {
        currentImages[i] = hiyoko1;
        states[i] = 3;
      } else if (states[i] == 3) {
        currentImages[i] = hiyoko2;
        states[i] = 4;
      } else if (states[i] == 4) {
        currentImages[i] = tobi;
        states[i] = 5;
        speedY[i] = 2; // tobiになったら上に移動
      }
    }
  }
}
