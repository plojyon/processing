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
	    <style></style>
	</head>
	<body>
		<!-- TODO: Content here -->
		<p>Stuff comes here.</p>
		<?php
			if (!isset($_GET['sketch']))
				echo "No sketch selected!\nReturn to the main page and select a sketch. If you encounter a broken link, please contact me at <a href='mailto:yon.ploj@gmail.com'>yon.ploj@gmail.com</a>";
			else
				include('sketches/'.$_GET['sketch']);
		?>
	</body>
</html>
