class World {
	int[][] data = new int[MAP_WIDTH/blockSize][MAP_HEIGHT/blockSize];

	int dmgX = 0; // x and y coordinates of the block (WORLD COORDINATES!! not block coordinates)
	int dmgY = 0;
	int dmgHP = 0;

	void generate() {
		// generate superflat floor
		int groundLevel = DEFgroundLevel;
		for (int i = 0; i < MAP_WIDTH/blockSize; i++) {
			groundLevel = floor(map(noise(i*0.1), 0, 1, DEFgroundLevel, DEFgroundLevel+variation));
			int stoneLevel = floor(map(noise(i*20+10000), 0, 1, groundLevel+1, groundLevel+5));

			for (int j = 0; j < MAP_HEIGHT/blockSize; j++) {
				this.data[i][j] = 0;
				if (j > groundLevel) this.data[i][j] = BLOCK.DIRT;
				if (j == groundLevel) this.data[i][j] = BLOCK.TURF_GRASS;
				if (j > stoneLevel) {
					this.data[i][j] = BLOCK.ROCK;
					if (ceil(random(0, 256)) == 3) this.data[i][j] = BLOCK.DIAMOND;
					if (ceil(random(0, 1024)) == 3) this.data[i][j] = BLOCK.LAPIS;
					if (ceil(random(0, 128)) == 3) this.data[i][j] = BLOCK.GOLD;
					if (ceil(random(0, 64)) == 3) this.data[i][j] = BLOCK.IRON;
					if (ceil(random(0, 32)) == 3) this.data[i][j] = BLOCK.COAL;
					if (ceil(random(0, 128)) == 3) this.data[i][j] = BLOCK.REDSTONE;
				}
			}
		}

		// bedrock border around the world
		for (int i = 0; i < MAP_WIDTH/blockSize; i++) { // TOP AND BOTTOM
			this.data[i][0] = 8;
			this.data[i][MAP_HEIGHT/blockSize-1] = 8;
		}
		for (int i = 0; i < MAP_HEIGHT/blockSize; i++) { // LEFT AND RIGHT
			this.data[0][i] = 8;
			this.data[MAP_WIDTH/blockSize-1][i] = 8;
		}
	}


	void update() {
		worldGraphics.beginDraw();
			worldGraphics.clear();

			// BLOCKS
			worldGraphics.noStroke();
			for (int j = 0; j < MAP_HEIGHT/blockSize; j++) {
				for (int i = 0; i < MAP_WIDTH/blockSize; i++) {
					if (this.data[i][j] != 0) worldGraphics.image(textures.get(this.data[i][j] * blockSize, 0, blockSize, blockSize), toWorld(i), toWorld(j));
				}
			}

		worldGraphics.endDraw();
	}



	void place(int x, int y, int ID) { // block coordinates
		this.data[x][y] = ID;
		this.update();
	}



	boolean hit(int x, int y) { // x and y are world coordinates
		if (data[toBlock(x)][toBlock(y)] == 0) return false; // cannot hit air

		x = toBlock(x);
		y = toBlock(y);
		if (dmgHP <= 0) dmgHP = BLOCK.HEALTH(data[x][y]); // first hit in a series

		if (x == dmgX && y == dmgY) dmgHP--; // successful hit
		else { // hit elsewhere
			dmgHP = BLOCK.HEALTH(data[x][y])-1;
			dmgX = x;
			dmgY = y;
		}
		if (dmgHP == 0) { // breaking hit
			inv.pickup(data[x][y]);
			data[x][y] = 0;
			world.update(); // update if block was broken or placed
		}

		return true;
	}


	int getBlock(int x, int y) { // return block at world coordinates x and y
		return data[toBlock(x)][toBlock(y)];
	}


	boolean isEmpty(int x, int y) { // world coordinates
		if (getBlock(x, y) == 0) return true;
		else return false;
	}
}









class Weather {

	void toggledownfall() {
		print("toggling downfall...");
		if (raindropCount > 0) {
			// is raining
			for (int i = 0; i < raindropCount; i++) {
				rain[i] = null;
			}
			raindropCount = 0;
		}
		else if (raindropCount == 0) {
			// not raining
			for (int i = 0; i < 300; i++) {
				rain[i] = new Raindrop();
				raindropCount++;
			}
		}
	}


