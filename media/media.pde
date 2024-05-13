/***
  名前  志村歩佳 
  行ったこと: MEDIAスロットを作りました！それぞれ5つの文字がランダムに変わっています。
  マウスクリックでスタートし、もう一度マウスクリックで全部一気に止まります。また1～5のキーを押すとひとつずつ止まります。
  全部止まっている時に再度マウスクリックで再スタートできます！全部のスロットが止まるとBGMも止まります。MEDIA揃うと別の効果音が流れます。
  また上部にはMEDIAの文字がずっと流れるようにしました！
  ***/

import processing.sound.*;
SoundFile file;
SoundFile winSound;  // 勝利の音源

String[] characters = {"M", "E", "D", "I", "A"};
String[] slotCharacters = {"", "", "", "", ""};
boolean[] running = {true, true, true, true, true};  // 各スロットが回転中かどうかを示すフラグ

float xPosRight = 0;
float xPosLeft = 0;

void setup() {
  size(800, 600);
  PFont font = createFont("Arial", 32);
  textFont(font);
  textAlign(CENTER, CENTER);
  frameRate(50);
  file = new SoundFile(this, "kaiten.mp3");
  winSound = new SoundFile(this, "jaja.mp3");  // 勝利の音源をロード
}

void draw() {
  background(255);
  fill(0);

  // 全てのスロットが停止しているかのフラグ
  boolean allStopped = true;

  for (int i = 0; i < 5; i++) {
    if (running[i]) {
      slotCharacters[i] = characters[(int) random(characters.length)];
      // スロットが回転しているものがあればフラグを下ろす
      allStopped = false;
    }

    fill(200);
    rect(120 + i * 120, height / 2 - 50, 80, 100);
    fill(0);
    text(slotCharacters[i], 160 + i * 120, height / 2);
  }

  if (!allStopped && !file.isPlaying()) {
    file.play();
  } else if (allStopped && file.isPlaying()) {
    file.stop();
  }
  //
  if (allStopped) {
    checkWin();
  }

  fill(random(255), random(255), random(255));
  
  // テキストを右
  for (float i = xPosRight; i < width; i += textWidth("MEDIA")) {
    text("MEDIA", i, 100);
  }

  xPosRight += 2;
  if (xPosRight > textWidth("MEDIA")) {
    xPosRight = 0;
  }
  
  // テキストを左
  for (float i = width - xPosLeft; i > -textWidth("MEDIA"); i -= textWidth("MEDIA")) {
    text("MEDIA", i, 150);
  }

  xPosLeft += 2;
  if (xPosLeft > textWidth("MEDIA")) {
    xPosLeft = 0;
  }
}

// マウスクリックで全てのスロットを同時に開始/停止
void mouseClicked() {
  for (int i = 0; i < running.length; i++) {
    running[i] = !running[i];
  }
}

// キー入力で対応するスロットを停止
void keyPressed() {
  if (key == '1') running[0] = false;
  if (key == '2') running[1] = false;
  if (key == '3') running[2] = false;
  if (key == '4') running[3] = false;
  if (key == '5') running[4] = false;
}

// 勝利を確認し、勝利の音を再生
void checkWin() {
  if (slotCharacters[0].equals("M") && slotCharacters[1].equals("E") && slotCharacters[2].equals("D")
      && slotCharacters[3].equals("I") && slotCharacters[4].equals("A")) {
    winSound.play();
  }
}
