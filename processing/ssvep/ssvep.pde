import oscP5.*;
import netP5.*;

OscP5 oscP5;

float[] eeg = new float[256];
int eegPos = 0;

boolean bFft = true;

void setup() {
  size(1280, 1280);
  frameRate(100);
  oscP5 = new OscP5(this, 12346);
}

int flashed = 0;
void draw() {
  background((frameCount / (int)map(mouseX, 0, width, 1, 30)) % 2 == 0 ? 255 : 0);

  //background(255);
  fill(0);
  rect(0, height/2, width, height);
  stroke(128);

  for (int i = 0; i < eeg.length; i++) {
    int i0 = (i + eegPos) % eeg.length;
    int i1 = (i + eegPos + 1) % eeg.length;
    if (bFft) {
      line(i*5, map(eeg[i0], 0, 0.01, height, 0), (i + 1)*5, map(eeg[i1], 0, 0.01, height, 0));
    } else {
      line(i, eeg[i0] + height/2 - mouseY, (i + 1), eeg[i1] + height/2 - mouseY);
    }
  }
}

void oscEvent(OscMessage m) {
  if (bFft) {
    if (m.checkAddrPattern("/openbci/fft")==true) {
      for (int i = 0; i < 250; i++) {
        float v = m.get(i).floatValue();
        eeg[i] = eeg[i] * 0.5 + 0.5 * v;
      }
      return;
    }
  } else {
    if (m.checkAddrPattern("/openbci")==true) {
      float v = m.get(0).floatValue();
      eeg[eegPos] = v * 500;
      eegPos = (eegPos + 1) % eeg.length;
      return;
    }
  }
}