	void tick() {
		// rain
		for (int i = 0; i < raindropCount; i++) {
			rain[i].show();
			rain[i].fall();
		}
	}

}








class Tree {
	float x = random(0, MAP_WIDTH);
	float y = DEFgroundLevel;
	float endX = this.x;
	float endY = DEFgroundLevel-HEIGHT/2 + random(-50, 50);
	boolean isBase = true;
	int generation = 0;
	int leafCount = floor(random(2, 4));
	int branchCount = floor(random(2, 5));
	Tree[] leaf = new Tree[leafCount];
	Branch[] branch = new Branch[branchCount];
	Stub leftStub = null;
	Stub rightStub = null;

	void reproduce() {
		// create 2 other branches that multiply recursively
		if (generation < 5) {
			for (int i = 0; i < leafCount; i++) {
				leaf[i] = new Tree();
				leaf[i].x = this.endX;
				leaf[i].y = this.endY;
				int variance = floor(random(10, 50)); if (i % 2 == 0) variance = -variance;
				leaf[i].endX = this.endX + variance;
				leaf[i].endY = this.endY - random(5, 50);
				leaf[i].isBase = false;
				leaf[i].generation = this.generation + 1;
				leaf[i].reproduce();
			}
		}

		if (isBase) {
			leftStub = new Stub();
			rightStub = new Stub();
			leftStub.left = true;
			leftStub.x = this.x-5;
			rightStub.x = this.x+4;

			for (int i = 0; i < branchCount; i++) {
				branch[i] = new Branch();
				if (i % 2 == 0) {
					branch[i].left = true;
					branch[i].x = this.x+5;
				}
				else {
					branch[i].left = false;
					branch[i].x = this.x-5;
				}
				branch[i].y = random(this.endY+50, this.y-50);

			}
		}
	}

	void show() {
		if (isBase) {
			for (int i = 0; i < branchCount; i++) {
				branch[i].show();
			}
			leftStub.show();
			rightStub.show();
			forestGraphics.stroke(140, 70, 20, 255);
			forestGraphics.strokeWeight(20);
		}
		else {
			forestGraphics.stroke(0, 255, 0, 255);
			forestGraphics.strokeWeight(map(generation, 5, 0, 4, 20));
		}
		forestGraphics.line(x, y, endX, endY);
		if (generation < 5) { // has leaves
			for (int i = 0; i < leafCount; i++) {
				leaf[i].show();
			}
		}
	}
}








class Stub {
	float x = 0;
	float y = DEFgroundLevel;
	float size = random(10, 30);
	boolean left = false;

	void show() {
		forestGraphics.fill(140, 70, 20, 255);
		forestGraphics.noStroke();
		if (this.left) forestGraphics.triangle(
				this.x-this.size, this.y, // bottom, by the tree
				this.x+this.size, this.y, // bottom, away from tree
				this.x, this.y-this.size // top, by the tree
			);
		else forestGraphics.triangle(
				this.x, this.y, // bottom by the tree
				this.x+this.size, this.y, // bottom, away from tree
				this.x, this.y-this.size // top, by the tree
			);
	}
}








class Raindrop {
	float x = random(-width, 2*width);
	float y = random(-height, 0);
	float z = random(0, 20);
	float len = map(z, 0, 20, 10, 20); // value from 10 to 20 depending on z order
	float weight = map(z, 0, 20, 0.1, 3); // value fdrom 0.1 to 3 depending on z order
	float speed = map(z, 0, 20, 10, 20); // value from 5 to 15 depending on z order

	void fall() {
		y += speed;
		if (y > (3/2)*height+camera.y) { // fell out of bounds
			x = random(camera.x-width, camera.x+2*width);
			y = camera.y-height/2;
		}
	}

	void show() {
		stroke(0, 0, 255, 100);
		strokeWeight(weight);
		line(x, y, x, y+len);
	}
}









import java.util.*;

final int WIDTH = 2000;
final int HEIGHT = 1000;

final int MAP_WIDTH = 5*WIDTH;
final int MAP_HEIGHT = 3*HEIGHT;

final int blockSize = 50;
final int characterOffset = round((HEIGHT*5)/20); // height:offset = 20:5

int DEFgroundLevel = 20; // in blocks, from top
int variation = 10;

PImage background; // background image
PImage textures; // block textures only
PImage cracks; // cracks textures

