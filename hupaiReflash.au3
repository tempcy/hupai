#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
$p6x = $CmdLine[1]
$p6y = $CmdLine[2]
$p7x = $CmdLine[3]
$p7y = $CmdLine[4]
MouseClick("left", $p6x, $p6y, 1, 0)
Sleep(1)
MouseClick("left", $p7x, $p7y, 1, 0)
Sleep(1)
Send("^a")
Sleep(1)
Send("{DEL}")
Exit