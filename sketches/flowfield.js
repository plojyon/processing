console.log("A simple perlin noise flowfield with translucent trail-leaving particles on retained background");
console.log("The result is an accumulating path on the more crowded parts of the canvas, and highlighted common paths");
console.log("Don't keep the animation running for too long because it gets uglier with time");

function setup() {
	speed = 0.01;/**/
	scl = 5; /*smaller number means smaller squares (more diverse)*/
	noiseScale = 20; /*smaller number means smaller squares (more diverse)*/
	maxSpeed = 5; /*bigger number means faster particles*/
	particleCount = 100; /* how many particles are there*/
	drawGuidelines = false;


	createCanvas(400,400);
	pic = createGraphics(400, 400);
	particles = new Array();
	time = random(0,100000);
	for (var i = 0; i < particleCount; i++) {
		particles[i] = new Particle();
	}
}

function draw() {
	background(255);
	if (drawGuidelines) {
		for (var i = 0; i < width/scl; i++) {
			for (var j = 0; j < height/scl; j++) {
				v = createVector(1,1);
				v.rotate(noise(i/noiseScale, j/noiseScale, time*speed)*TWO_PI);
				v.setMag(scl/2);
				strokeWeight(1);
				line(i*scl+scl/2, j*scl+scl/2, i*scl+scl/2+v.x, j*scl+scl/2+v.y);
				stroke(0,0,0,50); noFill();
				rect(i*scl, j*scl, scl, scl);
			}
		}
	}

	for (p in particles) {
		particles[p].move();
		particles[p].show();
	}
	image(pic, 0, 0);
	time++;
}




function Particle() {
	this.pos = createVector(random(0,width),random(0,height));
	this.prevpos = this.pos.copy();
	this.prevacc = createVector(0,0);
}

Particle.prototype.move = function() {
	var acc = createVector(1,0);
	//var acc = createVector(1,1);
	acc.rotate(noise(floor(this.pos.x/scl)/noiseScale, floor(this.pos.y/scl)/noiseScale, time*speed)*TWO_PI);
	//var dev = createVector(random(0, 1), random(0, 1));
	//acc.add(dev);

	acc.add(this.prevacc);
	this.prevacc = acc;

	acc.setMag(maxSpeed);
	this.pos.add(acc);

	if (this.pos.x <= 0) {
		this.pos.x = width;
		this.prevpos = this.pos.copy();
	}
	if (this.pos.y <= 0) {
		this.pos.y = height;
		this.prevpos = this.pos.copy();
	}
	if (this.pos.x > width) {
		this.pos.x = 0;
		this.prevpos = this.pos.copy();
	}
	if (this.pos.y > height) {
		this.pos.y = 0;
		this.prevpos = this.pos.copy();
	}
}

Particle.prototype.show = function() {
	pic.stroke(0,10);
	pic.strokeWeight(0.5);
	pic.line(this.prevpos.x, this.prevpos.y, this.pos.x, this.pos.y);
	this.prevpos = this.pos.copy();
}
