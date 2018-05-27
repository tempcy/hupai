#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

If $CmdLine[0] = 0 Then
	Global $Source_left = 0
	Global $Source_top = 0
	Global $Source_width = 200
	Global $Source_height = 100
	Global $MagFactor = 2
	Global $Mag_left = -1
	Global $Mag_top = -1
	Global $mouseview = 1
ElseIf $CmdLine[0] = 7 Then
	Global $Source_left = $CmdLine[1]
	Global $Source_top = $CmdLine[2]
	Global $Source_width = $CmdLine[3]
	Global $Source_height = $CmdLine[4]
	Global $MagFactor = $CmdLine[5]
	Global $Mag_left = $CmdLine[6]
	Global $Mag_top = $CmdLine[7]
	Global $mouseview = 0
EndIf
$Mag_width = Int($Source_width * $MagFactor)
$Mag_height = Int($Source_height * $MagFactor)
$Form_Mag = GUICreate("hupaiMag", $Mag_width + 6, $Mag_height + 28, $Mag_left, $Mag_top, 0, $WS_EX_TOPMOST)
GUISetState(@SW_SHOW)

Global $MyHDC = WinGetHandle("hupaiMag")

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
	Sleep(25)
	MAG()
WEnd

Func MAG()
	$MyHDC = DLLCall("user32.dll","int","GetDC","hwnd",$Form_Mag)
	$DeskHDC = DLLCall("user32.dll","int","GetDC","hwnd",0)
	If $mouseview = 1 Then
		$pCursor = MouseGetPos()
		$Source_left = $pCursor[0] - Int($Source_width / 2)
		$Source_top = $pCursor[1] - Int($Source_height / 2)
	EndIf
	DLLCall("gdi32.dll","int","StretchBlt","int",$MyHDC[0],"int",0,"int",0,"int",$Mag_width,"int",$Mag_height, _
		"int",$DeskHDC[0],"int",$Source_left,"int",$Source_top,"int",$Source_width,"int",$Source_height,"long",$SRCCOPY)
	DLLCall("user32.dll","int","ReleaseDC","int",$DeskHDC[0],"hwnd",0)
	DLLCall("user32.dll","int","ReleaseDC","int",$MyHDC[0],"hwnd",$Form_Mag)
EndFunc

HotKeySet("{ESC}", "_EXIT")
Func _EXIT()
	Exit
EndFunc

