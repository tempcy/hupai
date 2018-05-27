#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
$p3x = $CmdLine[1]
$p3y = $CmdLine[2]
$p4x = $CmdLine[3]
$p4y = $CmdLine[4]
$p5x = $CmdLine[5]
$p5y = $CmdLine[6]
$driftx = $CmdLine[7]
MouseClick("left", $p3x, $p3y, 1, 0)
Sleep(1)
Send("^a")
Sleep(1)
Send($driftx)
Sleep(1)
MouseClick("left", $p4x, $p4y, 1, 0)
Sleep(1)
MouseClick("left", $p5x, $p5y, 1, 0)
Exit