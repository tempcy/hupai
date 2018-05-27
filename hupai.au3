#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         Tempcy

 Script Function:AutoBid for Hupai
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here
;~ #Include <_Dbug.au3> ;for debug
Opt("WinTitleMatchMode", 2)
$g_szVersion = "hupai20180518"
If WinExists($g_szVersion) Then
	MsgBox(16,"程序即将退出!","检测到程序副本~~程序无法重复运行~~请按确定退出!!")
	Exit
EndIf
AutoItWinSetTitle($g_szVersion)

;可变参数
Global Const $g_sLastMinute = "11:29:" ;最后一分钟文本
Global Const $g_sFontColor = "FF0000" ;包含信息字符的颜色
Global Const $g_iSimilarColor = 196 ; 包含信息字符颜色的允许差
Global Const $g_iSimilarFont = 5 ;包含信息字符点阵的允许差

#Include <Array.au3>
#include <ButtonConstants.au3>
#Include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiListBox.au3>
#include <GuiListView.au3>
#include <GuiStatusBar.au3>
#include <Misc.au3>
#include <ScreenCapture.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WinAPIError.au3>
#include <WinAPIGdi.au3>
#include <WindowsConstants.au3>
#pragma compile(AutoItExecuteAllowed, true)

;var setup
Global $oString, $status, $time, $price, $beforetime, $difference, $tt, $fps, $lag, $bid2price, $bid3price, $bid4price ; 信息
Global $bid2time, $bid3time, $check3time, $apply3time, $msec, $bcl, $ucl, $lcl, $drift2, $drift3a, $drift3b, $drift3c, $acl ; 参数
Global $p1x, $p1y, $p2x, $p2y, $p3x, $p3y, $p4x, $p4y, $p5x, $p5y, $p6x, $p6y, $p7x, $p7y, $p8x, $p8y, $p9x, $p9y, $p10x, $p10y ; 坐标
Global $current_point, $second_last, $price_last, $aData[61][7]  ; 记录
Global $g_bPaused, $g_bPosCal, $g_bInfo, $g_bPriceLog, $g_bBeep, $g_bLatency, $g_bLibBuilding ; 标志
Global $g_bMagnify, $p_idMagnify, $g_dMagFactor, $MagSource_left, $MagSource_top, $MagSource_width, $MagSource_height, $Magnify_left, $Magnify_top ; 放大镜

