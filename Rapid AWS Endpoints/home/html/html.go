package html

func Welcome() string {
	return (`
	<!DOCTYPE html>
	<html>
		<head>
			<meta charset="utf-8">
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<style>
				img {
				display: block;
				margin-left: auto;
				margin-right: auto;
				}
				</style>
			<title>Rapid Api</title>
			<meta name="description" content="">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<link rel="stylesheet" href="">
		</head>
		<body style="background-color: #2b2e33">
			<img src="https://cdn.discordapp.com/attachments/855448636880191499/953803194172063834/rapid_api.png">
		</body>
	</html>
	`)
}
