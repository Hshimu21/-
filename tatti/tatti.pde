import processing.javafx.*;
import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;
import processing.video.Capture;

Capture cam;
DeepVision vision = new DeepVision(this);
SSDMobileNetwork network;
ResultList<ObjectDetectionResult> detections;

PVector redSquarePosition;
float redSquareSize = 50;
int score = 0;
int lastScoreTime = 0; // スコアが増加した最後の時刻を記録

public void setup() {
  size(640, 480, FX2D);
  colorMode(HSB, 360, 100, 100);

  println("creating network...");
  network = vision.createHandDetector();

  println("loading model...");
  network.setup();
  network.setConfidenceThreshold(0.7);

  println("setup camera...");
  cam = new Capture(this, "pipeline:autovideosrc");
  cam.start();

  // 赤い四角の初期位置をランダムに設定
  redSquarePosition = new PVector(random(width - redSquareSize), random(height - redSquareSize));
}

public void draw() {
  background(55);

  if (cam.available()) {
    cam.read();
  }

  image(cam, 0, 0);
  
  if(cam.width == 0) {
    return;
  }
  
  detections = network.run(cam);

  noFill();
  strokeWeight(2f);
  stroke(200, 80, 100);
  for (ObjectDetectionResult detection : detections) {
    rect(detection.getX(), detection.getY(), detection.getWidth(), detection.getHeight());
  }

  // 赤い四角を描画
  fill(0, 100, 100);
  rect(redSquarePosition.x, redSquarePosition.y, redSquareSize, redSquareSize);

  // スコアが増加してから1秒が経過するまで次の四角を表示しない
  if (millis() - lastScoreTime > 1000) {
    for (ObjectDetectionResult detection : detections) {
      if (detection.getX() < redSquarePosition.x + redSquareSize &&
          detection.getX() + detection.getWidth() > redSquarePosition.x &&
          detection.getY() < redSquarePosition.y + redSquareSize &&
          detection.getY() + detection.getHeight() > redSquarePosition.y) {
        score++;
        lastScoreTime = millis(); // 最後のスコア時刻を更新
        redSquarePosition.set(random(width - redSquareSize), random(height - redSquareSize));
        break; // 一度触れたら位置を変更
      }
    }
  }

  // スコア表示
  fill(0);
  textSize(32);
  text("Score: " + score, 10, 30);

  surface.setTitle("Hand Detection Game - FPS: " + Math.round(frameRate));
}
