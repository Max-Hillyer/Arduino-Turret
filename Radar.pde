import processing.serial.*; 
import java.awt.event.KeyEvent;
import java.io.IOException;

Serial myPort;

String angle = "";
String distance = "";
String data = "";

String noObject;

float pixsDistance;

int iAngle, iDistance;

int index1 = 0;
int index2 = 0;

PFont orcFont;

void setup() {
  size(800, 600);  // Change to a smaller window size
  smooth();
  String[] ports= Serial.list();
  for (String port : ports) {
    println(port);
  }
  myPort = new Serial(this, ports[1], 9600);  // Adjust if needed
  myPort.bufferUntil('.'); // Reading angle, distance

  print(myPort);
 
}

void draw() {
  fill(98, 245, 31);
  noStroke();
  
  // Background rectangle (scaled down)
  fill(0, 4); 
  rect(0, 0, width, height - height * 0.065); 
  
  fill(98, 245, 31); // Radar color

  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent(Serial myPort) {
    try {
        data = myPort.readStringUntil('.');
        
        // Check if the data is valid
        if (data != null && data.length() > 2) {
            data = data.trim();  // Remove any leading/trailing spaces
            data = data.substring(0, data.length() - 1); // Remove the period
            
            index1 = data.indexOf(",");  // Find the comma separating angle and distance
            if (index1 > 0) {
                angle = data.substring(0, index1);
                distance = data.substring(index1 + 1);
                iAngle = int(angle);
                iDistance = int(distance);
            } else {
                println("Error: Invalid data format, no comma found.");
            }
        } else {
            println("Error: Incomplete or invalid data received.");
        }
    } catch (Exception e) {
        println("Error reading serial data: " + e.getMessage());
    }
}


void drawRadar() {
  pushMatrix();
  translate(width / 2, height - height * 0.074);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  // Drawing the arc lines (scaled down)
  arc(0, 0, (width - width * 0.0625), (width - width * 0.0625), PI, TWO_PI);
  arc(0, 0, (width - width * 0.27), (width - width * 0.27), PI, TWO_PI);
  arc(0, 0, (width - width * 0.479), (width - width * 0.479), PI, TWO_PI);
  arc(0, 0, (width - width * 0.687), (width - width * 0.687), PI, TWO_PI);
  
  // Drawing the angle lines (scaled down)
  line(-width / 2, 0, width / 2, 0);    
  line(0, 0, (-width / 2) * cos(radians(30)), (-width / 2) * sin(radians(30)));
  line(0, 0, (-width / 2) * cos(radians(60)), (-width / 2) * sin(radians(60)));
  line(0, 0, (-width / 2) * cos(radians(90)), (-width / 2) * sin(radians(90)));
  line(0, 0, (-width / 2) * cos(radians(120)), (-width / 2) * sin(radians(120)));
  line(0, 0, (-width / 2) * cos(radians(150)), (-width / 2) * sin(radians(150)));
  line((-width / 2) * cos(radians(30)), 0, width / 2, 0);
  popMatrix();
}

void drawObject() {
    pushMatrix();
    translate(width / 2, height - height * 0.074);
    strokeWeight(9);
    stroke(255, 10, 10); // red 

    pixsDistance = iDistance * ((height - height * 0.1666) * 0.025); // converting the distance from cm to pixels

    // If distance is below 40 cm, draw the object, otherwise, ignore it
    if (iDistance < 40) {
        float angleRad = radians(iAngle);

        // Adjust angle to ensure it's always within 0 to 180 degrees (or 0 to -180 degrees)
        if (iAngle > 180) {
            // Ensure that angle stays within 0-180 for proper rendering
            iAngle -= 360;  // Adjust angle back within a 180-degree range if needed
        }

        // Convert polar coordinates to cartesian coordinates for the object position
        float x1 = pixsDistance * cos(angleRad);
        float y1 = -pixsDistance * sin(angleRad);
        float x2 = (width - width * 0.505) * cos(angleRad);
        float y2 = -(width - width * 0.505) * sin(angleRad);

        // Draw the object as a line from the center of the radar to the object
        line(x1, y1, x2, y2);
    }
    popMatrix();
}



void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(width / 2, height - height * 0.074); 
  line(0, 0, (height - height * 0.12) * cos(radians(iAngle)), -(height - height * 0.12) * sin(radians(iAngle)));
  popMatrix();
}

void drawText() { 
  pushMatrix();
  if (iDistance > 40) {
    noObject = "Out of Range";
  } else {
    noObject = "In Range";
  }
  
  fill(0, 0, 0);
  noStroke();
  rect(0, height - height * 0.0648, width, height);
  fill(98, 245, 31);
  textSize(15);  // Reduced font size
  
  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);
  textSize(30);  // Reduced font size
  text("Angle:  " + iAngle + " °", width - width * 0.48, height - height * 0.0277);
  text("Distance:  ", width - width * 0.26, height - height * 0.0277);
 
  if (iDistance < 40) {
    text("             " + iDistance + " cm", width - width * 0.225, height - height * 0.0277);
    fill(255, 10, 10);
    text("WARNING!", width - width * 0.875, height - height * 0.0277);
  }
  
  textSize(20);  // Reduced font size
  fill(98, 245, 60);
  
  // Adjusting the angle text for each section (scaled down)
  translate((width - width * 0.4994) + width / 2 * cos(radians(30)), (height - height * 0.0907) - width / 2 * sin(radians(30)));
  rotate(-radians(-60));
  text("30°", 0, 0);
  resetMatrix();
  
  translate((width - width * 0.503) + width / 2 * cos(radians(60)), (height - height * 0.0888) - width / 2 * sin(radians(60)));
  rotate(-radians(-30));
  text("60°", 0, 0);
  resetMatrix();
  
  translate((width - width * 0.507) + width / 2 * cos(radians(90)), (height - height * 0.0833) - width / 2 * sin(radians(90)));
  rotate(radians(0)); 
  text("90°", 0, 0);
  resetMatrix();
  
  translate(width - width * 0.513 + width / 2 * cos(radians(120)), (height - height * 0.07129) -width / 2 * sin(radians(120)));
  rotate(radians(-30));
  text("120°", 0, 0);
  resetMatrix();
  
  translate((width - width * 0.5104) + width / 2 * cos(radians(150)), (height - height * 0.0574) - width / 2 * sin(radians(150)));
  rotate(radians(-60));
  text("150°", 0, 0);
  popMatrix(); 
}
