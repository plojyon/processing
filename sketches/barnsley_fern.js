console.log("A barnsley fern generator");
console.log("See https://en.wikipedia.org/wiki/Barnsley_fern");
console.log("Point size and hue are products of the x and y coordinates (+ frame number for hue)");

var x = 0;
var y = 0;
var frame = 0;

function setup() {
	ratio = 0.48386225658; // 4.8378px / 9.9983px
	createCanvas(1000, 1000);
	background(69);
}

function draw() {
	frame++;
	for (i = 0; i < 1000; i++) {
		var r = random(100);
		var nx, xy;
		if (r < 1) { // f1 (1%)
			nx = 0;
			ny = 0.16 * y;
		}
		else if (r < 8) { // f3 (7% + 1%)
			nx = 0.2*x - 0.26*y;
			ny = 0.23*x + 0.22*y + 1.6;
		}
		else if (r < 15) { // f4 (7% + 1%+7%)
			nx = -0.15*x + 0.28*y;
			ny = 0.26*x + 0.24*y + 0.44;
		}
		else { // f2 (85%)
			nx = 0.85*x + 0.04*y;
			ny = -0.04*x + 0.85*y + 1.6;
		}
		x = nx;
		y = ny;

		// −2.1820 < x < 2.6558 and 0 ≤ y < 9.9983
		//px = map(x, -2.1820, 2.6558, 0, width);
		//py = map(y, 0, 9.9983, height, 0);
		px = map(x, -2.1820, 2.6558, 0, width); // 4.8378px wide
		py = map(y, 0, 9.9983, height, 0); // 9.9983px tall

		pos = px*(height-py);
		h = map(pos, 0, height*width, 0, 255);
		colorMode(HSB, 255);
		stroke(color((h+frame)%255, 255, 255));
		strokeWeight(map(pos, 0, height*width, 10, 1));
		point(px, py);
	}
}
