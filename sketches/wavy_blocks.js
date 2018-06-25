function setup() {
	createCanvas(1000, 1000, WEBGL);
	w = 20;
	h = 20;
	size = 40;
	tick = 0;
}

function draw() {
	background(127);
	ortho();
	translate(0,-400,0);
	rotateX(QUARTER_PI);
	rotateY(-QUARTER_PI);

	tick++;
	normalMaterial();

	for (var i = 0; i < w; i++) {
		for (var j = 0; j < h; j++) {
			push();
			translate(i*size, sin(i*j*tick/1000)*size, j*size);
			box(size);
			pop();
		}
	}
}
