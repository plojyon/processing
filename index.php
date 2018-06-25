<html>
	<head>
		<?php
			header("Expires: Mon, 4 Jan 1999 12:00:00 GMT"); // Expired already
			header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT"); // always modified
			header("Cache-Control: no-cache, must-revalidate"); // good for HTTP/1.1
			header("Pragma: no-cache"); // good for HTTP/1.0
		?>
		<meta charset="UTF-8">
	    <title></title>
		<!--<script language="javascript" type="text/javascript" src="libraries/p5.js"></script>
		<script language="javascript" type="text/javascript" src="sketch_180625a.js"></script>-->
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
		<!-- TODO: Content here -->
		<?php
			if (!isset($_GET['sketch'])) // a sketch was not selected in the parameter
				// print the error message "No sketch selected!" (with styling)
				echo "<div class='error container'><h1 class='error title'>ERROR: No sketch selected!</h1><p class='error content'>Return to the main page and select a sketch. If you encounter a broken link, please contact me at <a href='mailto:yon.ploj@gmail.com'>yon.ploj@gmail.com</a></p></div>";
			else
				// an OK sketch was selected, display it
				include('sketches/'.$_GET['sketch']);
				// TODO: check if sketch exists, and prevent ".." in the sketch name (to prevent XSS)
		?>
	</body>
</html>