final Raindrop[] rain = new Raindrop[1000];
final Tree[] forest = new Tree[50];
final World world = new World();
final Camera camera = new Camera();
final Weather weather = new Weather();
final Inventory inv = new Inventory();
final BlockData BLOCK	= new BlockData();
Dude mainDude;

PGraphics forestGraphics;
PGraphics inventoryGraphics;
PGraphics worldGraphics;
PGraphics backgroundGraphics;

final int treeCount = 3;
int raindropCount = 0;

/*
ANIMATION CONSTANTS
*/
final int WALK_RIGHT = 1;
final int IDLE = 3;
final int WALK_LEFT = 6;

/*
TODO:
load world in chunks
fullscreen inventory display
animate rain instead of particles
please leave multiplayer alone for now
(or dont? *lenny face*)
decide the future of this amazing masterpiece (npcs?)
*/


// === SETUP ===
void setup() {
	size(2000, 1000, P2D);
	frameRate(60);

	mainDude = new Dude();

	background = loadImage("back.png");
	textures = loadImage("blocks.png");
	cracks = loadImage("cracks.png");

	backgroundGraphics = createGraphics(WIDTH, HEIGHT);
	forestGraphics = createGraphics(MAP_WIDTH, MAP_HEIGHT);
	inventoryGraphics = createGraphics(WIDTH, HEIGHT);
	worldGraphics = createGraphics(MAP_WIDTH, MAP_HEIGHT);

	world.generate();
	world.update();

	forestGraphics.beginDraw();
	for (int i = 0; i < treeCount; i++) {
		forest[i] = new Tree();
		forest[i].reproduce();
		forest[i].show();
	}
	forestGraphics.endDraw();

	backgroundGraphics.beginDraw();
	backgroundGraphics.image(background, 0, 0, WIDTH, HEIGHT);
	backgroundGraphics.endDraw();

	inv.update();

	mouseX = width/2;
}



// === DRAW ===
void draw() {
	image(backgroundGraphics, 0, 0); // pre-rendered and resized background image

	pushMatrix();
		translate(-camera.x, -camera.y);

		fill(255, 255, 255, 100); // transparent white rect showing edges of the map
		rect(0, 0, MAP_WIDTH, MAP_HEIGHT);

		weather.tick();
		image(forestGraphics, 0, 0);
		image(worldGraphics, 0, 0);

		// BLOCK CRACKS
		if (world.dmgHP != BLOCK.HEALTH(world.data[world.dmgX][world.dmgY]))
			image(cracks.get(ceil(map(world.dmgHP, BLOCK.HEALTH(world.data[world.dmgX][world.dmgY])-1, 1, 0, 9)) * blockSize, 0, blockSize, blockSize), toWorld(world.dmgX), toWorld(world.dmgY));

	popMatrix();

	camera.tick();
	mainDude.show();

	image(inventoryGraphics, 0, 0);
}



// === INPUT HANDLING ====

void mouseClicked() {
	int x = mouseX+camera.x;
	int y = mouseY+camera.y;
	if (mouseButton == LEFT) {
		world.hit(x, y);
	}
	else if (mouseButton == RIGHT) {
		if (world.isEmpty(x, y))
			inv.place(x, y);
	}
}


void keyPressed() {

	// == MOVEMENT == //
	if ((key == 'd' || key == 'D') && camera.rightVel != 1) {
		camera.rightVel = 1;
		mainDude.animType = WALK_RIGHT;
	}
	if ((key == 'a' || key == 'A') && camera.rightVel != -1) {
		camera.rightVel = -1;
		mainDude.animType = WALK_LEFT;
	}
	if (key == ' ') {
		camera.jump();
	}


	// == CHEATS == //
	if (key == 'b') {
		weather.toggledownfall();
	}
	if (key == 'n') {
		saveFrame("screenshot-######.png");
	}

	// == HOTBAR MANAGEMENT == //
	if (key == '1') {
		inv.selectSlot(0);
	}
	if (key == '2') {
		inv.selectSlot(1);
	}
	if (key == '3') {
		inv.selectSlot(2);
	}
	if (key == '4') {
		inv.selectSlot(3);
	}
	if (key == '5') {
		inv.selectSlot(4);
	}
	if (key == '6') {
		inv.selectSlot(5);
	}
	if (key == '7') {
		inv.selectSlot(6);
	}
	if (key == '8') {
		inv.selectSlot(7);
	}
	if (key == '9') {
		inv.selectSlot(8);
	}
	if (key == '0') {
		inv.selectSlot(9);
	}
	if (key == 'e' || key == 'E') {
		inv.toggleInventory();
	}

}


