#Requires AutoHotkey v2.0.19
Persistent

; Định nghĩa hằng số
OCR_NORMAL := 32512  ; ID của con trỏ chuột chuẩn
OCR_APPSTARTING := 32650  ; Chuột khi đang khởi động
OCR_WAIT := 32514         ; Chuột khi đang đợi
OCR_CROSS := 32515        ; Chuột chữ thập
OCR_IBEAM := 32513        ; Chuột I-beam
OCR_HAND := 32649         ; Chuột hình bàn tay
; Thêm các con trỏ khác nếu cần

; Tạo cursor rỗng
emptyANDmask := Buffer(32*4, 0xFF)
emptyXORmask := Buffer(32*4, 0)
hEmptyCursor := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", emptyANDmask, "Ptr", emptyXORmask, "Ptr")

; Biến lưu trạng thái
lastX := 0
lastY := 0
idleTime := 0
hideDelay := 3000  ; 3 giây (3000 ms)
cursorHidden := false
needRestart := false
scriptPath := A_ScriptFullPath
logEnabled := false

; Kiểm tra nếu script đã được khởi động lại
restartParam := false
for n, param in A_Args {
    if (param = "--restart") {
        restartParam := true
        break
    }
}

; Khởi tạo log file nếu debug được bật
logFile := A_ScriptDir "\cursor_log.txt"
if (logEnabled && FileExist(logFile) && !restartParam)
    FileDelete(logFile)

; Hàm ghi log
Log(text) {
    global logEnabled, logFile
    if (logEnabled)
        FileAppend(A_Now . ": " . text . "`n", logFile)
}

Log("Script khởi động. Tham số restart: " . restartParam)

; Ẩn các con trỏ hệ thống
HideAllCursors() {
    global hEmptyCursor, cursorHidden
    
    cursorTypes := [OCR_NORMAL, OCR_APPSTARTING, OCR_WAIT, OCR_CROSS, OCR_IBEAM, OCR_HAND]
    
    for cursorType in cursorTypes {
        DllCall("SetSystemCursor", "Ptr", hEmptyCursor, "UInt", cursorType)
    }
    
    cursorHidden := true
    Log("Đã ẩn tất cả con trỏ")
}

; Khôi phục con trỏ hệ thống
RestoreCursors() {
    global cursorHidden
    DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0) ; SPI_SETCURSORS = 0x0057
    cursorHidden := false
    Log("Đã khôi phục tất cả con trỏ")
}

; Khởi động lại script với quyền quản trị
RestartAsAdmin() {
    global scriptPath, logEnabled
    
    Log("Chuẩn bị khởi động lại script với quyền quản trị")
    
    if (A_IsAdmin) {
        Log("Script đã chạy với quyền quản trị. Khởi động lại bình thường.")
        Run(A_AhkPath " " scriptPath " --restart")
    } else {
        Log("Khởi động lại với quyền quản trị")
        try {
            Run("*RunAs " A_AhkPath " " scriptPath " --restart")
        } catch {
            Log("Lỗi khi khởi động lại với quyền quản trị: " . A_LastError)
        }
    }
    
    ExitApp
}

; Khởi động lại script
RestartScript() {
    global scriptPath, needRestart, logEnabled
    
    if (needRestart) {
        Log("Đang khởi động lại script...")
        RestoreCursors()  ; Đảm bảo khôi phục con trỏ trước khi khởi động lại
        Run(A_AhkPath " " scriptPath " --restart")
        ExitApp
    }
}

; Theo dõi vị trí chuột
WatchMouse() {
    global lastX, lastY, idleTime, hideDelay, cursorHidden, needRestart
    
    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    
    if (x = lastX && y = lastY) {
        idleTime += 100
        if (idleTime >= hideDelay && !cursorHidden) {
            HideAllCursors()
            Log("Đã ẩn chuột sau " . idleTime . "ms không hoạt động")
        }
    } else {
        idleTime := 0
        if (cursorHidden) {
            RestoreCursors()
            Log("Phát hiện chuột di chuyển - đã khôi phục con trỏ")
            
            ; Đánh dấu cần khởi động lại sau 500ms
            needRestart := true
            SetTimer(RestartScript, -500)
        }
        lastX := x
        lastY := y
    }
}

; Phím tắt khẩn cấp để khôi phục chuột
^+C::  ; Ctrl+Shift+C
{
    global cursorHidden
    if (cursorHidden) {
        RestoreCursors()
        MsgBox("Chuột đã được khôi phục")
        Log("Chuột được khôi phục thông qua phím tắt")
    } else {
        MsgBox("Chuột đang hiển thị bình thường")
    }
}

; Phím tắt để bật/tắt logging
^+D::  ; Ctrl+Shift+D
{
    global logEnabled
    logEnabled := !logEnabled
    if (logEnabled)
        MsgBox("Đã bật chế độ ghi log vào " . logFile)
    else
        MsgBox("Đã tắt chế độ ghi log")
}

; Phím tắt để thoát script
^+X::  ; Ctrl+Shift+X
{
    global cursorHidden
    if (cursorHidden)
        RestoreCursors()
    MsgBox("Đang thoát script...")
    ExitApp
}

; Dọn dẹp khi script kết thúc
OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode) {
    global cursorHidden, hEmptyCursor
    
    Log("Script đang kết thúc. Lý do: " . ExitReason)
    
    if (cursorHidden)
        RestoreCursors()
    
    if (hEmptyCursor)
        DllCall("DestroyCursor", "Ptr", hEmptyCursor)
}

; Thiết lập timer theo dõi chuột
SetTimer(WatchMouse, 100)

Log("Script đã được khởi tạo hoàn tất")