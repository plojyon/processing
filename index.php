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
		<?php
			if (!isset($_GET['sketch'])) {// a sketch was not selected in the parameter
				// display the sketch selection page
				echo 'Welcome to the sketch selection page!';
			}
			elseif (!preg_match('/^[a-z0-9_]+$/i', $_GET['sketch'])) { // match string with only alphanumeric characters and underscores
				// print the error message for XSS attempt (with styling)
				echo "<div class='error container'><h1 class='error title'>ERROR: Invalid sketch name!</h1><p class='error content'>Sketch names can only contain letters, digits or underscores. Please utilize the sketch selection screen to proceed and do not attempt to 'hack' your way in.<br><br>If you encountered a bug or believe this is a mistake, do not hesitate to contact me <a href='mailto:yon.ploj@gmail.com'>yon.ploj@gmail.com</a></p></div>";
			}
			else {
				// an OK sketch was selected, display it
				// TODO: check if sketch exists
				include('sketches/'.$_GET['sketch']);
				echo 'Sketch "'.$_GET['sketch'].'" goes here';
			}
		?>
	</body>
</html>