void keyReleased() {
	if ((key == 'd' || key == 'D') && (camera.rightVel == 1)) {
		camera.rightVel = 0;
		mainDude.animType = IDLE;
	}
	if ((key == 'a' || key == 'A') && (camera.rightVel == -1)) {
		camera.rightVel = 0;
		mainDude.animType = IDLE;
	}
}



void mouseWheel(MouseEvent e) {
	if (e.getCount() > 0)
		inv.selectSlot(inv.selected + 1);
	if (e.getCount() < 0)
		inv.selectSlot(inv.selected - 1);
}


int toBlock(int x) {
	return floor(x/blockSize);
}

int toWorld(int x) {
	return x*blockSize;
}











class BlockData {
	Map<Integer, String> names = new HashMap();
	Map<Integer, Integer> healths = new HashMap();

	String NAME(int ID) {
		return names.get(ID);
	}

	int HEALTH(int ID) {
		return healths.get(ID);
	}


	final int AIR = 0;
	final int TURF_GRASS = 1;
	final int WORKBENCH = 2;
	final int DIRT = 3;
	final int SAND = 4;
	final int ICE = 5;
	final int ROCK = 6;
	final int PEEBLES = 7;
	final int BEDROCK = 8;
	final int WATER = 9;
	final int LAVA = 10;
	final int DIAMOND = 11;
	final int LAPIS = 12;
	final int GOLD = 13;
	final int IRON = 14;
	final int COAL = 15;
	final int REDSTONE = 16;
	final int SPONGE = 17;
	final int TURF_SNOW = 18;
	final int SNOW = 19;
	final int MOSSY = 20;
	final int STUB = 21;
	final int PLANKS = 22;
	final int BRICKS = 23;
	final int DYNAMITE = 24;
	final int IRON_REFINED = 25;
	final int GOLD_REFINED = 26;
	final int DIAMOND_REFINED = 27;
	final int EMERALD_REFINED = 28;


	BlockData() {
		healths.put(AIR, 0);
		healths.put(TURF_GRASS, 5); // grass side
		healths.put(WORKBENCH, 20);
		healths.put(DIRT, 5); // grass bottom
		healths.put(SAND, 5);
		healths.put(ICE, 10);
		healths.put(ROCK, 10);
		healths.put(PEEBLES, 10);
		healths.put(BEDROCK, 0);
		healths.put(WATER, 0);
		healths.put(LAVA, 0);
		healths.put(DIAMOND, 15);
		healths.put(LAPIS, 15);
		healths.put(GOLD, 15);
		healths.put(IRON, 15);
		healths.put(COAL, 10);
		healths.put(REDSTONE, 15);
		healths.put(SPONGE, 2);
		healths.put(TURF_SNOW, 5);
		healths.put(SNOW, 1);
		healths.put(MOSSY, 15);
		healths.put(STUB, 25);
		healths.put(PLANKS, 25);
		healths.put(BRICKS, 25);
		healths.put(DYNAMITE, 1);
		healths.put(IRON_REFINED, 50);
		healths.put(GOLD_REFINED, 50);
		healths.put(DIAMOND_REFINED, 50);
		healths.put(EMERALD_REFINED, 50);

		names.put(AIR, "air");
		names.put(TURF_GRASS, "turf_grass"); // grass side
		names.put(WORKBENCH, "workbench");
		names.put(DIRT, "dirt"); // grass bottom
		names.put(SAND, "sand");
		names.put(ICE, "ice");
		names.put(ROCK, "rock");
		names.put(PEEBLES, "peebles");
		names.put(BEDROCK, "bedrock");
		names.put(WATER, "water");
		names.put(LAVA, "lava");
		names.put(DIAMOND, "diamond");
		names.put(LAPIS, "lapis");
		names.put(GOLD, "gold");
		names.put(IRON, "iron");
		names.put(COAL, "coal");
		names.put(REDSTONE, "redstone");
		names.put(SPONGE, "sponge");
		names.put(TURF_SNOW, "turf_snow");
		names.put(SNOW, "snow");
		names.put(MOSSY, "mossy");
		names.put(STUB, "stub");
		names.put(PLANKS, "planks");
		names.put(BRICKS, "bricks");
		names.put(DYNAMITE, "dynamite");
		names.put(IRON_REFINED, "iron_refined");
		names.put(GOLD_REFINED, "gold_refined");
		names.put(DIAMOND_REFINED, "diamond_refined");
		names.put(EMERALD_REFINED, "emerald_refined");
	}
}












