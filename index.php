<html>
	<head>
		<?php
			// cache prevention (relevant because i'm dual hosting this website)
			// do not judge me! i have my reasons!
			// ..also it's not like anyone will ever use this
			header("Expires: Mon, 4 Jan 1999 12:00:00 GMT"); // Expired already
			header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT"); // always modified
			header("Cache-Control: no-cache, must-revalidate"); // good for HTTP/1.1
			header("Pragma: no-cache"); // good for HTTP/1.0
		?>
		<meta charset="UTF-8">
	    <title>Jatan's Processing page</title>
		<script src="https://github.com/processing/p5.js/releases/download/0.5.7/p5.js"></script>
		<script src="https://raw.github.com/processing-js/processing-js/v1.4.8/processing.js"></script>
	    <style>
			/****************/
			/* GLOBAL RULES */
			/****************/
			body {
				font-family: sans-serif;
				padding-bottom: 5em; /* big sketches should have space at the bottom */
			}


			/********************************/
			/* SKETCH SELECTION PAGE (main) */
			/********************************/
			#sketches .container {
				border: 1px solid black;
				box-shadow: 0 0 5px black;
				display: inline-block;
				width: 20em;
				height: 20em;
				cursor: pointer;
				margin: 1em;
			}
			#sketches .thumbnail {
				height: 18em;
				background-repeat: no-repeat;
				background-size: cover;
			}
			#sketches .description {
				font-weight: bold;
				text-align: center;
				padding-top: 0.5em;
				border-top: 1px dashed black;
			}
			h1#select-title {
				border-bottom: 2px dashed black;
				padding: 1em 0;
				margin: 0 auto 2em auto;
				width: 40%;
				text-align: center;
				text-transform: uppercase;
			}
			div#sketches {
				display: flex;
				flex-wrap: wrap;
				justify-content: center;
			}


			/***********************/
			/* SKETCH DISPLAY PAGE */
			/***********************/
			#sketch-title {
				border-bottom: 2px dashed black;
				padding: 1em 0;
				margin: 0 auto 2em auto;
				width: 40%;
			}
			#sketch-title:after {
				content: ".js";
			}
			canvas {
				border: 10px ridge black;
			}


			/**************/
			/* ERROR PAGE */
			/**************/
			.error {
				color: red;
			}
			.error.container {
				background-color: pink;
				border: 1px solid red;
				padding: 1em;
			}
		</style>
	</head>
	<body>
		<?php
			$site = "https://plojyon.github.io/processing/";
			$sketches_dir = $site."sketches/";
			$thumbnail_dir = $site."thumbnails/";
			$sketches = array("flowfield", "wavy_blocks", "barnsley_fern", "knots");
			$sketch_count = count($sketches);

			// a sketch was NOT selected in the parameter
			if (!isset($_GET['sketch'])) {
				// display the sketch selection page
				echo '
				<style>
					body { padding: 2em 3em; }
				</style>';

				echo "
				<section>
					<h1 id='select-title'>Select a sketch</h1>
					<div id='sketches'>";
				for ($i = 0; $i < $sketch_count; $i++) {
					add_sketch($sketches[$i], $thumbnail_dir);
				}
				echo "
					</div>
				</section>";
			}
			// sketch name validation - match string with only alphanumeric characters and underscores
			elseif (!preg_match('/^[a-z0-9_]+$/i', $_GET['sketch'])) {
				report("Invalid sketch name", "Sketch names can only contain letters, digits or underscores.");
				// this is used to prevent XSS (via the use of "../../fishy_stuff.exe")
			}
			// all OK (found .js)
			elseif (remote_exists($sketches_dir.$_GET['sketch'].'.js')) {
				// print the <script> include tag to load the sketch javascript
				echo '<h1 id="sketch-title">'.$_GET['sketch'].'</h1>';
				echo '<script src="'.$sketches_dir.$_GET['sketch'].'.js"></script>';
				echo '
				<style>
					body { margin: 0; text-align: center; }
				</style>';
			}
			// all OK (found .pde)
			elseif (remote_exists($sketches_dir.$_GET['sketch'].'.pde')) {
				// print the <canvas> element for the .pde file
				echo '<h1 id="sketch-title">'.$_GET['sketch'].'</h1>';
				echo '<canvas data-processing-sources="'.$sketches_dir.$_GET['sketch'].'.pde"></canvas>';
				echo '
				<style>
					body { margin: 0; text-align: center; }
				</style>';
			}
			// no such sketch found (404)
			else {
				report("Sketch does not exist", "The selected sketch (".$_GET['sketch'].") was not found.");
			}


			function add_sketch($sketch, $thumbnail_dir) {
				echo '
				<div class="container" onclick="window.location.href = \'?sketch='.$sketch.'\';">
					<div class="thumbnail" style="background-image: url(\''.$thumbnail_dir.$sketch.'.png\');"></div>
					<div class="description">'.$sketch.'</div>
				</div>';
			}


			// prints a pretty error report
			function report($title, $content) {
				echo "
				<div class='error container'>
					<h1 class='error title'>ERROR: ".$title."!</h1>
					<p class='error content'>
						".$content."
						Please utilize the <a href='.'>sketch selection page</a>
						to proceed and do not attempt to 'hack' your way in.
						<br>
						<br>
						<b>If you encountered a bug or believe this is a mistake,
						do not hesitate to contact me at
						<a href='mailto:yon.ploj@gmail.com'>yon.ploj@gmail.com</a></b>
					</p>
				</div>";
			}

			// checks if a file exists, but works on remote directories too (http://)
			function remote_exists($url) {
				$headers = get_headers($url);
				return stripos($headers[0], "200 OK") ? true:false; // return actual boolean
			}
		?>
	</body>
</html>
