import processing.javafx.*;
import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;
import java.util.List;
import processing.video.Capture;

// カメラを使用
Capture cam;
// DeepVisionを使用
DeepVision vision;
// 顔認識のためのツール
CascadeClassifierNetwork faceNetwork;

ResultList<ObjectDetectionResult> detections;

// ここから目の調整の初期化
// 虹彩の色を定義するためのグローバル変数
float irisR = 220;
float irisG = 0;
float irisB = 50;

// 新しい虹彩の色
float newIrisR = irisR;
float newIrisG = irisG;
float newIrisB = irisB;

// まばたきの制御
float eyelidY = 0; // まぶたのY座標
boolean isBlinking = false;
boolean isBlinkingDown = true; // まぶたが下がっている（まばたきが始まっている）かどうかを判断
boolean colorChangeReady = false; // 色の変更準備ができているかどうかを判断

// 目の位置
float eyeX;
float eyeY;

// 目のサイズ
float ellipseWidth = 600;
float ellipseHeight = 450;
// 目の調整の初期化終わり

//顔検出リセットの処理
int noFaceDetectedDuration = 0; // 顔が検出されない時間
int faceLostThreshold = 60; // 顔を「失った」とみなすフレーム数のしきい値
//目の色の処理
int colorChangeInterval = 120; // この値は適宜調整
int frameCounter = 0; // フレームカウンタ
//瞬き関数
int blinkInterval = 5000; // 瞬きの間隔（ミリ秒）
int lastBlinkTime = 0; // 最後に瞬きをした時間
// ハート形の目を表示するための変数
int faceDetectedDuration = 0; // 顔が検出されている時間（フレーム数）
int heartEyesThreshold = 3 * 60; // 5秒（フレームレート60を仮定）
boolean heartEyes = false; // ハート目を表示するかどうか

PImage photo;  // 写真を格納するための変数


void setup() {
  // 背景設定
  fullScreen();
  // スクリーンの中央に目の初期位置を設定
  eyeX = width/2;
  eyeY = height/2;

  // DeepVisionを初期化
  vision = new DeepVision(this);
  // 顔検出を使用
  faceNetwork = vision.createCascadeFrontalFace();
  faceNetwork.setup();

  // カメラのリストを取得し選択
  String[] cams = Capture.list();
  println("Available cameras:");
  for (int i = 0; i < cams.length; i++) {
    println(i + ": " + cams[i]);
  }
  // ここで目的のカメラを選択
  cam = new Capture(this, cams[1]); // 例: リストの2番目のカメラ
  cam.start();

  // 写真を読み込む

  photo = loadImage("aaa.png");
}


void draw() {
  background(255); // 背景を白くする

  if (cam.available()) {
    cam.read();
  }

  // 顔検出を実行
  detections = faceNetwork.run(cam);

  // 顔が検出された場合
  if (detections.size() > 0) {
    faceDetectedDuration++;
    noFaceDetectedDuration = 0;

    ObjectDetectionResult firstDetection = detections.get(0);
    float targetX = (width - firstDetection.getX() * (float(width) / cam.width)) - firstDetection.getWidth() * (float(width) / cam.width) / 2;
    float targetY = firstDetection.getY() * (float(height) / cam.height) + firstDetection.getHeight() * (float(height) / cam.height) / 2;
    eyeX += (targetX - eyeX) * 0.1;
    eyeY += (targetY - eyeY) * 0.1;
  } else {
    // 顔が検出されない場合
    if (noFaceDetectedDuration > faceLostThreshold) {
      // 中央に目をリセット
      eyeX = width / 2;
      eyeY = height / 2;
      faceDetectedDuration = 0; // 認識時間をリセット
    }
    noFaceDetectedDuration++;
  }

  if (faceDetectedDuration > heartEyesThreshold) {
    // 3秒以上顔が認識されたら、写真を表示し続ける
    image(photo, eyeX - photo.width / 2, eyeY - photo.height / 2);
  } else {
    // 通常の目を描画
    drawEye(eyeX, eyeY, 600, 450);
  }

  // 瞬きアニメーションの処理
  if (isBlinking) {
    if (isBlinkingDown) {
      eyelidY += 90; // まぶたを下げる
      if (eyelidY >= height) {
        isBlinkingDown = false;
      }
    } else {
      eyelidY -= 90; // まぶたを上げる
      if (eyelidY <= 0) {
        isBlinking = false; // 瞬きが終わったらフラグをリセット
        isBlinkingDown = true;
      }
    }
  }

  // まぶたを描画
  fill(0);
  rect(0, 0, width, eyelidY);
}



// 目を描画するための関数
void drawEye(float x, float y, float w, float h) {
  // 虹彩
  fill(irisR, irisG, irisB);
  ellipse(x, y, w, h);

  // 瞳孔
  fill(0);
  ellipse(x, y, w * 0.5, h * 0.5);

  // 光の反射
  fill(255);
  ellipse(x - (w * 0.1), y - (h * 0.15), w * 0.15, h * 0.15);
  ellipse(x + (w * 0.05), y - (h * 0.1), w * 0.07, h * 0.07);
}