class Inventory {
	int[] items = new int[50]; // which block is in the i-th invenory slot?
	int[] count = new int[50]; // how many blocks are in the i-th inv slot?
	int selected = 0;
	boolean open = false;

	boolean pickup(int ID) {
		for (int i = 0; i < 50; i++) { // find any existing occurences of the item
			if (this.items[i] == ID) {
				this.count[i]++;
				this.update();
				return true;
			}
		}
		for (int i = 0; i < 50; i++) { // no occurence found, attempt to find an empty slot to fill
			if (this.items[i] == 0) {
				this.items[i] = ID;
				this.count[i] = 1;
				this.update();
				return true;
			}
		}
		return false; // no empty slots and no stackable occurences, abort
	}


	void place(int x, int y) { // world coordinates
		if (this.count[this.selected] > 0) {
			world.place(toBlock(x), toBlock(y), this.items[this.selected]); // place block into world
			this.count[this.selected]--; // take one away

			if (this.count[this.selected] == 0) this.items[this.selected] = 0; // remove item entry if count reaches 0
		}
		this.update();
	}


	void selectSlot(int value) {
		if (value >= 10) value -= 10;
		if (value < 0) value += 10; // handle overflow values

		this.selected = value;
		print("slot #"+this.selected+" selected! Owns "+this.count[this.selected]+" of "+this.items[this.selected]+"\n");
		this.update();
	}


	void toggleInventory() {
		if (open) {
			open = false;
		}
		else {
			open = true;
		}
		this.update();
	}


	void update() {
		int X = WIDTH/15; // width of one subcontainer with margin
		int Y = (X-50)/2; // width of the margin

		inventoryGraphics.beginDraw();
		inventoryGraphics.clear();

		inventoryGraphics.translate(WIDTH/6, 0);
		inventoryGraphics.noStroke();

		inventoryGraphics.fill(100, 100, 100);
		inventoryGraphics.rect(-5, 0, 2*WIDTH/3 + 5, 70); // main container

		inventoryGraphics.fill(125, 125, 125);
		inventoryGraphics.rect(this.selected*X + Y - 5, 5, 60, 60); // selection border container

		inventoryGraphics.fill(150, 150, 150); // 10 sub-containers for items
		for (int i = 0; i < 10; i++) {
			inventoryGraphics.rect((i*X) + Y, 10, 50, 50);
			inventoryGraphics.image(textures.get(this.items[i]*blockSize, 0, blockSize, blockSize), i*X + Y, 10, 50, 50);
		}

		// fullscreen inventory window
		if (open) inventoryGraphics.text("[imagine there's an inventory window or something]", 0, 200);

		inventoryGraphics.endDraw(); // finalize
	}
}












class Dude {
	int h = 80;
	int w = (this.h*35)/100;
	int x = width/2-w/2; // coordinates of top left point of dude
	int y = height-characterOffset-h;

	Animation anim;
	int animType = IDLE; // 0-10 the current animation playing

	Dude() { // class constructor (initialization, prepare animation class)
		anim = new Animation();
		anim.tex = loadImage("dudeResized.png");
		anim.maxFrame = 10;
		anim.verticalOffset = IDLE*80;
		anim.frameWidth = 80;
		anim.frameHeight = 80;
		anim.speed = 2;
	}


	void show() {
		anim.show(this.x-this.w, this.y, animType*80);
	}

	// == COLLISION DETECTION ==

	boolean isFalling() {
		if (world.getBlock(camera.x+this.x+5, camera.y+this.y+this.h) != 0 || // left point of dude
			world.getBlock(camera.x+this.x+this.w-5, camera.y+this.y+this.h) != 0 // right point of dude
		) return false;
		return true;
	}

	boolean isFreeLeft() {
		if (camera.x <= 0) return false; // invisible map wall
		if (world.getBlock(camera.x+this.x-5, camera.y+this.y) != 0 || // TOP BLOCK
				world.getBlock(camera.x+this.x-5, camera.y+this.y+this.h-10) != 0 // BOTTOM BLOCK
		) return false;
		else return true;
	}

