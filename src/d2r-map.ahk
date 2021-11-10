#SingleInstance, Force
#Include %A_ScriptDir%\include\getPlayerOffset.ahk
#Include %A_ScriptDir%\include\getMapUrl.ahk
#Include %A_ScriptDir%\include\getLevelNo.ahk
#Include %A_ScriptDir%\include\getDifficulty.ahk
#Include %A_ScriptDir%\include\getPlayerPosition.ahk
#Include %A_ScriptDir%\include\getLevelInfo.ahk
#Include %A_ScriptDir%\include\getMapSeed.ahk
#Include %A_ScriptDir%\include\showAutoMap.ahk
#Include %A_ScriptDir%\include\downloadMapImage.ahk
#Include %A_ScriptDir%\include\logging.ahk

if !FileExist(A_Scriptdir . "\settings.ini") {
	MsgBox, , Missing settings, Could not find settings.ini file
	ExitApp
}
lastMap := ""
exitArray := []
WriteLog("*******************************************************")
WriteLog("* Map overlay started *")
WriteLog("*******************************************************")
IniRead, baseUrl, settings.ini, MapHost, baseUrl
IniRead, width, settings.ini, MapSettings, width
IniRead, topMargin, settings.ini, MapSettings, topMargin
IniRead, leftMargin, settings.ini, MapSettings, leftMargin
IniRead, opacity, settings.ini, MapSettings, opacity
IniRead, startingOffset, settings.ini, Memory, playerOffset
IniRead, debug, settings.ini, Logging, debug

WriteLog("Using configuration:")
WriteLog("    baseUrl: " baseUrl)
WriteLog("    Map: width: " width ", topMargin: " topMargin ", leftMargin: " leftMargin ", opacity: " opacity)
WriteLog("    startingOffset: " startingOffset)
WriteLog("    debug logging: " debug)

playerOffset:=startingOffset
windowShow := true
mapData := []
sFile := ""

SetTimer, UpdateCycle, 1000 ; the 1000 here is priority, not sleep
SetTimer, CheckScreen, 50
return


CheckScreen:
	Gui, 1: Show, NA
return

UpdateCycle:
	; scan for the player offset
	playerOffset := checkLastOffset(playerOffset)
	if (!playerOffset) {
		playerOffset := scanForPlayerOffset(startingOffset)
	}
	if (playerOffset) {
		pSeedAddress := getMapSeedAddress(playerOffset)
		if (pSeedAddress) {
			pDifficultyAddress := getDifficultyAddress(playerOffset)
			pLevelNoAddress := getLevelNoAddress(playerOffset)
			if (pLevelNoAddress) {
				playerPositionArray := getPlayerPosition(playerOffset)
				sMapUrl := getD2RMapUrl(baseUrl, pSeedAddress, pDifficultyAddress, pLevelNoAddress)
				if (InStr(lastMap, sMapUrl)) {
				} else {
					; new map so refresh image and map data
					WriteLog("Fetching new map from " sMapUrl)
					lastMap := sMapUrl
					windowShow := true
					downloadMapImage(sMapUrl, mapData)
				}
				ShowAutoMap(mapData, width, leftMargin, topMargin, opacity, playerPositionArray)
			} else {
				windowShow := false
			}
		} else {
			WriteLog("Found playerOffset" playerOffset ", but not map seed address")
			windowShow := false
			playerOffset := startingOffset ; reset the offset to default
		}
	} else {
		playerOffset := startingOffset ; reset the offset to default
		windowShow := false
		Sleep, 5000  ; sleep longer when no offset found, you're likely in menu
	}
	Sleep, 1000 ; set a pacing of 1 second
return

+F10::
{
	WriteLog("Pressed Shift+F10, exiting...")
	ExitApp
}


