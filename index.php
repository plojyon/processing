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
				background-position: center;
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
			$sketches = array("flowfield", "wavy_blocks", "barnsley_fern", "knots", "shtikmen");
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
			/*
			// all OK (found .js)
			elseif (remote_exists($sketches_dir.$_GET['sketch'].'.js')) {
				// print the <script> include tag to load the sketch javascript
				echo '<h1 id="sketch-title">'.$_GET['sketch'].'</h1>';
				echo '<script src="'.$sketches_dir.$_GET['sketch'].'.js"></script>';
				echo '
				<style>
					body { margin: 0; text-align: center; }
					#sketch-title:after { content: ".js"; }
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
					#sketch-title:after { content: ".pde"; }
				</style>';
			}
			*/
			elseif (remote_exists($sketches_dir.$_GET['sketch'].'.js'))
				load_sketch($sketches_dir, $_GET['sketch'], '.js');

			elseif (remote_exists($sketches_dir.$_GET['sketch'].'.pde'))
				load_sketch($sketches_dir, $_GET['sketch'], '.pde');

			else // no such sketch found (404)
				report("Sketch does not exist", "The selected sketch (".$_GET['sketch'].") was not found.");


			// fetches a sketch from github and overwrites the local copy
			// then redirects the user to the newly created sketch
			function load_sketch($dir, $name, $extension) {
				// 0. if project is already locally stored, delete it
				if (file_exists('sketches/'.$name))
					deleteDir('sketches/'.$name);
				mkdir('sketches/'.$name);

				// 1. generate index.html
				$index = '<h1 id="sketch-title">'.$name.$extension.'</h1>';
				if ($extension === ".js")
					$index .= '<script src="'.$name.'.js"></script>';
					$index .= '<script src="https://github.com/processing/p5.js/releases/download/0.5.7/p5.js"></script>';
				elseif ($extension === ".pde")
					$index .= '<canvas data-processing-sources="'.$name.'.pde"></canvas>';
					$index .= '<script src="https://raw.github.com/processing-js/processing-js/v1.4.8/processing.js"></script>';
				$index .= '
				<style>
					body {
						margin: 0;
						text-align: center;
					}
					#sketch-title {
						border-bottom: 2px dashed black;
						padding: 1em 0;
						margin: 0 auto 2em auto;
						width: 40%;
					}
					canvas {
						border: 10px ridge black;
					}
				</style>';
				file_put_contents('sketches/'.$name.'/index.html', $index);

				// 2. fetch source file from Github
				$source = file_get_contents($dir.'/'.$name.$extension);
				file_put_contents('sketches/'.$name.'/'.$name.$extension, $source);

				// 3. TODO: check for additional media files
				//   3.1 TODO: download additional files, possibly overwriting existing data

				// 4. redirect user to the newly created index.html
				header('Location: sketches/'.$name.'/index.html');
				die();
			}

			// echoes a pretty-formated sketch div for the main page (with thumbnail)
			function add_sketch($sketch, $thumbnail_dir) {
				echo '
				<div class="container" onclick="window.location.href = \'?sketch='.$sketch.'\';">
					<div class="thumbnail" style="background-image: url(\''.$thumbnail_dir.$sketch.'.png\');"></div>
					<div class="description">'.$sketch.'</div>
				</div>';
			}

			// echoes an error report div
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
			// source: StackOverflow (https://stackoverflow.com/questions/2280394/how-can-i-check-if-a-url-exists-via-php)
			function remote_exists($url) {
				$headers = get_headers($url);
				return stripos($headers[0], "200 OK") ? true:false; // return actual boolean
			}

			// recursively deletes a non-empty directory
			// source: StackOverflow (https://stackoverflow.com/questions/3349753/delete-directory-with-files-in-it)
			function deleteDir($dirPath) {
				if (!is_dir($dirPath)) throw new InvalidArgumentException("$dirPath must be a directory");
				if (substr($dirPath, strlen($dirPath) - 1, 1) != '/') $dirPath .= '/';
				$files = glob($dirPath . '*', GLOB_MARK);
				foreach ($files as $file) {
					if (is_dir($file)) self::deleteDir($file);
					else unlink($file);
				}
				rmdir($dirPath);
			}
		?>
	</body>
</html>