	boolean isFreeRight() {
		if (camera.x+WIDTH >= MAP_WIDTH) return false; // invisible map wall
		if (world.getBlock(camera.x+this.x+this.w+5, camera.y+this.y) != 0 || // TOP BLOCK
				world.getBlock(camera.x+this.x+this.w+5, camera.y+this.y+this.h-10) != 0 // BOTTOM BLOCK
		) return false;
		else return true;
	}

	boolean isFreeUp() {
		if (world.getBlock(camera.x+this.x+5, camera.y+this.y) != 0 ||					 // left point of dude HEAD
				world.getBlock(camera.x+this.x+this.w-5, camera.y+this.y) != 0 ||		// right point of dude HEAD
				world.getBlock(camera.x+this.x+5, camera.y+this.y-50) != 0 ||				// left point of dude ABOVE HEAD
				world.getBlock(camera.x+this.x+this.w-5, camera.y+this.y-50) != 0 || // right point of dude ABOVE HEAD
				world.getBlock(camera.x+this.x+5, camera.y+this.y+50) != 0 ||				// left point of dude FEET
				world.getBlock(camera.x+this.x+this.w-5, camera.y+this.y+50) != 0		// right point of dude FEET
		) return false;
		return true;
	}
}










class Camera {
	int x = MAP_WIDTH/2 - WIDTH/2, y = DEFgroundLevel*blockSize+characterOffset-HEIGHT;
	float upVelocity = 0;
	int rightVel = 0;
	float gravity = 1;
	int jumpHeight = 11;

	void jump() {
		if (mainDude.isFreeUp() && !mainDude.isFalling() && this.upVelocity == 0) this.upVelocity += jumpHeight;
	}

	void tick() {
		this.y -= this.upVelocity; // apply y velocity
		if (this.upVelocity > 0) this.upVelocity -= this.gravity; // flying, apply gravity to slow down and fall back down

		if (mainDude.isFalling()) { // if not ascending and has nothing below, fall down
			if (this.upVelocity == 0) this.upVelocity = -10;
		}
		else this.upVelocity = 0; // stop falling when hit the ground


		// MOVEMENT LOCKS (x velocity):
		//if (!mainDude.isFalling()) {
			if (rightVel == -1) {
				if (mainDude.isFreeLeft()) {
					this.x -= 10;
				}
				else if (mainDude.isFreeUp() && this.upVelocity == 0 && !mainDude.isFalling()) {
					mainDude.y -= blockSize*1.5;
					if (mainDude.isFreeLeft()) {
						this.upVelocity += jumpHeight;
					}
					mainDude.y += blockSize*1.5;
				}
			}

			if (rightVel == 1) {
				if (mainDude.isFreeRight()) {
					this.x += 10;
				}
				else if (mainDude.isFreeUp() && this.upVelocity == 0 && !mainDude.isFalling()) {
					mainDude.y -= blockSize*1.5;
					if (mainDude.isFreeRight()) {
						this.upVelocity += jumpHeight;
					}
					mainDude.y += blockSize*1.5;
				}
			}
		//}
	}
}











class Branch {
	int odklon = 50;
	float x, y, endX, endY;
	float len = random(50, 100), thickness = map(len, 50, 100, 4, 8);
	boolean left = false;

	void show() {
		if (left) endX = x+odklon;
		else endX = x-odklon;
		endY = y-sqrt((len*len)-(odklon*odklon)); // calculate delta Y using the pythagorean theorem

		forestGraphics.stroke(140, 70, 20, 255);
		forestGraphics.strokeWeight(thickness);
		forestGraphics.line(x, y, endX, endY);
	}
}









class Animation {
	int frame = 0;
	int verticalOffset = 0;
	int maxFrame;
	int speed; // number of ticks per frame (lower number = faster animation)
	int frameWidth;
	int frameHeight;
	PImage tex;

	//Queue<Integer> queue = new LinkedList<Integer>();

	void show(int x, int y, int vOffset) {
		verticalOffset = vOffset;
		image(this.tex.get(floor(frame/speed) * frameWidth, verticalOffset, frameWidth, frameHeight), x, y); // draw dude

		// tick animation
		this.frame++;
		if (this.frame == 10*speed) this.frame = 0;
	}

	/*
	void queueAnimation(int vOffset) {
		queue.add(vOffset);
		print(queue.remove());
	}
	*/
}
