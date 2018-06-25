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
	    <style>
			body {
				font-family: sans-serif;
			}
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
			$sketches = $site."sketches/";

			// a sketch was NOT selected in the parameter
			if (!isset($_GET['sketch'])) {
				// display the sketch selection page
				echo 'Welcome to the sketch selection page!'; // TODO: make an actual page
			}
			// sketch name validation - match string with only alphanumeric characters and underscores
			elseif (!preg_match('/^[a-z0-9_]+$/i', $_GET['sketch'])) {
				report("Invalid sketch name", "Sketch names can only contain letters, digits or underscores.");
				// this is used to prevent XSS (via the use of "../../fishy_stuff.exe")
			}
			// no such sketch found (404)
			elseif (!remote_exists($sketches.$_GET['sketch'].'.js')) {
				report("Sketch does not exist", "The selected sketch (".$_GET['sketch'].") was not found.");
			}
			// all OK
			else {
				// print the <script> include tag to load the sketch javascript
				echo '<h1 id="title">'.$_GET['sketch'].'</h1>';
				echo '<script src="'.$sketches.$_GET['sketch'].'.js"></script>';
				echo '
				<style>
					body {
						margin: 0;
						padding: 0;
						text-align: center;
					}
					#title {
						border-bottom: 2px dashed black;
						padding: 1em 0;
						margin: 0 auto 2em auto;
						width: 40%;
					}
					#title:after {
						content: ".js";
					}
					canvas {
						border: 10px ridge black;
					}
				</style>';
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

			// checks if a file exists on a remote directory
			function remote_exists($url){
				$headers=get_headers($url);
				return stripos($headers[0],"200 OK")?true:false;
			}
		?>
	</body>
</html>
