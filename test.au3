#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
;#Include <_Dbug.au3> ;for debug
#include <Misc.au3>
#include <GuiListBox.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
; Script Start - Add your code below here
Opt("WinTitleMatchMode", 2)
Global Const $g_sFontColor = "FF0000" ;包含信息字符的颜色
Global Const $g_iSimilarColor = 196 ; 包含信息字符颜色的允许差
Global Const $g_iSimilarFont = 5 ;包含信息字符点阵的允许差
#Region ### START Koda GUI section ### Form=c:\work\form_setting.kxf
$Form_Setting = GUICreate("Setting", 331, 244, 364, 346, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
$Tab_Setting = GUICtrlCreateTab(0, 0, 330, 210)
$TabSheet_Lib = GUICtrlCreateTabItem("建立字库")
GUICtrlSetState(-1,$GUI_SHOW)
$ButtonLibBuilder = GUICtrlCreateButton("开始", 131, 175, 65, 29)
$Checkbox1 = GUICtrlCreateCheckbox("数字1", 49, 40, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox2 = GUICtrlCreateCheckbox("数字2", 49, 64, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox3 = GUICtrlCreateCheckbox("数字3", 49, 88, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox4 = GUICtrlCreateCheckbox("数字4", 49, 112, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox5 = GUICtrlCreateCheckbox("数字5", 49, 136, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox10 = GUICtrlCreateCheckbox("符号：", 229, 40, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox6 = GUICtrlCreateCheckbox("数字6", 139, 40, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox7 = GUICtrlCreateCheckbox("数字7", 139, 64, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox8 = GUICtrlCreateCheckbox("数字8", 139, 88, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox9 = GUICtrlCreateCheckbox("数字9", 139, 112, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox0 = GUICtrlCreateCheckbox("数字0", 139, 136, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox11 = GUICtrlCreateCheckbox("换行符_", 229, 64, 60, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateTabItem("")
$ButtonApply = GUICtrlCreateButton("应用", 131, 210, 65, 29)
$ButtonSave = GUICtrlCreateButton("保存", 196, 210, 65, 29)
$ButtonCancel = GUICtrlCreateButton("放弃", 261, 210, 65, 29)
$ButtonStart = GUICtrlCreateButton("启动F11", 1, 210, 65, 29)
$ButtonBreak = GUICtrlCreateButton("停止Pause", 66, 210, 65, 29)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
Func HandleGuiMsg()
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $ButtonLibBuilder
			SetButtonState($GUI_DISABLE)
			GUICtrlSetData($ButtonLibBuilder, "处理中")
			GUICtrlSetState($ButtonLibBuilder, $GUI_DISABLE)
			;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & 'BuildLib()' & @CRLF & @CRLF & 'Return:' & @CRLF & "lag here!") ;### Debug MSGBOX
			BuildLib()
			SetButtonState($GUI_ENABLE)
			GUICtrlSetData($ButtonLibBuilder, "开始")
			GUICtrlSetState($ButtonLibBuilder, $GUI_ENABLE)
	EndSwitch
EndFunc
Func SetButtonState($StateCode)
	GUICtrlSetState($ButtonStart, $StateCode)
	GUICtrlSetState($ButtonBreak, $StateCode)
	GUICtrlSetState($ButtonApply, $StateCode)
	GUICtrlSetState($ButtonSave, $StateCode)
	GUICtrlSetState($ButtonCancel, $StateCode)
EndFunc
Func BuildLib() ;run chlibbuild.exe to check if all numbers and necessary symbols are included
	ToolTip("准备文档中，请等待...",@DesktopWidth / 2,@DesktopWidth / 2, "", $TIP_WARNINGICON, $TIP_CENTER)
	While WinKill("字库建造工具")
		Sleep(1000)
		;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & 'WinKill("字库建造工具---已注册！")' & @CRLF & @CRLF & 'Return:' & @CRLF & "kill found!") ;### Debug MSGBOX
	WEnd
	Run("ChLibBuilder.exe", @ScriptDir)
	;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & 'Run("ChLibBuilder.exe", @ScriptDir)' & @CRLF & @CRLF & 'Return:' & @CRLF & "Run ChLibBuilder.exe ok!") ;### Debug MSGBOX
	WinWait("字库建造工具")
	WinActivate("字库建造工具")
	Send("^o")
	WinWait("另存为")
	WinActivate("另存为")
	Send("hupai.txt{ENTER}!s")
	Sleep(100)
	WinActivate("字库建造工具")
	Sleep(100)
	ControlSetText("字库建造工具", "", "[CLASS:TEdit; INSTANCE:17]", $g_sFontColor)
	Sleep(100)
	ControlSetText("字库建造工具", "", "[CLASS:TEdit; INSTANCE:8]", $g_iSimilarColor)
	Sleep(100)
	ControlSetText("字库建造工具", "", "[CLASS:TEdit; INSTANCE:15]", $g_iSimilarFont)
	Sleep(100)
	Local $LibComplete = False
	Local $aCB = [$Checkbox0,$Checkbox1,$Checkbox2,$Checkbox3,$Checkbox4,$Checkbox5,$Checkbox6,$Checkbox7,$Checkbox8,$Checkbox9,$Checkbox10,$Checkbox11]
	Local $hEdit = ControlGetHandle("字库建造工具", "", "[CLASS:TEdit; INSTANCE:16]")
	For $hCB In $aCB
		GUICtrlSetState($hCB, $GUI_ENABLE + $GUI_UNCHECKED)
	Next
	ToolTip("")
	MsgBox(262144,"准备好了","切换到拍牌页面（或者测试页面moni.51hupai.org），看到时间和价格信息，然后点确定！");esc退出
	While Not $LibComplete
		WinActivate("字库建造工具")
		Send("!yt")
		Do
			$aMouse = MouseGetPos()
			ToolTip("框选时间和价格信息区域！然后按回车！", $aMouse[0], $aMouse[1] - 25)
			If _IsPressed("1B") Then
				ToolTip("")
				WinActivate("字库建造工具")
				Send("^s")
				Return
			EndIf
			Sleep(25)
		Until _IsPressed("0D")
		ToolTip("")
		Sleep(100)
		WinActivate("字库建造工具")
		Send("^{ENTER}")
		Sleep(500)
		Local $hLB = ControlGetHandle("字库建造工具", "", "[CLASS:TListBox; INSTANCE:1]")
		Local $iCnt = _GUICtrlListBox_GetCount($hLB)
		For $n = 0 To $iCnt - 1
			$n = _GUICtrlListBox_GetCaretIndex($hLB);重置位置，防止位置和计数不同步
			ControlFocus("字库建造工具", "", "[CLASS:TEdit; INSTANCE:16]")
			$sChr = ControlGetText("字库建造工具", "", "[CLASS:TEdit; INSTANCE:16]")
			If $sChr = "" Then
			;If _GUICtrlListBox_GetSel($hLB, $n) Then
				Do
					$aMouse = MouseGetPos()
					ToolTip("输入字符，按回车确认！或者空格键跳过该字符！", $aMouse[0], $aMouse[1] - 25)
					If _IsPressed("1B") Then
						ToolTip("")
						WinActivate("字库建造工具")
						Send("^s")
						Return
					EndIf
					If  _IsPressed("20") Then
						Do
							Sleep(25)
						Until Not _IsPressed("20")
						Send("{DOWN}")
						ExitLoop
					EndIf
					Sleep(25)
				Until _IsPressed("0D")
				ToolTip("")
				Sleep(1000)
				ChrCheck(_GUICtrlListBox_GetText($hLB, $n))
			Else
				ChrCheck($sChr)
				Send("{DOWN}")
			EndIf
		Next
		$LibComplete = True
		For $hCB In $aCB
			If GUICtrlRead($hCB) = $GUI_UNCHECKED Then
				$LibComplete = False
				Do
					$aMouse = MouseGetPos()
					ToolTip("字符不完整，准备好时间和价格信息，然后按退格键继续！", $aMouse[0], $aMouse[1] - 25)
					If _IsPressed("1B") Then
						ToolTip("")
						WinActivate("字库建造工具")
						Send("^s")
						Return
					EndIf
					Sleep(25)
				Until _IsPressed("08")
				ToolTip("")
				ExitLoop
			EndIf
		Next
	WEnd
	MsgBox(262144,"完成","字符检查完整！请点确定返回！")
	WinActivate("字库建造工具")
	Send("^s")
EndFunc   ;==>BuildLib

Func ChrCheck($chr)
	Switch $chr
		Case "0"
			GUICtrlSetState($Checkbox0, $GUI_CHECKED)
		Case "1"
			GUICtrlSetState($Checkbox1, $GUI_CHECKED)
		Case "2"
			GUICtrlSetState($Checkbox2, $GUI_CHECKED)
		Case "3"
			GUICtrlSetState($Checkbox3, $GUI_CHECKED)
		Case "4"
			GUICtrlSetState($Checkbox4, $GUI_CHECKED)
		Case "5"
			GUICtrlSetState($Checkbox5, $GUI_CHECKED)
		Case "6"
			GUICtrlSetState($Checkbox6, $GUI_CHECKED)
		Case "7"
			GUICtrlSetState($Checkbox7, $GUI_CHECKED)
		Case "8"
			GUICtrlSetState($Checkbox8, $GUI_CHECKED)
		Case "9"
			GUICtrlSetState($Checkbox9, $GUI_CHECKED)
		Case ":"
			GUICtrlSetState($Checkbox10, $GUI_CHECKED)
		Case "_"
			GUICtrlSetState($Checkbox11, $GUI_CHECKED)
	EndSwitch
EndFunc

;mainloop
While 1
	;handle message
	HandleGuiMsg()
WEnd