;data form : last 1 minute price log
$Form_Data = GUICreate("PriceLog", 180, 720, 300, 400, $WS_THICKFRAME, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
Local $ListViewData = GUICtrlCreateListView("序号|时间|价格|可接受时间|跳价估算|本地时间|备注", 2, 2, 175, 688)
For $i = 0 to 60
	$aData[$i][0] = $i
Next
_GUICtrlListView_AddArray($ListViewData, $aData)

#Region ### START Koda GUI section ### Form=c:\work\form_info.kxf
$Form_Info = GUICreate("Info", 424, 79, 391, 286, $WS_POPUP, $WS_EX_TOPMOST)
GUISetBkColor(0xA6CAF0)
$LabelTime = GUICtrlCreateLabel("11:00:00", 0, 0, 176, 56, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
GUICtrlSetFont(-1, 30, 800, 0, "Microsoft YaHei UI")
$LabelDiff = GUICtrlCreateLabel("diff", 180, 0, 99, 56, $SS_RIGHT, $GUI_WS_EX_PARENTDRAG)
GUICtrlSetFont(-1, 30, 800, 0, "Microsoft YaHei UI")
$LabelPrice = GUICtrlCreateLabel("00000", 288, 0, 129, 56, $SS_RIGHT, $GUI_WS_EX_PARENTDRAG)
GUICtrlSetFont(-1, 30, 800, 0, "Microsoft YaHei UI")
$StatusBar_Info = _GUICtrlStatusBar_Create($Form_Info)
Dim $StatusBar_Info_PartsWidth[7] = [55, 95, 140, 195, 265, 335, -1]
_GUICtrlStatusBar_SetParts($StatusBar_Info, $StatusBar_Info_PartsWidth)
_GUICtrlStatusBar_SetText($StatusBar_Info, "??:??:??", 0)
_GUICtrlStatusBar_SetText($StatusBar_Info, "fps??", 1)
_GUICtrlStatusBar_SetText($StatusBar_Info, "???ms", 2)
_GUICtrlStatusBar_SetText($StatusBar_Info, "status ?", 3)
_GUICtrlStatusBar_SetText($StatusBar_Info, "bid2 ?????", 4)
_GUICtrlStatusBar_SetText($StatusBar_Info, "bid3 ?????", 5)
_GUICtrlStatusBar_SetText($StatusBar_Info, "bid4 ?????", 6)
_GUICtrlStatusBar_SetBkColor($StatusBar_Info, 0xF0CAA6)
_GUICtrlStatusBar_SetMinHeight($StatusBar_Info, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;~ GUIRegisterMsg($WM_NCHITTEST,"INFOWM_NCHITTEST") ;Gui drag
;~ Func INFOWM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
;~ EndFunc   ;==>INFOWM_NCHITTEST

#Region ### START Koda GUI section ### Form=c:\work\form_pos.kxf
$Form_Pos = GUICreate("Pos", 467, 412, 644, 453, 0, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
$TabPos = GUICtrlCreateTab(0, 0, 465, 385)
$TabSheet_Pic1 = GUICtrlCreateTabItem("位置1~5")
$Pic1 = GUICtrlCreatePic("C:\work\hupai1.jpg", 8, 24, 450, 353)
$TabSheet_Pic2 = GUICtrlCreateTabItem("位置6~9")
$Pic2 = GUICtrlCreatePic("C:\work\hupai2.jpg", 8, 24, 450, 353)
$TabSheet_Pic3 = GUICtrlCreateTabItem("位置10")
$Pic3 = GUICtrlCreatePic("C:\work\hupai3.jpg", 8, 24, 450, 353)
GUICtrlCreateTabItem("")
$StatusBar_Pos = _GUICtrlStatusBar_Create($Form_Pos)
Dim $StatusBar_Pos_PartsWidth[6] = [120, 150, 185, 215, 250, -1]
_GUICtrlStatusBar_SetParts($StatusBar_Pos, $StatusBar_Pos_PartsWidth)
_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & "mouse position :", 0)
_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & @TAB & "X =", 1)
_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & "????", 2)
_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & @TAB & "Y =", 3)
_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & "????", 4)
_GUICtrlStatusBar_SetText($StatusBar_Pos, "提示：请使用鼠标中键设定位置坐标", 5)
_GUICtrlStatusBar_SetMinHeight($StatusBar_Pos, 25)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=c:\work\form_setting.kxf
$Form_Setting = GUICreate("Setting", 331, 244, 364, 346, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
$Tab_Setting = GUICtrlCreateTab(0, 0, 330, 210)

$TabSheet_RM = GUICtrlCreateTabItem("说明")
GUICtrlSetState(-1,$GUI_SHOW)
$EditRemark = GUICtrlCreateEdit("", 6, 27, 318, 178, BitOR($ES_AUTOVSCROLL,$ES_WANTRETURN,$WS_VSCROLL))
GUICtrlSetData(-1, "EditRemark")

$TabSheet_Lib = GUICtrlCreateTabItem("建立字库")
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

$TabSheet_Pos = GUICtrlCreateTabItem("屏幕坐标")
$ButtonPosCal = GUICtrlCreateButton("校准", 131, 175, 65, 29)
$Inputp1x = GUICtrlCreateInput("????", 56, 48, 33, 21)
$Inputp2x = GUICtrlCreateInput("????", 56, 72, 33, 21)
$Inputp3x = GUICtrlCreateInput("????", 56, 96, 33, 21)
$Inputp4x = GUICtrlCreateInput("????", 56, 120, 33, 21)
$Inputp5x = GUICtrlCreateInput("????", 56, 144, 33, 21)
$Inputp6x = GUICtrlCreateInput("????", 240, 48, 33, 21)
$Inputp7x = GUICtrlCreateInput("????", 240, 72, 33, 21)
$Inputp8x = GUICtrlCreateInput("????", 240, 96, 33, 21)
$Inputp9x = GUICtrlCreateInput("????", 240, 120, 33, 21)
$Inputp10x = GUICtrlCreateInput("????", 240, 144, 33, 21)
$Inputp1y = GUICtrlCreateInput("????", 96, 48, 33, 21)
$Inputp2y = GUICtrlCreateInput("????", 96, 72, 33, 21)
$Inputp3y = GUICtrlCreateInput("????", 96, 96, 33, 21)
$Inputp4y = GUICtrlCreateInput("????", 96, 120, 33, 21)
$Inputp5y = GUICtrlCreateInput("????", 96, 144, 33, 21)
$Inputp6y = GUICtrlCreateInput("????", 280, 48, 33, 21)
$Inputp7y = GUICtrlCreateInput("????", 280, 72, 33, 21)
$Inputp8y = GUICtrlCreateInput("????", 280, 96, 33, 21)
$Inputp9y = GUICtrlCreateInput("????", 280, 120, 33, 21)
$Inputp10y = GUICtrlCreateInput("????", 280, 144, 33, 21)
$LabelLX = GUICtrlCreateLabel("X", 72, 27, 11, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelLy = GUICtrlCreateLabel("Y", 112, 27, 11, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP8 = GUICtrlCreateLabel("位置8", 200, 99, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP7 = GUICtrlCreateLabel("位置7", 200, 75, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP9 = GUICtrlCreateLabel("位置9", 200, 123, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP10 = GUICtrlCreateLabel("位置10", 200, 147, 40, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP1 = GUICtrlCreateLabel("位置1", 16, 51, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP2 = GUICtrlCreateLabel("位置2", 16, 75, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP3 = GUICtrlCreateLabel("位置3", 16, 99, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP4 = GUICtrlCreateLabel("位置4", 16, 123, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP5 = GUICtrlCreateLabel("位置5", 16, 147, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelP6 = GUICtrlCreateLabel("位置6", 200, 51, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelRx = GUICtrlCreateLabel("X", 256, 27, 11, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelRy = GUICtrlCreateLabel("Y", 296, 27, 11, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)

$TabSheet_Para = GUICtrlCreateTabItem("时间和价格")
$InputB2T = GUICtrlCreateInput("??", 100, 54, 25, 21)
$InputB3T = GUICtrlCreateInput("??", 100, 78, 25, 21)
$InputC3T = GUICtrlCreateInput("??", 100, 102, 25, 21)
$InputA3T = GUICtrlCreateInput("??", 100, 174, 25, 21)
$InputMsec = GUICtrlCreateInput("???", 132, 174, 33, 21)
$InputUCL = GUICtrlCreateInput("???", 212, 126, 33, 21)
$InputLCL = GUICtrlCreateInput("???", 212, 150, 33, 21)
$InputACL = GUICtrlCreateInput("???", 212, 174, 33, 21)
$InputD2P = GUICtrlCreateInput("???", 284, 54, 33, 21)
$InputD3P = GUICtrlCreateInput("???", 284, 78, 33, 21)
$InputDBP = GUICtrlCreateInput("???", 284, 102, 33, 21)
$InputDCP = GUICtrlCreateInput("???", 284, 126, 33, 21)
$LabelBid2_C = GUICtrlCreateLabel("二次出价", 12, 57, 52, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelBid3_C = GUICtrlCreateLabel("三次出价", 12, 81, 52, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelCheck3_C = GUICtrlCreateLabel("补抢检查", 12, 105, 52, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelApply3_C = GUICtrlCreateLabel("强制确认", 12, 177, 52, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelTime_R = GUICtrlCreateLabel("时间", 68, 33, 28, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelSec_R = GUICtrlCreateLabel("秒", 107, 33, 16, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelMsec_R = GUICtrlCreateLabel("毫秒", 134, 33, 28, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelConment_R = GUICtrlCreateLabel("说明", 172, 33, 28, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelLimmit_R = GUICtrlCreateLabel("价差", 216, 33, 28, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelHotkey_R = GUICtrlCreateLabel("按键", 252, 33, 30, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelDrift_R = GUICtrlCreateLabel("加价", 288, 33, 28, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelF7_K = GUICtrlCreateLabel("F7", 260, 57, 22, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelF10_K = GUICtrlCreateLabel("F10", 260, 81, 22, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelF8_K = GUICtrlCreateLabel("F8", 260, 105, 22, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelF9_K = GUICtrlCreateLabel("F9", 260, 129, 22, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelBlock_M = GUICtrlCreateLabel("阻塞<", 172, 105, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelLCL_M = GUICtrlCreateLabel("超差>", 172, 129, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelUCL_M = GUICtrlCreateLabel("超差<", 172, 153, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LabelDiff_M = GUICtrlCreateLabel("差额=", 172, 177, 34, 17)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$InputBCL = GUICtrlCreateInput("???", 212, 102, 33, 21)

$TabSheet_Tools = GUICtrlCreateTabItem("工具")
$CheckboxPricelog = GUICtrlCreateCheckbox("数据记录", 20, 41, 65, 17)
$CheckboxMagn = GUICtrlCreateCheckbox("验证码放大镜", 20, 73, 97, 17)
$CheckboxInfo = GUICtrlCreateCheckbox("信息提示", 20, 105, 65, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$CheckboxLatency = GUICtrlCreateCheckbox("服务器延迟", 20, 169, 81, 17)
$ButtonCopyLog = GUICtrlCreateButton("复制记录", 168, 37, 65, 25)
$ButtonSetLogWidth = GUICtrlCreateButton("自动展宽", 248, 37, 65, 25)
$SliderMagFactor = GUICtrlCreateSlider(240, 72, 81, 25)
GUICtrlSetLimit(-1, 12, 4)
GUICtrlSetData(-1, 8)
GUICtrlSetState(-1, $GUI_DISABLE)
$ButtonSetMag = GUICtrlCreateButton("区域设定", 168, 69, 65, 25)
$CheckboxBeep = GUICtrlCreateCheckbox("按键提示音", 20, 137, 81, 17)

GUICtrlCreateTabItem("")
$ButtonApply = GUICtrlCreateButton("应用", 131, 210, 65, 29)
$ButtonSave = GUICtrlCreateButton("保存", 196, 210, 65, 29)
$ButtonCancel = GUICtrlCreateButton("放弃", 261, 210, 65, 29)
$ButtonStart = GUICtrlCreateButton("启动F11", 1, 210, 65, 29)
$ButtonBreak = GUICtrlCreateButton("停止Pause", 66, 210, 65, 29)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;read ini file
$p1x = IniRead("hupai.ini", "Display", "Point1x", "0")
$p1y = IniRead("hupai.ini", "Display", "Point1y", "0")
$p2x = IniRead("hupai.ini", "Display", "Point2x", "0")
$p2y = IniRead("hupai.ini", "Display", "Point2y", "0")
$p3x = IniRead("hupai.ini", "Display", "Point3x", "0")
$p3y = IniRead("hupai.ini", "Display", "Point3y", "0")
$p4x = IniRead("hupai.ini", "Display", "Point4x", "0")
$p4y = IniRead("hupai.ini", "Display", "Point4y", "0")
$p5x = IniRead("hupai.ini", "Display", "Point5x", "0")
$p5y = IniRead("hupai.ini", "Display", "Point5y", "0")
$p6x = IniRead("hupai.ini", "Display", "Point6x", "0")
$p6y = IniRead("hupai.ini", "Display", "Point6y", "0")
$p7x = IniRead("hupai.ini", "Display", "Point7x", "0")
$p7y = IniRead("hupai.ini", "Display", "Point7y", "0")
$p8x = IniRead("hupai.ini", "Display", "Point8x", "0")
$p8y = IniRead("hupai.ini", "Display", "Point8y", "0")
$p9x = IniRead("hupai.ini", "Display", "Point9x", "0")
$p9y = IniRead("hupai.ini", "Display", "Point9y", "0")
$p10x = IniRead("hupai.ini", "Display", "Point10x", "0")
$p10y = IniRead("hupai.ini", "Display", "Point10y", "0")
$bid2time = IniRead("hupai.ini", "Second", "Bid2", "0")
$bid3time = IniRead("hupai.ini", "Second", "Bid3", "0")
$check3time = IniRead("hupai.ini", "Second", "Check3", "0")
$apply3time = IniRead("hupai.ini", "Second", "Apply3", "0")
$msec = IniRead("hupai.ini", "Second", "MSec", "0")
$bcl = IniRead("hupai.ini", "Check", "BCL", "0")
$ucl = IniRead("hupai.ini", "Check", "UCL", "0")
$lcl = IniRead("hupai.ini", "Check", "LCL", "0")
$drift2 = IniRead("hupai.ini", "Drift", "Drift2", "0")
$drift3a = IniRead("hupai.ini", "Drift", "Drift3", "0")
$drift3b = IniRead("hupai.ini", "Drift", "Drift3U", "0")
$drift3c = IniRead("hupai.ini", "Drift", "Drift3L", "0")
$acl = IniRead("hupai.ini", "Drift", "DifferenceLimit", "0")
$g_bInfo = IniRead("hupai.ini", "Tools", "Info", "1")
$g_bPriceLog = IniRead("hupai.ini", "Tools", "PriceLog", "0")
$g_bMagnify = IniRead("hupai.ini", "Tools", "Magnify", "0")
$g_bLatency = IniRead("hupai.ini", "Tools", "Latency", "0")
$g_bBeep = IniRead("hupai.ini", "Tools", "Beep", "0")
$g_dMagFactor = IniRead("hupai.ini", "Tools", "MagFactor", "0")
$MagSource_left = IniRead("hupai.ini", "Tools", "Source_left", "0")
$MagSource_top = IniRead("hupai.ini", "Tools", "Source_top", "0")
$MagSource_width = IniRead("hupai.ini", "Tools", "Source_width", "0")
$MagSource_height = IniRead("hupai.ini", "Tools", "Source_height", "0")
$Magnify_left = IniRead("hupai.ini", "Tools", "Magnify_left", "0")
$Magnify_top = IniRead("hupai.ini", "Tools", "Magnify_top", "0")

;ocr obj create
ShellExecuteWait("regsvr32.exe", "/s " & "SimPlugOCR.dll", @AppDataDir)
Global $oShell = ObjCreate("simplugocr.ocr")
If $oShell = 0 Then
	MsgBox(0, "警告", "注册OCR控件失败！")
	Exit
EndIf
$oShell.SetDict("hupai.txt")
$oShell.SetFontColor($g_sFontColor)
$oShell.similarcolor = $g_iSimilarColor
$oShell.similarfont = $g_iSimilarFont

;hotkeys
HotKeySet("{PAUSE}", "TogglePause")
HotKeySet("{F11}", "RestartMainLoop")
HotKeySet("{F7}", "Bid2nd")
HotKeySet("{F10}", "Bid3rd")
HotKeySet("{F8}", "BidBlock")
HotKeySet("{F9}", "BidCheckout")
HotKeySet("{NUMPADMULT}", "ReflashChptcha")
HotKeySet("{NUMPADSUB}", "CancelBid")
HotKeySet("{NUMPADADD}", "ApplyBid")

;functions
Func GuiInit()
	RestoreParameter()
	InitializeInfo()
	InitializeData()
	If $g_bMagnify = 1 Then
		InitializeMagn()
	EndIf
EndFunc   ;==>GuiInit

Func RestoreParameter() ;restore parameters in setting window from variable
	GUICtrlSetData($InputB2T, $bid2time)
	GUICtrlSetData($InputB3T, $bid3time)
	GUICtrlSetData($InputC3T, $check3time)
	GUICtrlSetData($InputA3T, $apply3time)
	GUICtrlSetData($InputMsec, $msec)
	GUICtrlSetData($InputBCL, $bcl)
	GUICtrlSetData($InputUCL, $ucl)
	GUICtrlSetData($InputLCL, $lcl)
	GUICtrlSetData($InputACL, $acl)
	GUICtrlSetData($InputD2P, $drift2)
	GUICtrlSetData($InputD3P, $drift3a)
	GUICtrlSetData($InputDBP, $drift3b)
	GUICtrlSetData($InputDCP, $drift3c)
	GUICtrlSetData($Inputp1x, $p1x)
	GUICtrlSetData($Inputp1y, $p1y)
	GUICtrlSetData($Inputp2x, $p2x)
	GUICtrlSetData($Inputp2y, $p2y)
	GUICtrlSetData($Inputp3x, $p3x)
	GUICtrlSetData($Inputp3y, $p3y)
	GUICtrlSetData($Inputp4x, $p4x)
	GUICtrlSetData($Inputp4y, $p4y)
	GUICtrlSetData($Inputp5x, $p5x)
	GUICtrlSetData($Inputp5y, $p5y)
	GUICtrlSetData($Inputp6x, $p6x)
	GUICtrlSetData($Inputp6y, $p6y)
	GUICtrlSetData($Inputp7x, $p7x)
	GUICtrlSetData($Inputp7y, $p7y)
	GUICtrlSetData($Inputp8x, $p8x)
	GUICtrlSetData($Inputp8y, $p8y)
	GUICtrlSetData($Inputp9x, $p9x)
	GUICtrlSetData($Inputp9y, $p9y)
	GUICtrlSetData($Inputp10x, $p10x)
	GUICtrlSetData($Inputp10y, $p10y)
	If $g_bInfo = 0 Then
		GUICtrlSetState($CheckboxInfo, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($CheckboxInfo, $GUI_CHECKED)
	Endif
	If $g_bPriceLog = 0 Then
		GUICtrlSetState($CheckboxPricelog, $GUI_UNCHECKED)
		GUICtrlSetState($ButtonCopyLog, $GUI_DISABLE)
		GUICtrlSetState($ButtonSetLogWidth, $GUI_DISABLE)
	Else
		GUICtrlSetState($CheckboxPricelog, $GUI_CHECKED)
		GUICtrlSetState($ButtonCopyLog, $GUI_ENABLE)
		GUICtrlSetState($ButtonSetLogWidth, $GUI_ENABLE)
	EndIf
	If $g_bMagnify = 0 Then
		GUICtrlSetState($CheckboxMagn, $GUI_UNCHECKED)
		GUICtrlSetState($ButtonSetMag, $GUI_DISABLE)
		GUICtrlSetState($SliderMagFactor, $GUI_DISABLE)
	Else
		GUICtrlSetState($CheckboxMagn, $GUI_CHECKED)
		GUICtrlSetState($ButtonSetMag, $GUI_ENABLE)
		GUICtrlSetState($SliderMagFactor, $GUI_ENABLE)
	EndIf
	If $g_bLatency = 0 Then
		GUICtrlSetState($CheckboxLatency, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($CheckboxLatency, $GUI_CHECKED)
	EndIf
	If $g_bBeep = 0 Then
		GUICtrlSetState($CheckboxBeep, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($CheckboxBeep, $GUI_CHECKED)
	EndIf
	GUICtrlSetData($EditRemark, FileRead("readme.txt"))
EndFunc   ;==>RestoreParameter

Func InitializeInfo()
	GUICtrlSetData($LabelTime, "11:00:00")
	GUICtrlSetData($LabelDiff, "Dif")
	GUICtrlSetData($LabelPrice, "00000")
	_GUICtrlStatusBar_SetText($StatusBar_Info, "fps??", 1)
	_GUICtrlStatusBar_SetText($StatusBar_Info, "???ms", 2)
	_GUICtrlStatusBar_SetText($StatusBar_Info, "status 1", 3)
	_GUICtrlStatusBar_SetText($StatusBar_Info, "bid2 ?????", 4)
	_GUICtrlStatusBar_SetText($StatusBar_Info, "bid3 ?????", 5)
	_GUICtrlStatusBar_SetText($StatusBar_Info, "bid4 ?????", 6)
	If $g_bInfo = 0 Then
		GUISetState(@SW_HIDE, $Form_Info)
	Else
		GUISetState(@SW_SHOW, $Form_Info)
	EndIf
EndFunc   ;==>InitializeInfo

Func InitializeData()
	for $i = 0 to 60
		_GUICtrlListView_AddSubItem($ListViewData, $i, "", 1)
		_GUICtrlListView_AddSubItem($ListViewData, $i, "", 2)
		_GUICtrlListView_AddSubItem($ListViewData, $i, "", 3)
		_GUICtrlListView_AddSubItem($ListViewData, $i, "", 4)
		_GUICtrlListView_AddSubItem($ListViewData, $i, "", 5)
		_GUICtrlListView_AddSubItem($ListViewData, $i, "", 6)
	Next
	If $g_bPriceLog = 0 Then
		GUISetState(@SW_HIDE, $Form_Data)
	Else
		GUISetState(@SW_SHOW, $Form_Data)
	EndIf
EndFunc   ;==>InitializeData

Func InitializeMagn()
	If Not $p_idMagnify Then
		If ($Magnify_left > @DesktopWidth) Or ($Magnify_top > @DesktopHeight) Then
			$Magnify_left = Int(@DesktopWidth / 2)
			$Magnify_top = Int(@DesktopHeight / 2)
		EndIf
		$p_idMagnify = Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaiMag.au3 ' _
			& $MagSource_left & " " & $MagSource_top & " " & $MagSource_width & " " & $MagSource_height & " " _
			& $g_dMagFactor & " " & $Magnify_left & " " & $Magnify_top)
	EndIf
EndFunc   ;==>InitializeMagn

Func GuiCustom();move tool windows to where it used to be
	$iTempLeft = IniRead("hupai.ini", "Display", "Setting_left", 100)
	$iTempTop = IniRead("hupai.ini", "Display", "Setting_top", 100)
	If ($iTempLeft > @DesktopWidth) Or ($iTempTop > @DesktopHeight) Then
		$iTempLeft = Int(@DesktopWidth / 2)
		$iTempTop = Int(@DesktopHeight / 2)
	EndIf
	WinMove("Setting", "",$iTempLeft, $iTempTop)
	$iTempLeft = IniRead("hupai.ini", "Display", "Info_left", 100)
	$iTempTop = IniRead("hupai.ini", "Display", "Info_top", 100)
	If ($iTempLeft > @DesktopWidth) Or ($iTempTop > @DesktopHeight) Then
		$iTempLeft = Int(@DesktopWidth / 2)
		$iTempTop = Int(@DesktopHeight / 2)
	EndIf
	WinMove("Info", "", $iTempLeft, $iTempTop)
	$iTempLeft = IniRead("hupai.ini", "Display", "Pos_left", 100)
	$iTempTop = IniRead("hupai.ini", "Display", "Pos_top", 100)
	If ($iTempLeft > @DesktopWidth) Or ($iTempTop > @DesktopHeight) Then
		$iTempLeft = Int(@DesktopWidth / 2)
		$iTempTop = Int(@DesktopHeight / 2)
	EndIf
	WinMove("Pos", "", $iTempLeft, $iTempTop)
	$iTempLeft = IniRead("hupai.ini", "Display", "PriceLog_left", 100)
	$iTempTop = IniRead("hupai.ini", "Display", "PriceLog_top", 100)
	$iTempWidth = IniRead("hupai.ini", "Display", "PriceLog_width", 100)
	$iTempHeight = IniRead("hupai.ini", "Display", "PriceLog_height", 100)
	If ($iTempLeft > @DesktopWidth) Or ($iTempTop > @DesktopHeight) Then
		$iTempLeft = Int(@DesktopWidth / 2)
		$iTempTop = 10
	EndIf
	If ($iTempWidth > @DesktopWidth) Or ($iTempHeight > @DesktopHeight) Then
		$iTempWidth = 100
		$iTempHeight = @DesktopHeight - 50
	EndIf
	WinMove("PriceLog", "", $iTempLeft, $iTempTop, $iTempWidth, $iTempHeight)
	For $iCol = 0 To 6
		_GUICtrlListView_SetColumnWidth($ListViewData, $iCol, Number(IniRead("hupai.ini", "Display", "LogColumnWidth_" & $iCol, 25)))
	Next
EndFunc   ;==> GuiCustom

Func TogglePause() ;pause main loop
    $g_bPaused = Not $g_bPaused
	if $g_bPaused Then
		_GUICtrlStatusBar_SetText($StatusBar_Info, "Paused!", 3)
	Else
		_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & $status, 3)
	EndIf
EndFunc   ;==>TogglePause

Func RestartMainLoop() ;reset parameters and restart main loop
    GuiInit()
	VarInit()
EndFunc   ;==>RestartMainLoop

Func Bid2nd() ;bid 2nd
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaibidx.au3' & " " & $p3x & " " & $p3y & " " & $p4x & " " & $p4y & " " & $p5x & " " & $p5y & " " & $drift2)
	If $g_bBeep = 1 Then
		_WinAPI_MessageBeep(0)
	EndIf
EndFunc   ;==>Bid2nd

Func Bid3rd() ;bid 3rd
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaibidx.au3' & " " & $p3x & " " & $p3y & " " & $p4x & " " & $p4y & " " & $p5x & " " & $p5y & " " & $drift3a)
	If $g_bBeep = 1 Then
		_WinAPI_MessageBeep(0)
	EndIf
EndFunc   ;==>Bid3rd

Func BidBlock() ;rebid when check block
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaibidx.au3' & " " & $p3x & " " & $p3y & " " & $p4x & " " & $p4y & " " & $p5x & " " & $p5y & " " & $drift3b)
	If $g_bBeep = 1 Then
		_WinAPI_MessageBeep(0)
	EndIf
EndFunc   ;==> BidBlock

Func BidCheckout() ;rebid when check fail
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaibidx.au3' & " " & $p3x & " " & $p3y & " " & $p4x & " " & $p4y & " " & $p5x & " " & $p5y & " " & $drift3c)
	If $g_bBeep = 1 Then
		_WinAPI_MessageBeep(0)
	EndIf
EndFunc   ;==>BidCheckout

Func ReflashChptcha() ;reflash chptcha when it is not shown in the apply form
	If $g_bMagnify = 1 Then
		_ScreenCapture_CaptureWnd(@ScriptDir & "\ChptchaSnap\" & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & "=" & @MIN & "=" & @SEC & ".bmp", WinGetHandle("hupaiMag"))
	EndIf
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaireflash.au3' & " " & $p6x & " " & $p6y & " " & $p7x & " " & $p7y)
	_WinAPI_MessageBeep(0)
EndFunc   ;==>ReflashChptcha

Func ApplyBid() ;apply price manually in the apply form
	If $g_bMagnify = 1 Then
		_ScreenCapture_CaptureWnd(@ScriptDir & "\ChptchaSnap\" & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & "=" & @MIN & "=" & @SEC & ".bmp", WinGetHandle("hupaiMag"))
	EndIf
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaiapply.au3' & " " & $p8x & " " & $p8y)
	$aData[$second_last + 1][6] = "Num+"
	If $g_bPriceLog Then
		_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
	EndIf
	If $g_bBeep = 1 Then
		_WinAPI_MessageBeep(0)
	EndIf
EndFunc   ;==>ApplyBid

Func CancelBid() ;cancel bid and close the bid apply form
	Run(@AutoItExe & ' /AutoIt3ExecuteScript hupaicancel.au3' & " " & $p9x & " " & $p9y & " " & $p10x & " " & $p10y)
	If $g_bBeep = 1 Then
		_WinAPI_MessageBeep(0)
	EndIf
EndFunc   ;==>CancelBid

Func ApplyParameter() ;apply parameters in setting window to variable which used in main loop
	$bid2time = GUICtrlRead($InputB2T)
	$bid3time = GUICtrlRead($InputB3T)
	$check3time = GUICtrlRead($InputC3T)
	$apply3time = GUICtrlRead($InputA3T)
	$msec = GUICtrlRead($InputMsec)
	$bcl = GUICtrlRead($InputBCL)
	$ucl = GUICtrlRead($InputUCL)
	$lcl = GUICtrlRead($InputLCL)
	$acl = GUICtrlRead($InputACL)
	$drift2 = GUICtrlRead($InputD2P)
	$drift3a = GUICtrlRead($InputD3P)
	$drift3b = GUICtrlRead($InputDBP)
	$drift3c = GUICtrlRead($InputDCP)
	$p1x = GUICtrlRead($Inputp1x)
	$p1y = GUICtrlRead($Inputp1y)
	$p2x = GUICtrlRead($Inputp2x)
	$p2y = GUICtrlRead($Inputp2y)
	$p3x = GUICtrlRead($Inputp3x)
	$p3y = GUICtrlRead($Inputp3y)
	$p4x = GUICtrlRead($Inputp4x)
	$p4y = GUICtrlRead($Inputp4y)
	$p5x = GUICtrlRead($Inputp5x)
	$p5y = GUICtrlRead($Inputp5y)
	$p6x = GUICtrlRead($Inputp6x)
	$p6y = GUICtrlRead($Inputp6y)
	$p7x = GUICtrlRead($Inputp7x)
	$p7y = GUICtrlRead($Inputp7y)
	$p8x = GUICtrlRead($Inputp8x)
	$p8y = GUICtrlRead($Inputp8y)
	$p9x = GUICtrlRead($Inputp9x)
	$p9y = GUICtrlRead($Inputp9y)
	$p10x = GUICtrlRead($Inputp10x)
	$p10y = GUICtrlRead($Inputp10y)
EndFunc   ;==>ApplyParameter

Func SaveParameter() ;save parameters in setting window to variable and ini file
	ApplyParameter()
	SaveIniFile()
EndFunc   ;==>SaveParameter

Func SaveIniFile()
	IniWrite("hupai.ini", "Display", "Point1x", $p1x)
	IniWrite("hupai.ini", "Display", "Point1y", $p1y)
	IniWrite("hupai.ini", "Display", "Point2x", $p2x)
	IniWrite("hupai.ini", "Display", "Point2y", $p2y)
	IniWrite("hupai.ini", "Display", "Point3x", $p3x)
	IniWrite("hupai.ini", "Display", "Point3y", $p3y)
	IniWrite("hupai.ini", "Display", "Point4x", $p4x)
	IniWrite("hupai.ini", "Display", "Point4y", $p4y)
	IniWrite("hupai.ini", "Display", "Point5x", $p5x)
	IniWrite("hupai.ini", "Display", "Point5y", $p5y)
	IniWrite("hupai.ini", "Display", "Point6x", $p6x)
	IniWrite("hupai.ini", "Display", "Point6y", $p6y)
	IniWrite("hupai.ini", "Display", "Point7x", $p7x)
	IniWrite("hupai.ini", "Display", "Point7y", $p7y)
	IniWrite("hupai.ini", "Display", "Point8x", $p8x)
	IniWrite("hupai.ini", "Display", "Point8y", $p8y)
	IniWrite("hupai.ini", "Display", "Point9x", $p9x)
	IniWrite("hupai.ini", "Display", "Point9y", $p9y)
	IniWrite("hupai.ini", "Display", "Point10x", $p10x)
	IniWrite("hupai.ini", "Display", "Point10y", $p10y)
	IniWrite("hupai.ini", "Second", "Bid2", $bid2time)
	IniWrite("hupai.ini", "Second", "Bid3", $bid3time)
	IniWrite("hupai.ini", "Second", "Check3", $check3time)
	IniWrite("hupai.ini", "Second", "Apply3", $apply3time)
	IniWrite("hupai.ini", "Second", "MSec", $msec)
	IniWrite("hupai.ini", "Check", "BCL", $bcl)
	IniWrite("hupai.ini", "Check", "UCL", $ucl)
	IniWrite("hupai.ini", "Check", "LCL", $lcl)
	IniWrite("hupai.ini", "Drift", "Drift2", $drift2)
	IniWrite("hupai.ini", "Drift", "Drift3", $drift3a)
	IniWrite("hupai.ini", "Drift", "Drift3U", $drift3b)
	IniWrite("hupai.ini", "Drift", "Drift3L", $drift3c)
	IniWrite("hupai.ini", "Tools", "Info", $g_bInfo)
	IniWrite("hupai.ini", "Tools", "PriceLog", $g_bPriceLog)
	IniWrite("hupai.ini", "Tools", "Magnify", $g_bMagnify)
	IniWrite("hupai.ini", "Tools", "Latency", $g_bLatency)
	IniWrite("hupai.ini", "Tools", "Beep", $g_bBeep)
	IniWrite("hupai.ini", "Display", "Setting_left", WinGetPos("Setting")[0])
	IniWrite("hupai.ini", "Display", "Setting_top", WinGetPos("Setting")[1])
	IniWrite("hupai.ini", "Display", "Info_left", WinGetPos("Info")[0])
	IniWrite("hupai.ini", "Display", "Info_top", WinGetPos("Info")[1])
	IniWrite("hupai.ini", "Display", "Pos_left", WinGetPos("Pos")[0])
	IniWrite("hupai.ini", "Display", "Pos_top", WinGetPos("Pos")[1])
	IniWrite("hupai.ini", "Display", "PriceLog_left", WinGetPos("PriceLog")[0])
	IniWrite("hupai.ini", "Display", "PriceLog_top", WinGetPos("PriceLog")[1])
	IniWrite("hupai.ini", "Display", "PriceLog_width", WinGetPos("PriceLog")[2])
	IniWrite("hupai.ini", "Display", "PriceLog_height", WinGetPos("PriceLog")[3])
	For $iCol = 0 To 6
		IniWrite("hupai.ini", "Display", "LogColumnWidth_" & $iCol, _GUICtrlListView_GetColumnWidth($ListViewData, $iCol))
	Next
	If $g_bMagnify = 1 Then
		IniWrite("hupai.ini", "Tools", "Magnify_left", $Magnify_left)
		IniWrite("hupai.ini", "Tools", "Magnify_top", $Magnify_top)
		IniWrite("hupai.ini", "Tools", "MagFactor", $g_dMagFactor)
		IniWrite("hupai.ini", "Tools", "Magnify_left", $Magnify_left)
		IniWrite("hupai.ini", "Tools", "Magnify_top", $Magnify_top)
		IniWrite("hupai.ini", "Tools", "Source_left", $MagSource_left)
		IniWrite("hupai.ini", "Tools", "Source_top", $MagSource_top)
		IniWrite("hupai.ini", "Tools", "Source_width", $MagSource_width)
		IniWrite("hupai.ini", "Tools", "Source_height", $MagSource_height)
	EndIf
EndFunc   ;==>SaveIniFile

Func SubLoop_Pause() ;pause main loop, will start a new loop in main loop
	HandleGuiMsg()
EndFunc   ;==>SubLoop_Pause

Func TogglePosCal() ;setup positions used in main loop, will start a new loop in main loop
	$g_bPosCal = Not $g_bPosCal
	if $g_bPosCal then
		$current_point = 1
		GUISetState(@SW_SHOW, $Form_Pos)
		GUICtrlSetState($TabSheet_Pic1, $GUI_SHOW)
		GUICtrlSetData($ButtonPosCal, "完成")
		SetButtonState($GUI_DISABLE)
		PositionHighlight(1,1,0,0,0,0,0,0,0,0)
	Else
		ToolTip("")
		GUISetState(@SW_HIDE, $Form_Pos)
		GUICtrlSetData($ButtonPosCal, "校准")
		SetButtonState($GUI_ENABLE)
		PositionHighlight(0,0,0,0,0,0,0,0,0,0)
	EndIf
EndFunc   ;==>TogglePosCal

Func SetButtonState($StateCode)
	GUICtrlSetState($ButtonStart, $StateCode)
	GUICtrlSetState($ButtonBreak, $StateCode)
	GUICtrlSetState($ButtonApply, $StateCode)
	GUICtrlSetState($ButtonSave, $StateCode)
	GUICtrlSetState($ButtonCancel, $StateCode)
EndFunc   ;==>SetButtonState

Func SubLoop_PosCal() ;position calibration loop
	;pos window infomation
	_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & MouseGetPos(0), 2)
	_GUICtrlStatusBar_SetText($StatusBar_Pos, @TAB & MouseGetPos(1), 4)
	;detect midclick
	Switch $current_point
		Case 0
			ToolTip("完成！")
		Case 1
			ToolTip("使用鼠标中键按位置1 -> 位置2的顺序拖拽矩形框。首先请在位置1按下鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp1x, MouseGetPos(0))
				GUICtrlSetData($Inputp1y, MouseGetPos(1))
				$current_point = 2
				;draw rectangle prepare gui and p1
				Global $aMouse_Pos, $hMask, $hMaster_Mask
				Global $UserDLL = DllOpen("user32.dll")
				Global $hRectangle_GUI = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)
				GUISetBkColor(0xFF0000)
				$aMouse_Pos = MouseGetPos()
				Global $iX1 = $aMouse_Pos[0]
				Global $iY1 = $aMouse_Pos[1]
			EndIf
		Case 2
			ToolTip("请在位置2放开鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				;draw rectangle from p1 to mouse position
				$aMouse_Pos = MouseGetPos()
				$hMaster_Mask = _WinAPI_CreateRectRgn(0, 0, 0, 0)
				$hMask = _WinAPI_CreateRectRgn($iX1,  $aMouse_Pos[1], $aMouse_Pos[0],  $aMouse_Pos[1] + 1) ; Bottom of rectangle
				_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
				_WinAPI_DeleteObject($hMask)
				$hMask = _WinAPI_CreateRectRgn($iX1, $iY1, $iX1 + 1, $aMouse_Pos[1]) ; Left of rectangle
				_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
				_WinAPI_DeleteObject($hMask)
				$hMask = _WinAPI_CreateRectRgn($iX1 + 1, $iY1 + 1, $aMouse_Pos[0], $iY1) ; Top of rectangle
				_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
				_WinAPI_DeleteObject($hMask)
				$hMask = _WinAPI_CreateRectRgn($aMouse_Pos[0], $iY1, $aMouse_Pos[0] + 1,  $aMouse_Pos[1]) ; Right of rectangle
				_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
				_WinAPI_DeleteObject($hMask)
				; Set overall region
				_WinAPI_SetWindowRgn($hRectangle_GUI, $hMaster_Mask)
				If WinGetState($hRectangle_GUI) < 15 Then GUISetState()
			Else
				GUICtrlSetData($Inputp2x, MouseGetPos(0))
				GUICtrlSetData($Inputp2y, MouseGetPos(1))
				$current_point = 3
				PositionHighlight(0,0,1,0,0,0,0,0,0,0)
				;release rectangle
				GUIDelete($hRectangle_GUI)
				DllClose($UserDLL)
			EndIf
		Case 3
			ToolTip("请在位置3点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp3x, MouseGetPos(0))
				GUICtrlSetData($Inputp3y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 4
				PositionHighlight(0,0,0,1,0,0,0,0,0,0)
			EndIf
		Case 4
			ToolTip("请在位置4点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp4x, MouseGetPos(0))
				GUICtrlSetData($Inputp4y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 5
				PositionHighlight(0,0,0,0,1,0,0,0,0,0)
			EndIf
		Case 5
			ToolTip("请在位置5点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp5x, MouseGetPos(0))
				GUICtrlSetData($Inputp5y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 6
				PositionHighlight(0,0,0,0,0,1,0,0,0,0)
				GUICtrlSetState($TabSheet_Pic2, $GUI_SHOW)
			EndIf
		Case 6
			ToolTip("请随意加价后进入验证码窗口，然后在位置6点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp6x, MouseGetPos(0))
				GUICtrlSetData($Inputp6y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 7
				PositionHighlight(0,0,0,0,0,0,1,0,0,0)
			EndIf
		Case 7
			ToolTip("请在位置7点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp7x, MouseGetPos(0))
				GUICtrlSetData($Inputp7y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 8
				PositionHighlight(0,0,0,0,0,0,0,1,0,0)
			EndIf
		Case 8
			ToolTip("请在位置8点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp8x, MouseGetPos(0))
				GUICtrlSetData($Inputp8y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 9
				PositionHighlight(0,0,0,0,0,0,0,0,1,0)
			EndIf
		Case 9
			ToolTip("请在位置9点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp9x, MouseGetPos(0))
				GUICtrlSetData($Inputp9y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 10
				PositionHighlight(0,0,0,0,0,0,0,0,0,1)
				GUICtrlSetState($TabSheet_Pic3, $GUI_SHOW)
			EndIf
		Case 10
			ToolTip("请点击确定按钮，然后在位置10点击鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
			If _IsPressed("04") Then
				GUICtrlSetData($Inputp10x, MouseGetPos(0))
				GUICtrlSetData($Inputp10y, MouseGetPos(1))
				Do
					Sleep(10)
				Until Not _IsPressed("04")
				$current_point = 0
				PositionHighlight(0,0,0,0,0,0,0,0,0,0)
			EndIf
	EndSwitch
	;direct to certain position by clicking the label or tab
	Switch GUIGetMsg()
		Case $ButtonPosCal
			TogglePosCal()
		Case $LabelP1
			$current_point = 1
			GUICtrlSetState($TabSheet_Pic1, $GUI_SHOW)
			PositionHighlight(1,1,0,0,0,0,0,0,0,0)
		Case $LabelP2
			$current_point = 2
			GUICtrlSetState($TabSheet_Pic1, $GUI_SHOW)
			PositionHighlight(1,1,0,0,0,0,0,0,0,0)
		Case $LabelP3
			$current_point = 3
			GUICtrlSetState($TabSheet_Pic1, $GUI_SHOW)
			PositionHighlight(0,0,1,0,0,0,0,0,0,0)
		Case $LabelP4
			$current_point = 4
			GUICtrlSetState($TabSheet_Pic1, $GUI_SHOW)
			PositionHighlight(0,0,0,1,0,0,0,0,0,0)
		Case $LabelP5
			$current_point = 5
			GUICtrlSetState($TabSheet_Pic1, $GUI_SHOW)
			PositionHighlight(0,0,0,0,1,0,0,0,0,0)
		Case $LabelP6
			$current_point = 6
			GUICtrlSetState($TabSheet_Pic2, $GUI_SHOW)
			PositionHighlight(0,0,0,0,0,1,0,0,0,0)
		Case $LabelP7
			$current_point = 7
			GUICtrlSetState($TabSheet_Pic2, $GUI_SHOW)
			PositionHighlight(0,0,0,0,0,0,1,0,0,0)
		Case $LabelP8
			$current_point = 8
			GUICtrlSetState($TabSheet_Pic2, $GUI_SHOW)
			PositionHighlight(0,0,0,0,0,0,0,1,0,0)
		Case $LabelP9
			$current_point = 9
			GUICtrlSetState($TabSheet_Pic2, $GUI_SHOW)
			PositionHighlight(0,0,0,0,0,0,0,0,1,0)
		Case $LabelP10
			$current_point = 10
			PositionHighlight(0,0,0,0,0,0,0,0,0,1)
		Case $TabPos
			Switch GUICtrlRead($TabPos)
				Case 0
					$current_point = 1
					PositionHighlight(1,1,0,0,0,0,0,0,0,0)
				Case 1
					$current_point = 6
					PositionHighlight(0,0,0,0,0,1,0,0,0,0)
				Case 2
					$current_point = 10
					PositionHighlight(0,0,0,0,0,0,0,0,0,1)
			EndSwitch
	EndSwitch
EndFunc   ;==>SubLoop_PosCal

Func PositionHighlight($hp1, $hp2, $hp3, $hp4, $hp5, $hp6, $hp7, $hp8, $hp9, $hp10) ;highlight current point label
	If $hp1 Then
		GUICtrlSetBkColor($LabelP1, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP1, 0xFFFFFF)
	EndIf
	If $hp2 Then
		GUICtrlSetBkColor($LabelP2, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP2, 0xFFFFFF)
	EndIf
	If $hp3 Then
		GUICtrlSetBkColor($LabelP3, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP3, 0xFFFFFF)
	EndIf
	If $hp4 Then
		GUICtrlSetBkColor($LabelP4, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP4, 0xFFFFFF)
	EndIf
	If $hp5 Then
		GUICtrlSetBkColor($LabelP5, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP5, 0xFFFFFF)
	EndIf
	If $hp6 Then
		GUICtrlSetBkColor($LabelP6, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP6, 0xFFFFFF)
	EndIf
	If $hp7 Then
		GUICtrlSetBkColor($LabelP7, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP7, 0xFFFFFF)
	EndIf
	If $hp8 Then
		GUICtrlSetBkColor($LabelP8, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP8, 0xFFFFFF)
	EndIf
	If $hp9 Then
		GUICtrlSetBkColor($LabelP9, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP9, 0xFFFFFF)
	EndIf
	If $hp10 Then
		GUICtrlSetBkColor($LabelP10, 0x3399FF)
	Else
		GUICtrlSetBkColor($LabelP10, 0xFFFFFF)
	EndIf
EndFunc   ;==>PositionHighlight

Func HandleGuiMsg()
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			If $g_bMagnify = 1 Then
				ProcessClose($p_idMagnify)
			EndIf
			Exit
		Case $ButtonStart
			RestartMainLoop()
		Case $ButtonBreak
			TogglePause()
		Case $ButtonApply
			ApplyParameter()
		Case $ButtonSave
			SaveParameter()
		Case $ButtonCancel
			RestoreParameter()
		Case $ButtonPosCal
			TogglePosCal()
		Case $CheckboxPricelog
			Switch GUICtrlRead($CheckboxPricelog)
				Case $GUI_CHECKED
					GUISetState(@SW_SHOW, $Form_Data)
					$g_bPriceLog = 1
					GUICtrlSetState($ButtonCopyLog, $GUI_ENABLE)
					GUICtrlSetState($ButtonSetLogWidth, $GUI_ENABLE)
				Case $GUI_UNCHECKED
					GUISetState(@SW_HIDE, $Form_Data)
					$g_bPriceLog = 0
					GUICtrlSetState($ButtonCopyLog, $GUI_DISABLE)
					GUICtrlSetState($ButtonSetLogWidth, $GUI_DISABLE)
			EndSwitch
		Case $ButtonCopyLog
			_ArrayToClip($aData, @TAB)
			ClipPut(ClipGet() & @CRLF _
				& "二次出价时间=" & $bid2time & @CRLF _
				& "三次出价时间=" & $bid3time & @CRLF _
				& "出价检查时间=" & $check3time & @CRLF _
				& "出价确认时间=" & $apply3time & @CRLF _
				& "出价确认延迟=" & $msec & @CRLF _
				& "跳价阻塞限=" & $bcl & @CRLF _
				& "跳价检查上限=" & $ucl & @CRLF _
				& "跳价检查下限=" & $lcl & @CRLF _
				& "出价确认差额=" & $acl & @CRLF _
				& "二次出价加价=" & $drift2 & @CRLF _
				& "三次出价加价=" & $drift3a & @CRLF _
				& "跳价阻塞加价=" & $drift3b & @CRLF _
				& "跳价超限加价=" & $drift3c & @CRLF)
		Case $ButtonSetLogWidth
			For $iCol = 0 To 6
				_GUICtrlListView_SetColumnWidth($ListViewData, $iCol, $LVSCW_AUTOSIZE)
			Next
		Case $ButtonSetMag
			SetButtonState($GUI_DISABLE)
			SetMagSource()
			SetButtonState($GUI_ENABLE)
			ProcessClose($p_idMagnify)
			$p_idMagnify = ""
			InitializeMagn()
		Case $SliderMagFactor
			$g_dMagFactor = GUICtrlRead($SliderMagFactor) * 0.25
			;restart mag with new factor
			$Magnify_left = WinGetPos("hupaiMag")[0]
			$Magnify_top = WinGetPos("hupaiMag")[1]
			ProcessClose($p_idMagnify)
			$p_idMagnify = ""
			InitializeMagn()
		Case $ButtonLibBuilder
			If Not $g_bLibBuilding Then
				$g_bLibBuilding = True
				SetButtonState($GUI_DISABLE)
				GUICtrlSetData($ButtonLibBuilder, "处理中")
				GUICtrlSetState($ButtonLibBuilder, $GUI_DISABLE)
				;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & 'BuildLib()' & @CRLF & @CRLF & 'Return:' & @CRLF & "lag here!") ;### Debug MSGBOX
				BuildLib()
				SetButtonState($GUI_ENABLE)
				GUICtrlSetData($ButtonLibBuilder, "开始")
				GUICtrlSetState($ButtonLibBuilder, $GUI_ENABLE)
			EndIf
			$g_bLibBuilding = False
		Case $CheckboxMagn
			Switch GUICtrlRead($CheckboxMagn)
				Case $GUI_CHECKED
					$g_bMagnify = 1
					GUICtrlSetState($ButtonSetMag, $GUI_ENABLE)
					GUICtrlSetState($SliderMagFactor, $GUI_ENABLE)
					InitializeMagn()
				Case $GUI_UNCHECKED
					$g_bMagnify = 0
					$Magnify_left = WinGetPos("hupaiMag")[0]
					$Magnify_top = WinGetPos("hupaiMag")[1]
					GUICtrlSetState($ButtonSetMag, $GUI_DISABLE)
					GUICtrlSetState($SliderMagFactor, $GUI_DISABLE)
					ProcessClose($p_idMagnify)
					$p_idMagnify = ""
			EndSwitch
		Case $CheckboxInfo
			Switch GUICtrlRead($CheckboxInfo)
				Case $GUI_CHECKED
					GUISetState(@SW_SHOW, $Form_Info)
					$g_bInfo = 1
				Case $GUI_UNCHECKED
					GUISetState(@SW_HIDE, $Form_Info)
					$g_bInfo = 0
			EndSwitch
		Case $CheckboxLatency
			MsgBox(0,"Warning","Under Construction!");待开发
		Case $CheckboxBeep
			Switch GUICtrlRead($CheckboxBeep)
				Case $GUI_CHECKED
					$g_bBeep = 1
					_WinAPI_MessageBeep(0)
				Case $GUI_UNCHECKED
					$g_bBeep = 0
					_WinAPI_MessageBeep(0)
			EndSwitch
	EndSwitch
EndFunc   ;==>HandleGuiMsg

Func SetMagSource()
	;draw rectangle prepare gui and p1
	Global $aMouse_Pos, $hMask, $hMaster_Mask
	Global $UserDLL = DllOpen("user32.dll")
	Global $hRectangle_GUI = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)
	GUISetBkColor(0xFF0000)
	Do
		ToolTip("使用鼠标中键按左上 -> 右下的顺序设定放大区域。首先请移动鼠标到左上角并按下鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
		Sleep(25)
	Until _IsPressed("04")
	$aMouse_Pos = MouseGetPos()
	$iX1 = $aMouse_Pos[0]
	$iY1 = $aMouse_Pos[1]
	Do
		ToolTip("然后请移动鼠标到右下角再放开鼠标中键。", MouseGetPos(0), MouseGetPos(1) - 40," ",0,0)
		;draw rectangle from p1 to mouse position
		$aMouse_Pos = MouseGetPos()
		$hMaster_Mask = _WinAPI_CreateRectRgn(0, 0, 0, 0)
		$hMask = _WinAPI_CreateRectRgn($iX1,  $aMouse_Pos[1], $aMouse_Pos[0],  $aMouse_Pos[1] + 1) ; Bottom of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		$hMask = _WinAPI_CreateRectRgn($iX1, $iY1, $iX1 + 1, $aMouse_Pos[1]) ; Left of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		$hMask = _WinAPI_CreateRectRgn($iX1 + 1, $iY1 + 1, $aMouse_Pos[0], $iY1) ; Top of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		$hMask = _WinAPI_CreateRectRgn($aMouse_Pos[0], $iY1, $aMouse_Pos[0] + 1,  $aMouse_Pos[1]) ; Right of rectangle
		_WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
		_WinAPI_DeleteObject($hMask)
		; Set overall region
		_WinAPI_SetWindowRgn($hRectangle_GUI, $hMaster_Mask)
		If WinGetState($hRectangle_GUI) < 15 Then GUISetState()
		Sleep(25)
	Until Not _IsPressed("04")
	;release rectangle and tooltip
	GUIDelete($hRectangle_GUI)
	DllClose($UserDLL)
	ToolTip("")
	;check and setup source
	$aMouse_Pos = MouseGetPos()
	If ($aMouse_Pos[0] > $iX1) And ($aMouse_Pos[1] > $iY1) Then
		$MagSource_left = $iX1
		$MagSource_top = $iY1
		$MagSource_width = $aMouse_Pos[0] - $iX1
		$MagSource_height = $aMouse_Pos[1] - $iY1
	Else
		MsgBox(16,"错误！","设定的区域似乎有问题，请按照提示重新设定！！")
	EndIf
	;restart mag with new source
	$Magnify_left = WinGetPos("hupaiMag")[0]
	$Magnify_top = WinGetPos("hupaiMag")[1]
EndFunc   ;==>SetMagSource

Func BuildLib() ;run chlibbuild.exe to check if all numbers and necessary symbols are included
	ToolTip("准备文档中，请等待...",@DesktopWidth / 2,@DesktopWidth / 2, "", $TIP_WARNINGICON, $TIP_CENTER)
	While WinKill("字库建造工具")
		Sleep(1000)
		;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & 'WinKill("字库建造工具")' & @CRLF & @CRLF & 'Return:' & @CRLF & "kill found!") ;### Debug MSGBOX
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
				LibChrCheck(_GUICtrlListBox_GetText($hLB, $n))
			Else
				LibChrCheck($sChr)
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

Func LibChrCheck($chr)
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
EndFunc   ;==>LibChrCheck

Func VarInit()
	$time = "??:??:??"
	$price = "?????"
	$status = 1
	$second_last = -1
	$price_last = 0
	$fps = 0
	$tt = @SEC
	$g_bPaused = False
	$g_bPosCal = False
	$g_bLibBuilding = False
EndFunc   ;==>VarInit

GuiInit() ;Gui Initialize
GuiCustom() ;restore window position
VarInit() ;Var Initalize
;status标识出价阶段
;第一次出价后：1（初始）
;第二次出价后：2
;第三次出价后：3
;出价检查失败后：4
;出价检查成功后：5
;自动确认出价后：6
;价格阻塞出价后：7

While 1 ;mainloop
	;handle message
	HandleGuiMsg()
	;pause loop
	While $g_bPaused
		SubLoop_Pause()
		Sleep(10)
	WEnd
	;position calibration loop
	While $g_bPosCal
		SubLoop_PosCal()
		Sleep(10)
	WEnd
	;get time & price
	$oString = $oShell.OCR($p1x, $p1y, $p2x, $p2y)
	if StringInStr($oString, "_", 0, 2) and StringInStr($oString, ":", 0, 4) Then
		$elements = StringSplit ($oString, "_")
		$time = $elements[1]
		$price = $elements[2]
		$beforetime = StringRight($elements[3], 8)
	EndIf
	;difference
	Switch $status
		Case 1
			$difference = "wait"
		Case 2
			$difference = $bid2price - $price
		Case 3
			$difference = $bid3price - $price
		Case 4
			$difference = $bid4price - $price
		Case 5
			$difference = $bid3price - $price
		Case 6
			$difference = $bid3price - $price
		Case 7
			$difference = $bid4price - $price
	EndSwitch
	;process autobid
	Switch $status
		;bid2nd
		Case 1
			If StringLeft($time, 6) = $g_sLastMinute and StringRight($time, 2) >= $bid2time Then
				Bid2nd()
				$bid2price = $price + $drift2
				$status = 2
				If $g_bInfo Then
					_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 3)
					_GUICtrlStatusBar_SetText($StatusBar_Info, "bid2 " & String($bid2price), 4)
				EndIf
				$aData[$second_last + 1][6] = "bid2 " & $bid2price
				If $g_bPriceLog Then
					_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
				EndIf
			EndIf
		;bid3rd
		Case 2
			If StringRight($time, 2) >= $bid3time Then
				Bid3rd()
				$bid3price = $price + $drift3a
				$status = 3
				If $g_bInfo Then
					_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 3)
					_GUICtrlStatusBar_SetText($StatusBar_Info, "bid3 " & String($bid3price), 5)
				EndIf
				$aData[$second_last + 1][6] = "bid3 " & $bid3price
				If $g_bPriceLog Then
					_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
				EndIf
			EndIf
		;check if bid3price will be ok?
		Case 3
			If StringRight($time, 2) >= $check3time Then
				;rebid when block, need to apply manually
				If $price - $bid3price + $drift3a <= $bcl Then
					CancelBid()
					Sleep(100)
					BidBlock()
					$bid4price = $price + $drift3b
					$status = 7
					If $g_bInfo Then
						_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 3)
						_GUICtrlStatusBar_SetText($StatusBar_Info, "bid4 " & String($bid4price), 6)
					EndIf
					$aData[$second_last + 1][6] = "check block, rebid " & $bid4price
					If $g_bPriceLog Then
						_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
					EndIf
				;rebid when check fail, need to apply manually
				ElseIf $difference > $ucl or $difference <$lcl Then
					CancelBid()
					Sleep(100)
					BidCheckout()
					$bid4price = $price + $drift3c
					$status = 4
					If $g_bInfo Then
						_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 3)
						_GUICtrlStatusBar_SetText($StatusBar_Info, "bid4 " & String($bid4price), 6)
					EndIf
					$aData[$second_last + 1][6] = "check fail, rebid " & $bid4price
					If $g_bPriceLog Then
						_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
					EndIf
				;check ok, will apply automatically
				Else
					$status = 5
					If $g_bInfo Then
						_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 3)
					EndIf
					$aData[$second_last + 1][6] = "check ok"
					If $g_bPriceLog Then
						_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
					EndIf
				EndIf
			EndIf
		;apply bid3price automatically
		Case 5
			If StringRight($time, 2) >= $apply3time Then
				Sleep($msec)
				ApplyBid()
				$status = 6
				If $g_bInfo Then
					_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 2)
				EndIf
				$aData[$second_last + 1][6] = "apply"
				If $g_bPriceLog Then
					_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
				EndIf
			EndIf
			If $difference <= $acl Then
				ApplyBid()
				$status = 6
				If $g_bInfo Then
					_GUICtrlStatusBar_SetText($StatusBar_Info, "status " & String($status), 2)
				EndIf
				$aData[$second_last + 1][6] = "apply"
				If $g_bPriceLog Then
					_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][6], 6)
				EndIf
			EndIf
	EndSwitch
	;gather data
	If $g_bPriceLog Then
		If StringLeft($time, 6) = $g_sLastMinute Then
			$second0 = StringRight($time, 2)
			If StringLeft($beforetime, 6) = $g_sLastMinute Then
				$second2 = StringRight($beforetime, 2)
			Else
				$second2 = 0
			EndIf
			While $second_last < $second0
				$aData[$second_last + 1][0] = $second0
				$aData[$second_last + 1][1] = $price
				$aData[$second_last + 1][2] = $second2
				$aData[$second_last + 1][5] = @HOUR & ":" &@MIN & ":" & @SEC & " " & @MSEC
				_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][0], 1)
				_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][1], 2)
				_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][2], 3)
				_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][5], 5)
				$k = 0
				While _GUICtrlListView_GetItem($ListViewData, $k, 2) < $price - 300
					$k = $k + 1
				WEnd
				$price100 = ($second0 - $second2) / ($second0 - $k)
				$price100 = Int($price100 * 100)
				If $second_last = -1 Then
					$aData[$second_last + 1][4] = "--" & "%"
				Else
					$aData[$second_last + 1][4] = $price100 & "%"
				EndIf
				_GUICtrlListView_AddSubItem($ListViewData, $second_last + 1, $aData[$second_last + 1][4], 4)
				_GUICtrlListView_EnsureVisible($ListViewData, $second_last + 1)
				$second_last = $second_last + 1
			WEnd
		EndIf
	EndIf
	;Information layout
	If $g_bInfo Then
		;reflash time, price, difference when time changes
		If GUICtrlRead($LabelTime) <> $time Then
			GUICtrlSetData($LabelTime, $time)
			GUICtrlSetData($LabelPrice, $price)
			GUICtrlSetData($LabelDiff, $difference)
		EndIf
		;reflash fps,latency... every second
		If $tt = @SEC Then
			$fps = $fps + 1
		Else
			_GUICtrlStatusBar_SetText($StatusBar_Info, @HOUR & ":" & @MIN & ":" & @SEC, 0)
			_GUICtrlStatusBar_SetText($StatusBar_Info, "fps" & $fps, 1)
			_GUICtrlStatusBar_SetText($StatusBar_Info, $lag & "???ms ", 2)
			$fps = 0
			$tt = @SEC
		EndIf
	EndIf
WEnd





