



float angle = 0;

ArrayList<PVector> vectors = new ArrayList<PVector>();
PVector rotation = new PVector(0, 0, 100);

// r(beta) = 0.8 + 1.6 * sin(6 * beta)
// theta(beta) = 2 * beta
// phi(beta) = 0.6 * pi * sin(12 * beta)

// r(beta) = 1.2 * 0.6 * sin(0.5 * pi + 6 * beta)
// theta(beta) = 4 * beta
// phi(beta) = 0.2 * pi * sin(6 * beta)

//x = r * cos(phi) * cos(theta)
//y = r * cos(phi) * sin(theta)
//z = r * sin(phi)

int speed = 15; // the only true parameter
int type = 0;

float beta = 0;
float len = 1;//0.1; // doesnt matter if it's dynamically changed in draw()
boolean dynamic = true;
int startIndex = 0;
int verticesCount = 0;
boolean redrawing = false;

void setup() {
    size(600, 400, P3D);
    makeShape();
    verticesCount = vectors.size()/2;
    sphereDetail(10);
}

void draw() {
    background(0);
    pushMatrix();
    //rotateX((height/2-mouseY)*0.01);
    //rotateY((mouseX-width/2)*0.01);
    
    //rotateX(millis()/1000.0);
    //rotateY(millis()/1010.0);
    
    rotateX(rotation.x);
    rotateY(rotation.y);
    
    //lights();
    directionalLight(255, 255, 255, 0, 0.1, -0.4); // TOP
    ambientLight(20, 20, 20);
    
    popMatrix();
    translate(width/2, height/2, rotation.z); // translate for camera
    rotateX(rotation.x);
    rotateY(rotation.y);
    
    stroke(255);
    noFill();//fill(100, 127, 0);
    box(1000);
    
    if (dynamic) {
    	float x = ((float)millis()/100.0); // x is the number of 0.1s that passed
    	x %= 200; // x is between 0 and 200
    	len = f(x/100);
    }
    
    //noFill();
    strokeWeight(8);
    
    /*
    //beginShape();
    int endIndex = (startIndex+(int)(len*verticesCount));
    for (int i = startIndex; i < endIndex; i++) {
        PVector v1 = vectors.get(i);
        PVector v2 = vectors.get(i+2);
        fill(255);
        noStroke();//stroke(255);//stroke((noise((i%verticesCount)*0.03)*255) % 255);
        //vertex(v.x, v.y, v.z);
        
        line3d(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
    }
    //endShape();
    */
    fill(255);
    noStroke();//stroke(255);//stroke((noise((i%verticesCount)*0.03)*255) % 255);
    
    if (!redrawing) {
        beginShape();
        int endIndex = (startIndex+(int)(len*verticesCount));
        for (int i = startIndex; i < endIndex; i++) {
            pushMatrix();
            PVector v = vectors.get(i);
            translate(v.x, v.y, v.z);
            sphere(8);
            popMatrix();
        }
        endShape();
        
        startIndex += speed;
        startIndex %= verticesCount;
    }
}




/* CAMERA MANIPULATION */
void mouseDragged() {
    rotation.y += (mouseX - pmouseX)*0.01;
    rotation.x += -(mouseY - pmouseY)*0.01;
}

void mouseWheel(MouseEvent event) {
    rotation.z -= event.getCount()*20;
}

void mousePressed() {
	if (mouseButton == RIGHT) {
    	redrawing = true;
    	type++;
    	type %= 2;
    	vectors = new ArrayList<PVector>();
    	makeShape();
    	verticesCount = vectors.size()/2;
    	redrawing = false;
	}
}

/*
void line3d(float x1, float y1, float z1, float x2, float y2, float z2) {
    beginShape();
    vertex(x1, y1, z1);
    vertex(x1+1, y1+1, z1+1);
    vertex(x2, y2, z2);
    vertex(x2+1, y2+1, z2+1);
    endShape(CLOSE);

}
*/


/* "PYRAMID" FUNTION */
float f(float n) {
    if (n < 1) return n;
    else return 2-n;
}


/* KNOT GENERATOR */
void makeShape() {
    beta = 0;
	while (true) {
        float r = getR(type);
        float theta = getTheta(type);
        float phi = getPhi(type);
        
        r *= 100;
          
        float x = r * cos(phi) * cos(theta);
        float y = r * cos(phi) * sin(theta);
        float z = r * sin(phi);
        
        vectors.add(new PVector(x,y,z));
        
        beta += 0.001;
        
        if (beta > TWO_PI) return;
    }
}




/* GED'DRS */
float getR(int type) {
    if (type == 0) return 1.2 * 0.6 * sin(HALF_PI + 6 * beta);
    else return 0.8 + 1.6 * sin(6 * beta);
}

float getTheta(int type) {
    if (type == 0) return 4 * beta;
    else return 2 * beta;
}

float getPhi(int type) {
   if (type == 0) return 0.2 * PI * sin(6 * beta);
   else return 0.6 * PI * sin(12 * beta);
}
