#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
$p9x = $CmdLine[1]
$p9y = $CmdLine[2]
$p10x = $CmdLine[3]
$p10y = $CmdLine[4]
MouseClick("left", $p9x, $p9y, 1, 0)
Sleep(1)
MouseClick("left", $p10x, $p10y, 1, 0)
Exit