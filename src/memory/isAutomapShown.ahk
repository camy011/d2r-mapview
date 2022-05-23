

isAutomapShown(ByRef d2rprocess, ByRef uiOffset) {

    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    startingAddress := d2rprocess.BaseAddress + uiOffset
    isMapShown := d2rprocess.read(startingAddress, "UShort")
    ;WriteLog(isMapShown " " uiOffset " " startingAddress)
    if (isMapShown == 1) {
        return true
    } else {
        return false ; if it failed to be read return true anyway
    }
}