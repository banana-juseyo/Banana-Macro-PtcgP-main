/************************************************************************
 * @description 바나나 무한 불판 매크로
 * @author Banana-juseyo
 * @date 2024/12/29
 * @version 1.00
 * @see {@link https://github.com/banana-juseyo/Banana-Macro-PtcgP Github Repository}
 * @see {@link https://gall.dcinside.com/m/pokemontcgpocket/ DCinside PtcgP Gallery}
 ***********************************************************************/

; 바나나 무한 불판 매크로 by Banana-juseyo
; 권장 스크린 해상도 : 1920 * 1080
; 권장 플레이어 : mumuplayer
; 권장 인스턴스 해상도 : 540 * 960 (220 dpi)

global _appTitle := "Banana Macro"
global _author := "banana-juseyo"
global _currentVersion := "v1.00"
global _website := "https://github.com/banana-juseyo/Banana-Macro-PtcgP"
global _repoName := "Banana-Macro-PtcgP"

#Requires AutoHotkey v2.0
#Include .\app\WebView2.ahk
#include .\app\_JXON.ahk

;; 이미지 변수
global _imageFile_friendRequestListCard := A_ScriptDir . "\asset\match\friendRequestListCard.png"
global _imageFile_friendRequestListEmpty := A_ScriptDir . "\asset\match\friendRequestListEmpty.png"
global _imageFile_friendRequestListClearButton := A_ScriptDir . "\asset\match\friendRequestListClearButton.png"
global _imageFile_userDetailEmblem := A_ScriptDir . "\asset\match\userDetailEmblem.png"
global _imageFile_userDetailMybest := A_ScriptDir . "\asset\match\userDetailMybest.png"
global _imageFile_passportPikachu := A_ScriptDir . "\asset\match\passportPikachu.png"
global _imageFile_userDetailAccept := A_ScriptDir . "\asset\match\userDetailAccept.png"
global _imageFile_userDetailDecline := A_ScriptDir . "\asset\match\userDetailDecline.png"
global _imageFile_userDetailRequestFriend := A_ScriptDir . "\asset\match\userDetailRequestFriend.png"
global _imageFile_userDetailFriendNow := A_ScriptDir . "\asset\match\userDetailFriendNow.png"
global _imageFile_userDetailEmpty := A_ScriptDir . "\asset\match\userDetailEmpty.png"
global _imageFile_userDetailRequestNotFound := A_ScriptDir . "\asset\match\userDetailRequestNotFound.png"
global _imageFile_friendMenuButton := A_ScriptDir . "\asset\match\friendsMenuButton.png"
global _imageFile_friendListCard := A_ScriptDir . "\asset\match\friendListCard.png"
global _imageFile_friendListEmpty := A_ScriptDir . "\asset\match\friendListEmpty.png"
global _imageFile_removeFriendConfirm := A_ScriptDir . "\asset\match\removeFriendConfirm.png"
global _imageFile_appIcon := A_ScriptDir . "\asset\image\_app_Icon.png"
global _imageFile_close := A_ScriptDir . "\asset\image\_app_Close.png"
global _imageFile_restart := A_ScriptDir . "\asset\image\_app_Restart.png"

; 글로벌 변수
global _isRunning := FALSE
global _isPausing := FALSE
global _debug := FALSE
global messageQueue := []
global _downloaderGUIHwnd := ""
global _configGUIHwnd := ""
global GuiInstance := {}
global recentText := ""
global RecentTextCtrl := {}
global oldTexts := ""
global _userIni := {}
global FileInfo

; 환경값 초기화 & 기본값
global _delayConfig := 150
global _instanceNameConfig := ""
global _acceptingTermConfig := 8 * 60000
global _deletingTermConfig := 2 * 60000

; 로그 파일 설정
global logFile := A_ScriptDir . "\log\" . A_YYYY . A_MM . A_DD . "_" . A_Hour . A_Min . A_Sec . "_" . "log.txt"

;; 실행 시 업데이트/필수 파일 자동 다운로드 로직
DownloaderInstance := Downloader()
;; msedge.dll 파일 확인
DownloaderInstance.CheckMsedgeDLL()
;; 스크립트 업데이트 확인
; 임시 폴더의 업데이트 스크립트 삭제
updateScriptPath := A_Temp "\updater.ahk"
if FileExist(updateScriptPath)
    FileDelete(updateScriptPath)
; 스크립트 업데이트 실행
DownloaderInstance.CheckForUpdates()

class Downloader {
    gui := ""
    ProgressBar := {}
    TextCtrl := {}
    Http := {}
    _progress := 0

    __New() {
        if (_downloaderGUIHwnd && WinExist(_downloaderGUIHwnd)) {
            WinActivate(_downloaderGUIHwnd)
            this.gui := GuiFromHwnd(_downloaderGUIHwnd)
        }
    }

    ; 다운로더 GUI 호출
    OpenDownloaderGUI() {
        global _downloaderGUIHwnd
        global ProgressBar, TextCtrl

        _gui := GUI()
        _downloaderGUIHwnd := _gui.hwnd
        _gui.Opt("-SysMenu -Caption")
        _gui.Title := "자동 업데이트"

        TextCtrl := _gui.Add("Text", "x10 y10 w300", "파일 상태 확인 중...")
        ProgressBar := _gui.Add("Progress", "x10 y40 w300 h20")

        _gui.Show()
        this.gui := _gui
        return _gui
    }

    Dismiss() {
        if (WinActive(_downloaderGUIHwnd)) {
            This.gui.Destroy()
            return
        }
    }

    ; 파일 업데이트 체크
    CheckMsedgeDLL() {
        ; 경로 표현 시 \ (백슬래시) 대신 / (슬래시) 사용
        _msedgeProjectPath := "/app/msedge.dll"
        _fullpath := A_ScriptDir . _msedgeProjectPath

        if (FileExist(_fullpath) && FileGetSize(_fullpath) >= 283108904) {
            SendDebugMsg("업데이트할 파일이 없습니다.")
        } else {
            FileInfo := DownloaderInstance.GetRepoApi(_msedgeProjectPath)
            if (FileInfo["isAvailable"]) {
                d := DownloaderInstance.Download(FileInfo, _fullpath)
            } else {
                MsgBox("138::파일 업데이트에 실패했습니다.")
            }
            if (d) {
                if (WinActive(DownloaderInstance.gui.hwnd)) {
                    DownloaderInstance.gui.Destroy()
                }
            }
            else {
                MsgBox("146::파일 다운로드에 실패했습니다.")
            }
        }
    }

    ; 파일 다운로드 실행
    Download(FileInfo, _fullPath) {
        global TextCtrl
        global _progress

        url := FileInfo["downloadUrl"]
        fileName := FileInfo["fileName"]
        destination := FileInfo["destination"]
        size := FileInfo["size"]

        ; 다운로더 GUI 열기
        DownloaderInstance.OpenDownloaderGUI()

        ; 파일 확인
        if FileExist(_fullPath) {
            FileDelete(_fullPath)
        }
        try {
            TextCtrl.Text := "다운로드 중 : " fileName
            SetTimer(() => This.UpdateDownloadProgress(_fullPath, size), 100)
            Download(url, _fullPath)

            if (FileGetSize(_fullPath) >= size) {
                global TextCtrl
                TextCtrl.Text := ("다운로드 완료")
                Sleep(1000)
                return TRUE
            }
            return TRUE
        }
        catch Error as e {
            MsgBox "[Download]`n다운로드 중 오류가 발생했습니다.`n" e.Message
            Reload
        }
    }

    ; 다운로드 진행에 따라 progress 업데이트
    UpdateDownloadProgress(_fullPath, _fullSize) {
        global ProgressBar, _progress
        try {
            _currentSize := FileGetSize(_fullPath)
            _progress := Floor((_currentSize / _fullSize) * 100) ; 진행률 계산

            ProgressBar.Value := _progress

            if (_currentSize >= _fullSize) {
                _progress := 100
                SetTimer , 0
                return
            }
        }
        catch Error as e {
            MsgBox ("[UpdateDownloadProgress]`n파일 다운로드 중 오류가 발생했습니다.`n" e.Message)
            Reload
        }
    }

    ; Repo Api에서 파일 조회 -> obj
    GetRepoApi(ProjectFilePath) {
        i := InStr(ProjectFilePath, "/", , -1)
        Path := SubStr(ProjectFilePath, 1, i - 1)
        FileName := SubStr(ProjectFilePath, i + 1)
        if (ProjectFilePath == "/app/msedge.dll") {
            url := "https://api.github.com/repos/banana-juseyo/Banana-Macro-PtcgP/contents/app/msedge.dll"
            try {
                http := ComObject("WinHttp.WinHttpRequest.5.1")
                http.Open("GET", url, TRUE)
                http.Send()
                http.WaitForResponse()
                response := http.ResponseText
                ; responsStr := Jxon_Dump(response)
                responseMap := Jxon_Load(&response)
                if (responseMap["name"] == "msedge.dll") {
                    return Map(
                        "isAvailable", TRUE,
                        "fileName", responseMap["name"],
                        "destination", A_ScriptDir . Path . "/",
                        "fullPath", A_ScriptDir . Path . "/" . responseMap["name"],
                        "downloadUrl", responseMap["download_url"],
                        "size", responseMap["size"]
                    )
                } else {
                    return Map("isAvailable", FALSE)
                }
            }
            catch Error as e {
                MsgBox "패키지 파일 확인 중 오류가 발생했습니다: " e.Message
                return Map("isAvailable", false)
            }
        } else {
            url := "https://api.github.com/repos/banana-juseyo/" . _repoName . "/contents" . Path
            try {
                http := ComObject("WinHttp.WinHttpRequest.5.1")
                http.Open("GET", url, TRUE)
                http.Send()
                http.WaitForResponse()
                response := http.ResponseText
                ; responsStr := Jxon_Dump(response)
                responseMap := Jxon_Load(&response)
                for key, file in responseMap {
                    if (file["name"] = FileName) {
                        return Map(
                            "isAvailable", TRUE,
                            "fileName", FileName,
                            "destination", A_ScriptDir . Path . "/",
                            "fullPath", A_ScriptDir . Path . "/" . FileName,
                            "downloadUrl", file["download_url"],
                            "size", file["size"]
                        )
                    }
                }
                return Map("isAvailable", FALSE)
            }
            catch Error as e {
                MsgBox "패키지 파일 확인 중 오류가 발생했습니다: " e.Message
                return Map("isAvailable", false)
            }
        }
    }

    ; 스크립트 최신 버전 확인
    CheckForUpdates() {
        url := "https://api.github.com/repos/banana-juseyo/Banana-Macro-PtcgP/releases/latest"
        try {
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("GET", url, true)
            http.Send()
            http.WaitForResponse()

            response := http.ResponseText
            response := Jxon_Load(&response)
            ; 버전 비교
            latestVersion := response["tag_name"]
            if (latestVersion != _currentVersion) {
                ; 업데이트가 필요한 경우
                fileInfo := Map(
                    "isAvailable", TRUE,
                    "fileName", response["assets"][1]["name"],
                    "destination", tempFile := A_Temp,
                    "fullPath", tempFile := A_Temp "\" A_ScriptName ".new",
                    "downloadUrl", response["assets"][1]["browser_download_url"],
                    "size", response["assets"][1]["size"]
                )
                return this.PerformUpdate(fileInfo)
            }
            ; 업데이트가 필요하지 않은 경우
            return true
        }
        catch Error as e {
            MsgBox "311::업데이트 확인 중 오류가 발생했습니다: " e.Message
            return false
        }
    }

    ; 업데이트 실행
    PerformUpdate(FileInfo) {
        downloadUrl := FileInfo["downloadUrl"]
        try {
            _fullpath := FileInfo["fullPath"]
            FileAppend("", _fullpath)
            backupFile := A_ScriptFullPath ".backup"
            ; 새 버전 다운로드
            ; Download(downloadUrl, tempFile)
            d := DownloaderInstance.Download(FileInfo, _fullpath)
            ; 현재 스크립트 백업
            if FileExist(backupFile)
                FileDelete(backupFile)
            FileCopy(A_ScriptFullPath, backupFile)
            ; 업데이트 스크립트 파일 생성
            updateScriptPath := this.CreateUpdateScript(_fullpath)
            ; 업데이트 스크립트 실행 후 현재 스크립트 종료
            Run(updateScriptPath)
            ExitApp

            return true
        }
        catch Error as e {
            MsgBox "342::업데이트 설치 중 오류가 발생했습니다: " e.Message
            return false
        }
    }

    CreateUpdateScript(tempFile) {
        ; 외부에서 업데이트를 수행할 새로운 AHK 업데이트 스크립트 생성
        updateScript := '#Requires AutoHotkey v2.0`n'
        updateScript .= 'Sleep(2000)`n'
        updateScript .= 'originalFile := "' A_ScriptFullPath '"`n'
        updateScript .= 'newFile := "' tempFile '"`n'
        updateScript .= '`n'
        updateScript .= 'try {`n'
        updateScript .= 'if FileExist(originalFile)`n'
        updateScript .= 'FileDelete(originalFile)`n'
        updateScript .= 'FileMove(newFile, originalFile)`n'
        updateScript .= 'Run(originalFile)`n'
        updateScript .= '} Catch Error as e {`n'
        updateScript .= 'MsgBox("Error While Update: " . e.Message)`n'
        updateScript .= '}`n'
        updateScript .= 'ExitApp'

        ; 업데이트 스크립트 임시 파일 생성
        updateScriptPath := A_Temp "\updater.ahk"
        if FileExist(updateScriptPath)
            FileDelete(updateScriptPath)

        FileAppend(updateScript, updateScriptPath)
        return updateScriptPath
    }
}

;; 메인 UI 정의
d := 1.25
width := Round(560 * d)
height := Round(432 * d)
radius := Round(8 * d)

ui := Gui("-SysMenu -Caption +LastFound")
ui.OnEvent('Close', (*) => ExitApp())

hIcon := LoadPicture(".\asset\image\app.ico", "Icon1 w" 32 " h" 32, &imgtype)
SendMessage(0x0080, 1, hIcon, ui)
ui.Show("w560 h432")
_instanceWindow := WinGetID(A_ScriptName, , "Code",)
WinSetTitle _appTitle . " " . _currentVersion, _instanceWindow
WinSetRegion Format("0-0 w{1} h{2} r{3}-{3}", width, height, radius), _instanceWindow

;; 메인 UI 생성 (웹뷰2)
wvc := WebView2.CreateControllerAsync(ui.Hwnd, { AdditionalBrowserArguments: "--enable-features=msWebView2EnableDraggableRegions" })
.await2()
wv := wvc.CoreWebView2
nwr := wv.NewWindowRequested(NewWindowRequestedHandler)
uiHtmlPath := A_ScriptDir . "\asset\html\index.html"
wv.Navigate("file:///" . StrReplace(uiHtmlPath, "\", "/"))

NewWindowRequestedHandler(wv2, arg) {
    deferral := arg.GetDeferral()
    arg.NewWindow := wv2
    deferral.Complete()
}

;; 메인 UI에서 넘어오는 값을 확인하는 리스너 -> Loop 중 함수로 넘기면 실행이 안됨 (우선순위 이슈)
nwr := wv.WebMessageReceived(HandleWebMessageReceived)
HandleWebMessageReceived(sender, args) {
    global _isPausing, _configGUIHwnd, GuiInstance

    message := args.TryGetWebMessageAsString()
    switch message {
        case "_button_click_header_home":
            Run _website
            return
        case "_button_click_header_restart":
            FinishRun()
            Reload
            return
        case "_button_click_header_quit":
            ExitApp
            return
        case "_button_click_footer_start":
            SetTimer(() => StartRun("00"), -1)
            return
        case "_button_click_footer_clear_friends":
            SetTimer(() => StartRun("D00"), -1)
            return
        case "_button_click_footer_pause":
            TogglePauseMode()
            Pause -1
            if (_isPausing) {
                SendUiMsg("⏸️ 일시 정지")
            }
            else if ( NOT _isPausing) {
                SendUiMsg("▶️ 재개")
            }
            return
        case "_button_click_footer_stop":
            FinishRun()
            return
        case "_button_click_footer_settings":
            GuiInstance := ConfigGUI()
            return
        case "_click_github_link":
            Run _website
            return
    }
}

;; 환경 설정 관련 로직 시작
; 환경 설정 불러오기
_userIni := ReadUserIni()

; 환경 설정 GUI 커스텀 클래스
class ConfigGUI {
    gui := ""

    __New() {
        if (_configGUIHwnd && WinExist(_configGUIHwnd)) {
            WinActivate(_configGUIHwnd)
            this.gui := GuiFromHwnd(_configGUIHwnd)
        }
        else {
            this.gui := OpenConfigGUI()
        }
    }

    Submit() {
        global _userIni
        _userIni := this.gui.Submit(TRUE)
        UpdateUserIni(_userIni)
        this.gui.Destroy()
        return
    }

    Dismiss() {
        if (WinActive(_configGUIHwnd)) {
            this.gui.Destroy()
            return
        }
    }
}

;; 환경값 재설정
_delayConfig := _userIni.Delay
_instanceNameConfig := _userIni.InstanceName
_acceptingTermConfig := _userIni.AcceptingTerm * 60000
_deletingTermConfig := _userIni.BufferTerm * 60000

; 환경설정 GUI 정의
OpenConfigGUI() {
    global _configGUIHwnd

    _gui := GUI()
    _configGUIHwnd := _gui.hwnd
    _gui.Opt("-SysMenu +LastFound +Owner" ui.Hwnd)
    _gui.Title := "환경 설정"
    _gui.BackColor := "DADCDE"
    _defaultValue := ""

    section := { x1: 30, y1: 30 }
    _confInstanceNameTitle := _gui.Add("Text", Format("x{} y{} w100 h30", section.x1, section.y1 + 5),
    "인스턴스 이름")
    _confInstanceNameTitle.SetFont("q3  s10 w600")
    _redDotText := _gui.Add("Text", Format("x{} y{} w10 h30", section.x1 + 93, section.y1 + 3),
    "*")
    _redDotText.SetFont("q3 s11 w600 cF65E3C")
    _confInstanceNameField := _gui.Add("Edit", Format("x{} y{} w280 h26 -VScroll Background", section.x1 +
        120,
        section.y1), _userIni.InstanceName)
    _confInstanceNameField.SetFont("q3  s13")
    _confInstanceNameField.name := "InstanceName"
    _confInstanceNameHint := _gui.Add("Text", Format("x{} y{} w280 h24", section.x1 + 120, section.y1 + 36),
    "불판이 가동중인 뮤뮤 플레이어 인스턴스 이름을 정확하게 입력해 주세요.")
    _confInstanceNameHint.SetFont("q3  s8 c636363")

    switch _userIni.Delay {
        global _defaultValue
        case "150": _defaultValue := "Choose1"
        case "250": _defaultValue := "Choose2"
        case "350": _defaultValue := "Choose3"
    }
    section := { x1: 30, y1: 100, default: _defaultValue }
    _confDelayTitle := _gui.Add("Text", Format("x{} y{} w100 h30", section.x1, section.y1 + 5), "딜레이`n(ms)"
    )
    _confDelayTitle.SetFont("q3 s10 w600")
    _confDelayField := _gui.Add("DropDownList", Format("x{} y{} w280 {}", section.x1 + 120,
        section.y1, section.default), [150, 250, 350])
    _confDelayField.SetFont("q3  s13")
    _confDelayField.name := "Delay"
    _confDelayHint := _gui.Add("Text", Format("x{} y{} w280 h24", section.x1 + 120, section.y1 + 30),
    "앱의 전반에 걸쳐 지연 시간을 설정합니다.`n값이 커지면 속도는 느려지지만 오류 확률이 줄어듭니다.")
    _confDelayHint.SetFont("q3  s8 c636363")

    switch _userIni.AcceptingTerm {
        global _defaultValue
        case 6: _defaultValue := "Choose1"
        case 8: _defaultValue := "Choose2"
        case 10: _defaultValue := "Choose3"
        case 12: _defaultValue := "Choose4"
    }
    section := { x1: 30, y1: 170, default: _defaultValue }
    _confAcceptingTermTitle := _gui.Add("Text", Format("x{} y{} w100 h30", section.x1, section.y1 + 5),
    "친구 수락 시간`n(분)")
    _confAcceptingTermTitle.SetFont("q3  s10 w600")
    _confAcceptingTermField := _gui.Add("DropDownList", Format("x{} y{} w280 {}", section.x1 + 120,
        section.y1, section.default), [6, 8, 10, 12])
    _confAcceptingTermField.SetFont("q3  s13")
    _confAcceptingTermField.name := "AcceptingTerm"
    _confAcceptingTermHint := _gui.Add("Text", Format("x{} y{} w280 h24", section.x1 + 120, section.y1 + 30
    ),
    "친구 수락 단계의 시간을 설정합니다.`n평균적으로 분당 8명 정도의 수락을 받을 수 있습니다.")
    _confAcceptingTermHint.SetFont("q3  s8 c636363")

    switch _userIni.BufferTerm {
        global _defaultValue
        case 2: _defaultValue := "Choose1"
        case 3: _defaultValue := "Choose2"
        case 4: _defaultValue := "Choose3"
    }
    section := { x1: 30, y1: 240, default: _defaultValue }
    _confBufferTermTitle := _gui.Add("Text", Format("x{} y{} w100 h30", section.x1, section.y1 + 5),
    "삭제 유예 시간`n(분)")
    _confBufferTermTitle.SetFont("q3  s10 w600")
    _confBufferTermField := _gui.Add("DropDownList", Format("x{} y{} w280 {}", section.x1 + 120, section.y1,
        section.default
    ), [2, 3, 4])
    _confBufferTermField.SetFont("q3  s13")
    _confBufferTermField.name := "BufferTerm"
    _confBufferTermHint := _gui.Add("Text", Format("x{} y{} w280 h24", section.x1 + 120, section.y1 + 30),
    "친구 수락을 완료한 뒤, 친구 삭제까지의 유예 시간을 설정합니다.")
    _confBufferTermHint.SetFont("q3  s8 c636363")

    section := { x1: 30, y1: 310 }
    _confirmButton := _gui.Add("Button", Format("x{} y{} w120 h40 BackgroundDADCDE", section.x1 + 76,
        section.y1
    ), "저장")
    _confirmButton.SetFont("q3  w600")
    _confirmButton.OnEvent("Click", Submit)
    _cancleButton := _gui.Add("Button", Format("x{} y{} w120 h40 BackgroundDADCDE", section.x1 + 200,
        section.y1
    ), "취소")
    _cancleButton.SetFont("q3  w600")
    _cancleButton.OnEvent("Click", Dismiss)

    _gui.Show("")
    _gui.Move(528, 205, 480, 410)

    return _gui

    Submit(*) {
        global _userIni
        _userIni := _gui.Submit(TRUE)
        UpdateUserIni(_userIni)
        _gui.Destroy()
        return
    }
    Dismiss(*) {
        if (WinActive(_gui.Hwnd)) {
            _gui.Destroy()
            return
        }
    }
}

F5:: {
    SetTimer(() => StartRun("00"), -1)
}
F6:: {
    SetTimer(() => StartRun("D00"), -1)
}
F7:: {
    TogglePauseMode()
    Pause -1
    if (_isPausing) {
        SendUiMsg("⏸️ 일시 정지")
    }
    else if ( NOT _isPausing) {
        SendUiMsg("▶️ 재개")
    }
    return
}
F8:: {
    SetTimer(() => FinishRun(), -1)
    Reload
}

^R:: {
    SetTimer(() => FinishRun(), -1)
    Reload
}

#HotIf WinActive(_configGUIHwnd)
~Enter:: {
    _gui := GuiFromHwnd(_configGUIHwnd)
    GuiInstance.Submit()
}
~Esc:: {
    GuiInstance.Dismiss()
}

;; 디버그용 GUI 정의
global statusGUI := Gui()
statusGUI.Opt("-SysMenu +Caption")
RecentTextCtrl := statusGUI.Add("Text", "x10 y10 w360 h20")
RecentTextCtrl.SetFont("s11", "Segoe UI Emoji, Segoe UI")
OldTextCtrl := statusGUI.Add("Text", "x10 y30 w360 h160")
OldTextCtrl.SetFont("C666666", "Segoe UI Emoji, Segoe UI")
if (_debug == TRUE) {
    statusGUI.Show("")
}
SendDebugMsg('Debug message will be shown here.')

SendUiMsg("포켓몬 카드 게임 포켓 갤러리")
SendUiMsg(" ")
SendUiMsg("바나나 무한 불판 매크로 " _currentVersion " by banana-juseyo")
SendUiMsg(" ")
SendUiMsg("매크로 초기화 완료")

;; 메인 함수 선언
_main(_currentLogic := "00") {
    global _isRunning
    global targetWindowHwnd
    global GuiInstance
    global _instanceNameConfig := _userIni.InstanceName
    SetTitleMatchMode 3

    if ( NOT _instanceNameConfig) {
        GuiInstance := ConfigGUI()
        SendUiMsg("[오류] 인스턴스 이름이 입력되지 않았습니다.")
        SetTimer(() => FinishRun(), -1)
        return
    }
    if ( NOT WinExist(_instanceNameConfig)) {
        GuiInstance := ConfigGUI()
        SendUiMsg("[오류] 인스턴스 이름이 잘못 되었습니다.")
        SetTimer(() => FinishRun(), -1)
        return
    }

    targetWindowHwnd := WinExist(_instanceNameConfig)
    if ( NOT targetWindowHwnd) {
        SendUiMsg("[오류] 입력한 인스턴스에서 PtcgP 앱을 확인할 수 없습니다 : " _instanceNameConfig)
        SetTimer(() => FinishRun(), -1)
        return
    }
    else if targetWindowHwnd {
        WinGetPos(&targetWindowX, &targetWindowY, &targetWindowWidth, &targetWindowHeight, targetWindowHwnd)
        global targetControlHandle := ControlGetHwnd('nemuwin1', targetWindowHwnd)
    }
    WinMove(, , 527, 970, targetWindowHwnd)
    WinActivate (targetWindowHwnd)
    CoordMode("Pixel", "Screen")

    ; 전역 변수 선언
    global targetWindowX, targetWindowY, targetWindowWidth, targetWindowHeight, _thisUserPass, _thisUserFulfilled
    global _nowAccepting
    global _recentTick, _currentTick
    global failCount

    _isRunning := TRUE
    _nowAccepting := TRUE
    _thisUserPass := FALSE
    _thisUserFulfilled := FALSE
    _recentTick := A_TickCount
    _currentTick := A_TickCount

    loop {
        if (!_isRunning) {
            break
        }
        ; 타겟 윈도우 재설정
        ; 타겟 윈도우의 크기를 동적으로 반영하기 위해 루프 속에서 실행
        WinGetPos(&targetWindowX, &targetWindowY, &targetWindowWidth, &targetWindowHeight, targetWindowHwnd)

        switch _currentLogic {
            ; 00. 화면 초기화
            case "00":
                ;; 환경값 재설정
                _delayConfig := _userIni.Delay
                _instanceNameConfig := _userIni.InstanceName
                _acceptingTermConfig := _userIni.AcceptingTerm * 60000
                _deletingTermConfig := _userIni.BufferTerm * 60000

                SendUiMsg("✅ 친구 추가부터 시작")
                caseDescription := '화면 초기화'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                InitLocation("RequestList")
                _currentLogic := "01"
                static globalRetryCount := 0
                failCount := 0

                ; 01. 친구 추가 확인
            case "01":
                caseDescription := '신청 확인'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)

                elapsedTime := _getElapsedTime()
                PhaseToggler(elapsedTime)

                if (_nowAccepting = FALSE) {
                    _currentLogic := "D00"
                    SendUiMsg("[페이즈 전환] 수락을 중단합니다. " . Round(_deletingTermConfig / 60000) . "분 후 친구 삭제 시작.")
                    globalRetryCount := 0
                    Sleep(_deletingTermConfig)
                }

                if (_nowAccepting == TRUE && _currentLogic == "01") {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('60%')
                        , getScreenYbyWindowPercentage('5%')
                        , getScreenXbyWindowPercentage('99%')
                        , getScreenYbyWindowPercentage('75%')
                        , '*50 ' . _imageFile_friendRequestListCard)  ; // 신청 카드 확인
                    if (match == 1) { ; // 신청 카드 있는 경우
                        targetX := matchedX - targetWindowX
                        targetY := matchedY - targetWindowY - 50
                        delayLong()
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        delayShort() ; // 오류 방지 위해 2중 클릭
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        _currentLogic := "02-A"
                        failCount := 0 ; // 유저 화면 진입 시 failCount 초기화
                        globalRetryCount := 0
                        delayLong()
                    }
                    else if (match == 0) {
                        match := ImageSearch(
                            &matchedX
                            , &matchedY
                            , getScreenXbyWindowPercentage('20%')
                            , getScreenYbyWindowPercentage('45%')
                            , getScreenXbyWindowPercentage('80%')
                            , getScreenYbyWindowPercentage('55%')
                            , '*50 ' . _imageFile_friendRequestListEmpty) ; // 잔여 신청 목록 = 0 인지 확인
                        if (match == 1) { ; // 잔여 신청 목록 = 0 인 경우
                            SendUiMsg('[안내] 잔여 신청 목록이 없습니다. 10초 후 새로고침.')
                            sleep(10000) ; 10초 중단
                            InitLocation("RequestList")
                            globalRetryCount := 0
                        }
                        else if (match == 0) { ; // 신청 목록 확인 실패, 일시적인 오류일 수 있어 failCount로 처리
                            failCount := failCount + 1
                            delayLong()
                        }
                    }
                }
                if (failCount >= 5) {
                    globalRetryCount := globalRetryCount + 1
                    if (globalRetryCount > 5) {
                        SendUiMsg("[심각] 반복적인 화면 인식 실패. 프로그램을 종료합니다.")
                        ExitApp
                    }
                    SendUiMsg("[오류] 신청 목록 확인 실패. 화면을 초기화 합니다.")
                    InitLocation("RequestList")
                    _currentLogic := "01"
                    failCount := 0
                    delayShort()
                }

            case "02-A": ; // 02. 유저 디테일 // A. 화면 진입 확인
                caseDescription := '유저 화면 진입'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                match := ImageSearch(
                    &matchedX,
                    &matchedY,
                    getScreenXbyWindowPercentage('12%'),
                    getScreenYbyWindowPercentage('70%'),
                    getScreenXbyWindowPercentage('88%'),
                    getScreenYbyWindowPercentage('77%'),
                    '*50 ' . _imageFile_userDetailRequestFriend)
                if (match == 1) {
                    SendUiMsg("[오류] 유저의 신청 취소")
                    _clickCloseModalButton()
                    _thisUserFulfilled := TRUE
                    _currentLogic := "01"
                }
                else if (match == 0) {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('35%')
                        , getScreenYbyWindowPercentage('80%')
                        , getScreenXbyWindowPercentage('65%')
                        , getScreenYbyWindowPercentage('92%')
                        , '*50 ' . _imageFile_userDetailEmblem)
                    if (match == 1) {
                        ; ControlClick(targetControlHandle, targetWindowHandle, , 'WD', 1, 'NA', , ) ;
                        ControlClick(targetControlHandle, targetWindowHwnd, , 'WD', 2, 'NA', ,) ;
                        delayShort()
                        ; _clickSafeArea() ; // 어째선지 호출이 안됨
                        ControlClick(
                            'X' . getWindowXbyWindowPercentage('98%') . ' Y' . getWindowYbyWindowPercentage('50%')
                            , targetWindowHwnd, , 'Left', 2, 'NA', ,)
                        _currentLogic := "02-B"
                        failCount := 0
                        ; _delayLong() ; // 1배속
                        delayShort() ; // 2배속
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                        SendUiMsg("[안내] 유저화면 진입완료 대기 중")
                        delayShort()
                    }
                    if (failCount >= 5) {
                        ; 잔여 신청 목록이 0인지 체크
                        match := ImageSearch(
                            &matchedX
                            , &matchedY
                            , getScreenXbyWindowPercentage('20%')
                            , getScreenYbyWindowPercentage('45%')
                            , getScreenXbyWindowPercentage('80%')
                            , getScreenYbyWindowPercentage('55%')
                            , '*50 ' . _imageFile_friendRequestListEmpty)
                        if (match == 1) {
                            SendUiMsg('[안내] 잔여 신청 목록이 없습니다. 10초 후 새로고침.')
                            _currentLogic := "01"
                            failCount := 0
                            sleep(10000) ; 10초 중단
                            InitLocation("RequestList")
                        }
                        else if (match == 0) {
                            SendUiMsg("[오류] 유저 화면 진입 실패. 화면을 초기화 합니다.")
                            _currentLogic := "01"
                            failCount := 0
                            InitLocation("RequestList")
                        }
                    }
                }

                ; 02. 유저 디테일 // B. 마이베스트 진입 시도
            case "02-B":
                caseDescription := '마이베스트 카드 검색'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                _clickSafeArea()
                match := ImageSearch(
                    &matchedX
                    , &matchedY
                    , getScreenXbyWindowPercentage('20%')
                    , getScreenYbyWindowPercentage('5%')
                    , getScreenXbyWindowPercentage('80%')
                    , getScreenYbyWindowPercentage('90%')
                    , '*100 ' . _imageFile_userDetailEmpty)
                if (match == 1) {
                    SendUiMsg("[오류] 마이 베스트 미설정")
                    SendUiMsg("❌ 입국 심사 거절")
                    _thisUserPass := FALSE
                    _thisUserFulfilled := FALSE
                    _currentLogic := "03-B"
                    failCount := 0
                }
                else if (match == 0) {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('38%')
                        , getScreenYbyWindowPercentage('5%')
                        , getScreenXbyWindowPercentage('62%')
                        , getScreenYbyWindowPercentage('90%')
                        , '*100 ' . _imageFile_userDetailMybest)
                    if (match == 1) {
                        targetX := (matchedX - targetWindowX) + 20
                        targetY := (matchedY - targetWindowY) + 100
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        delayShort() ; // 오류 자꾸 발생해서 2중 클릭 예외 처리
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        ; _delayLong() ; // 1배속
                        _currentLogic := "03-A"
                        failCount := 0
                        delayLong()
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                    }
                    if (failCount >= 5) {
                        SendUiMsg("[오류] 마이 베스트 진입 불가")
                        _clickCloseModalButton()
                        _currentLogic := "01"
                        failCount := 0
                        delayShort()
                    }
                }

                ; 03. 입국 심사 // A. 여권 확인
            case "03-A":
                caseDescription := '입국 심사 : 여권 확인'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                ; _delayLong() ; // 1배속
                if (failCount < 5) {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('2%')
                        , getScreenYbyWindowPercentage('83%')
                        , getScreenXbyWindowPercentage('22%')
                        , getScreenYbyWindowPercentage('90%')
                        , '*50 ' . _imageFile_passportPikachu)
                    if (match == 1) {
                        _thisUserPass := TRUE
                        _thisUserFulfilled := FALSE
                        SendUiMsg("✅ 입국 심사 통과")
                        ControlClick('X' . getWindowXbyWindowPercentage('50%') . ' Y' .
                        getWindowYbyWindowPercentage(
                            '95%'), targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        _currentLogic := "03-B"
                        failCount := 0
                        delayShort()
                    }
                    else if (match == 0) {
                        SendUiMsg("[여권 인식 실패] 잠시 후 재시도 ")
                        failCount := failCount + 1
                        delayLong()
                    }
                }
                if (failCount >= 5) {
                    SendUiMsg("❌ 입국 심사 거절")
                    _thisUserPass := FALSE
                    _thisUserFulfilled := FALSE
                    ControlClick('X' . getWindowXbyWindowPercentage('50%') . ' Y' . getWindowYbyWindowPercentage(
                        '95%'),
                    targetWindowHwnd, , 'Left', 1, 'NA', ,)
                    _currentLogic := "03-B"
                    failCount := 0
                    delayShort()
                }

                ; 03. 입국 심사 // B. 유저 화면 재진입, 신청 처리
            case "03-B":
                caseDescription := '유저 화면 재진입, 신청 처리'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                match := ImageSearch(
                    &matchedX
                    , &matchedY
                    , getScreenXbyWindowPercentage('38%')
                    , getScreenYbyWindowPercentage('5%')
                    , getScreenXbyWindowPercentage('62%')
                    , getScreenYbyWindowPercentage('90%')
                    , '*100 ' . _imageFile_userDetailMybest)
                if (match == 1) {
                    ControlClick(targetControlHandle, targetWindowHwnd, , 'WU', 3, 'NA', ,) ;
                    delayShort()
                    _currentLogic := "03-C"
                    failCount := 0
                }
                else if (match == 0) {
                    ControlClick(targetControlHandle, targetWindowHwnd, , 'WU', 1, 'NA', ,)
                    delayShort()
                    ControlClick(targetControlHandle, targetWindowHwnd, , 'WD', 1, 'NA', ,)
                    delayShort()
                    failCount := failCount + 1
                }
                if (failCount >= 5) {
                    SendUiMsg("[오류] 승인 화면 진입 실패. 화면을 초기화 합니다.")
                    _currentLogic := "01"
                    InitLocation("RequestList")
                    failCount := 0
                }

            case "03-C":
                caseDescription := '신청 처리'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                if (_thisUserPass == TRUE && _thisUserFulfilled == FALSE) {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('12%')
                        , getScreenYbyWindowPercentage('70%')
                        , getScreenXbyWindowPercentage('88%')
                        , getScreenYbyWindowPercentage('77%')
                        , '*50 ' . _imageFile_userDetailAccept)
                    ; _statusMsg("[match] = " . match)
                    if (match == 1) {
                        targetX := matchedX - targetWindowX + 10
                        targetY := matchedY - targetWindowY + 10
                        ; _statusMsg("[클릭]`ntargetX : " . targetX . "`ntargetY : " . targetY)
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        _thisUserFulfilled := TRUE
                        failCount := 0
                        delayLong() ; // 닌텐도 서버 이슈로 로딩 발생
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                        ControlClick(targetControlHandle, targetWindowHwnd, , 'WU', 3, 'NA', ,) ;

                        ; 재시도 후 failsafe, 해당 유저의 신청 포기 처리, 현재 case 정보 로그 남기기
                        match := ImageSearch(
                            &matchedX,
                            &matchedY,
                            getScreenXbyWindowPercentage('12%'),
                            getScreenYbyWindowPercentage('70%'),
                            getScreenXbyWindowPercentage('88%'),
                            getScreenYbyWindowPercentage('77%'),
                            '*50 ' . _imageFile_userDetailRequestFriend)
                        if (match == 1) {
                            SendUiMsg("[오류] 유저의 신청 취소")
                            _clickCloseModalButton()
                            _thisUserFulfilled := TRUE
                            _currentLogic := "01"
                            failCount := 0
                        }
                        else if (match == 0) {
                            delayShort()
                        }
                    }
                    if (failCount >= 5) {
                        SendUiMsg("[오류] 승인 불가")
                        _clickCloseModalButton()
                        _currentLogic := "01"
                        failCount := 0
                        delayShort()
                    }

                }
                if (_thisUserPass == FALSE && _thisUserFulfilled == FALSE) {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('12%')
                        , getScreenYbyWindowPercentage('70%')
                        , getScreenXbyWindowPercentage('88%')
                        , getScreenYbyWindowPercentage('77%')
                        , '*50 ' . _imageFile_userDetailDecline)
                    if (match == 1) {
                        targetX := matchedX - targetWindowX
                        targetY := matchedY - targetWindowY
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        _thisUserFulfilled := TRUE
                        failCount := 0
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                        ControlClick(targetControlHandle, targetWindowHwnd, , 'WU', 3, 'NA', ,) ;
                    }
                }
                if (_thisUserPass == TRUE && _thisUserFulfilled == TRUE) {
                    match := ImageSearch(
                        &matchedX,
                        &matchedY,
                        getScreenXbyWindowPercentage('12%'),
                        getScreenYbyWindowPercentage('70%'),
                        getScreenXbyWindowPercentage('88%'),
                        getScreenYbyWindowPercentage('77%'),
                        '*50 ' . _imageFile_userDetailFriendNow)
                    if (match == 1) {
                        ControlClick('X' . getWindowXbyWindowPercentage('50%') . ' Y' .
                        getWindowYbyWindowPercentage(
                            '95%'), targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        SendUiMsg("[승인 완료] 다음 신청 진행")
                        _currentLogic := "01"
                        failCount := 0
                    }
                    else if (match == 0) {
                        ; _delayXLong() ; // 유저가 입국 절차 중간에 신청 취소 시 닌텐도 서버 이슈로 긴 로딩 발생
                        ; 딜레이를 주면 전체 사이클이 느려지는 문제 / 차라리 사이클을 한번 더 돌리는게 이득
                        match := ImageSearch(
                            &matchedX
                            , &matchedY
                            , getScreenXbyWindowPercentage('25%')
                            , getScreenYbyWindowPercentage('43%')
                            , getScreenXbyWindowPercentage('75%')
                            , getScreenYbyWindowPercentage('52%')
                            , '*50 ' . _imageFile_userDetailRequestNotFound)
                        if (match == 1) {
                            SendUiMsg("[오류] '신청은 발견되지 않았습니다'")
                            ControlClick(
                                'X' . getWindowXbyWindowPercentage('50%') . ' Y' . getWindowYbyWindowPercentage(
                                    '68%')
                                , targetWindowHwnd, , 'Left', 1, 'NA', ,)
                            delayShort()
                            ControlClick('X' . getWindowXbyWindowPercentage('50%') . ' Y' .
                            getWindowYbyWindowPercentage('95%'), targetWindowHwnd, , 'Left', 1, 'NA', ,)
                            _currentLogic := "01"
                            failCount := 0
                            delayLong()
                        }
                        else if (match == 0) {
                            SendUiMsg("[안내] 수락완료 대기 중")
                            failCount := failCount + 1
                        }
                    }
                }
                if (_thisUserPass == FALSE && _thisUserFulfilled == TRUE) {
                    match := ImageSearch(
                        &matchedX,
                        &matchedY,
                        getScreenXbyWindowPercentage('12%'),
                        getScreenYbyWindowPercentage('70%'),
                        getScreenXbyWindowPercentage('88%'),
                        getScreenYbyWindowPercentage('77%'),
                        '*50 ' . _imageFile_userDetailRequestFriend)
                    if (match == 1) {
                        _clickCloseModalButton()
                        SendUiMsg("[거절 완료] 다음 신청 진행")
                        _currentLogic := "01"
                        failCount := 0
                        delayShort()
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                    }
                }
                if (failCount >= 5) {
                    SendUiMsg("[오류] 유저 화면 진입 실패. 화면을 초기화 합니다.")
                    _currentLogic := "01"
                    failCount := 0
                    SendInput "{esc}"
                    InitLocation("RequestList")
                }

                ;; 거절 로직 시작
            case "D00":
                ;; 환경값 재설정
                _delayConfig := _userIni.Delay
                _instanceNameConfig := _userIni.InstanceName
                _acceptingTermConfig := _userIni.AcceptingTerm * 60000
                _deletingTermConfig := _userIni.BufferTerm * 60000

                SendUiMsg("🗑️ 친구 삭제 부터 시작")
                caseDescription := '친구 삭제를 위해 메뉴 초기화'
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                failCount := 0
                _clickCloseModalButton()
                delayXLong()
                match := ImageSearch(
                    &matchedX
                    , &matchedY
                    , getScreenXbyWindowPercentage('2%')
                    , getScreenYbyWindowPercentage('80%')
                    , getScreenXbyWindowPercentage('24%')
                    , getScreenYbyWindowPercentage('90%')
                    , '*100 ' . _imageFile_friendMenuButton)
                if (match == 1) {
                    ; _statusMsg("match = 1")
                    targetX := matchedX - targetWindowX + 10
                    targetY := matchedY - targetWindowY + 10
                    ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                    _currentLogic := "D01"
                    delayLong()
                }
                else if (match == 0) {
                    ; _statusMsg("match = 0")
                }

            case "D01":
                caseDescription := "친구 목록 확인"
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                delayShort()
                static globalRetryCount := 0 ; 무한루프 시 앱 종료를 위해

                match := ImageSearch(
                    &matchedX
                    , &matchedY
                    , getScreenXbyWindowPercentage('56%')
                    , getScreenYbyWindowPercentage('20%')
                    , getScreenXbyWindowPercentage('98%')
                    , getScreenYbyWindowPercentage('44%')
                    , '*100 ' . _imageFile_friendListCard)
                if (match == 1) {
                    globalRetryCount := 0
                    ; _statusMsg("match = 1")
                    targetX := matchedX - targetWindowX
                    targetY := matchedY - targetWindowY
                    ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                    delayShort()
                    ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                    _currentLogic := "D02"
                    _thisUserDeleted := FALSE
                    failCount := 0 ; 성공 시 초기화
                    delayLong()
                }
                else if (match == 0) {
                    match := ImageSearch(
                        &matchedX
                        , &matchedY
                        , getScreenXbyWindowPercentage('20%')
                        , getScreenYbyWindowPercentage('45%')
                        , getScreenXbyWindowPercentage('80%')
                        , getScreenYbyWindowPercentage('55%')
                        , '*100 ' . _imageFile_friendListEmpty)
                    if (match == 1) {
                        SendUiMsg("[안내] 친구를 모두 삭제했습니다.")
                        SendUiMsg("[페이즈 전환] 수락을 재개합니다.")
                        PhaseToggler()
                        globalRetryCount := 0 ; 성공 시 초기화
                        _currentLogic := "00"
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                    }
                    if (failCount >= 5) {
                        globalRetryCount := globalRetryCount + 1
                        if (globalRetryCount > 5) {
                            SendUiMsg("[심각] 반복적인 화면 인식 실패. 프로그램을 종료합니다.")
                            ExitApp
                        }
                        SendUiMsg("[오류] 유저 화면 진입 실패. 화면을 초기화 합니다.")
                        failCount := 0
                        InitLocation('FriendList')
                    }
                }

            case "D02":
                caseDescription := "친구 화면 진입"
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                delayShort()
                match := ImageSearch(
                    &matchedX,
                    &matchedY,
                    getScreenXbyWindowPercentage('12%'),
                    getScreenYbyWindowPercentage('70%'),
                    getScreenXbyWindowPercentage('88%'),
                    getScreenYbyWindowPercentage('77%'),
                    '*50 ' . _imageFile_userDetailFriendNow)
                if (match == 1) {
                    ; _statusMsg("match = 1")
                    targetX := matchedX - targetWindowX + 5
                    targetY := matchedY - targetWindowY + 5
                    ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                    _currentLogic := "D03"
                    delayLong()
                }
                else if (match == 0) {
                    failCount := failCount + 1
                }
                if (failCount >= 5) {
                    SendUiMsg("[오류] 친구 삭제 호출 실패. 화면을 초기화 합니다.")
                    _currentLogic := "D01"
                    failCount := 0
                    InitLocation("FriendList")
                }

            case "D03":
                caseDescription := "친구 삭제 진행"
                SendUiMsg("[Current] " . _currentLogic . " : " . caseDescription)
                if (_thisUserDeleted == FALSE) {
                    match := ImageSearch(
                        &matchedX,
                        &matchedY,
                        getScreenXbyWindowPercentage('50%'),
                        getScreenYbyWindowPercentage('62%'),
                        getScreenXbyWindowPercentage('98%'),
                        getScreenYbyWindowPercentage('74%'),
                        '*50 ' . _imageFile_removeFriendConfirm)
                    if (match == 1) {
                        ; _statusMsg("match = 1")
                        targetX := matchedX - targetWindowX + 50
                        targetY := matchedY - targetWindowY + 20
                        ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
                        _thisUserDeleted := TRUE
                        ; _statusMsg("[친구 삭제 완료]")
                        delayLong()
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                    }
                    if (failCount >= 5) {
                        SendUiMsg("[오류] 친구 삭제 호출 실패. 화면을 초기화 합니다.")
                        _currentLogic := "D01"
                        failCount := 0
                        SendInput "{esc}"
                        InitLocation("FriendList")
                    }
                }
                else if (_thisUserDeleted == TRUE) {
                    ; _statusMsg("[매치 시도] "
                    ; . getScreenXbyWindowPercentage('12%')
                    ; . " " . getScreenYbyWindowPercentage('70%')
                    ; . " " . getScreenXbyWindowPercentage('88%')
                    ; . " " . getScreenYbyWindowPercentage('77%'))
                    delayShort()
                    match := ImageSearch(
                        &matchedX,
                        &matchedY,
                        getScreenXbyWindowPercentage('12%'),
                        getScreenYbyWindowPercentage('70%'),
                        getScreenXbyWindowPercentage('88%'),
                        getScreenYbyWindowPercentage('77%'),
                        '*50 ' . _imageFile_userDetailRequestFriend)
                    if (match == 1) {
                        _clickCloseModalButton()
                        _currentLogic := "D01"
                        delayLong()
                    }
                    else if (match == 0) {
                        failCount := failCount + 1
                    }
                    if (failCount >= 5) {
                        SendUiMsg("[오류] 화면 전환 실패. 화면을 초기화 합니다.")
                        _currentLogic := "D01"
                        failCount := 0
                        SendInput "{esc}"
                        InitLocation("FriendList")
                    }
                }

        }
    }
}

; // Current 확인 로직 추가
; // Current에 따라 초기 화면으로 돌아가는 로직 추가
; // 이전 단계로 넘어가기 전에 현재 화면 체크 로직 필요 / 체크 완료 후 Current 변경 / 전체적으로 화면 변경 시점의 전환 로직 살펴보기
; // control 클릭 함수 정리 필요 -->> tryClick
; // 주요 버튼 클릭 함수화 ? 가능한지

;; 함수 정의
; getScreenXbyWindowPercentage() 정의
; 1) nn%와 같은 상대값을 입력 받고
; 2) 타겟 윈도우의 창 크기를 기준으로 절대값으로 변환
; 3) 스크린 기준 좌표로 반환
getScreenXbyWindowPercentage(somePercentage) {
    if targetWindowWidth = false {
        MsgBox "타겟 윈도우가 설정되지 않았습니다."
        return
    }
    replacedPercentage := StrReplace(somePercentage, "%")
    if IsNumber(replacedPercentage) = false {
        MsgBox "올바른 퍼센티지 값이 입력되지 않았습니다."
        return
    }
    return Round(targetWindowX + (targetWindowWidth * replacedPercentage / 100), -1)
}

; getScreenYbyWindowPercentage() 정의
; "이미지 서치 시에만" 사용 // 퍼센티지 상대값을 스크린 기준 절대값으로 변환
getScreenYbyWindowPercentage(somePercentage) {
    if targetWindowHeight = false {
        MsgBox "타겟 윈도우가 설정되지 않았습니다."
        return
    }
    replacedPercentage := StrReplace(somePercentage, "%")
    if IsNumber(replacedPercentage) = false {
        MsgBox "올바른 퍼센티지 값이 입력되지 않았습니다."
        return
    }
    return Round(targetWindowY + (targetWindowHeight * replacedPercentage / 100), -1)
}

; getWindowXbyWindowPercentage() 정의
; 클릭 등 창 내부 상호작용에 사용 // 퍼센티지 상대값을 창 기준 절대값으로 변환
getWindowXbyWindowPercentage(somePercentage) {
    if targetWindowWidth = false {
        MsgBox "타겟 윈도우가 설정되지 않았습니다."
        return
    }
    replacedPercentage := StrReplace(somePercentage, "%")
    if IsNumber(replacedPercentage) = false {
        MsgBox "올바른 퍼센티지 값이 입력되지 않았습니다."
        return
    }
    return Round((targetWindowWidth * replacedPercentage / 100), -1)
}

getWindowYbyWindowPercentage(somePercentage) {
    if targetWindowHeight = false {
        MsgBox "타겟 윈도우가 설정되지 않았습니다."
        return
    }

    replacedPercentage := StrReplace(somePercentage, "%")
    if IsNumber(replacedPercentage) = false {
        MsgBox "올바른 퍼센티지 값이 입력되지 않았습니다."
        return
    }
    return Round((targetWindowHeight * replacedPercentage / 100), -1)

}

delayShort() {
    Sleep(_delayConfig)
}

delayLong() {
    Sleep(_delayConfig * 3)
}

delayXLong() {
    Sleep(_delayConfig * 10)
}

delayLoad() {
    Sleep(2000)
}

; 모달 x 버튼 클릭
_clickCloseModalButton() {
    ControlClick(
        'X' . getWindowXbyWindowPercentage('50%') . ' Y' . getWindowYbyWindowPercentage('95%')
        , targetWindowHwnd, , 'Left', 1, 'NA', ,)
}

_clickSafeArea() {
    ControlClick(
        'X' . getWindowXbyWindowPercentage('98%') . ' Y' . getWindowYbyWindowPercentage('50%')
        , targetWindowHwnd, , 'Left', 2, 'NA', ,)
}

_getElapsedTime() {
    global _nowAccepting
    global _recentTick, _currentTick

    _currentTick := A_TickCount
    elapsedTime := _currentTick - _recentTick
    SendUiMsg("[안내] 현재 페이즈 경과 시간 - " . MillisecToTime(elapsedTime))
    return elapsedTime
}

PhaseToggler(elapsedTime := 0) {
    global _nowAccepting
    global _recentTick, _currentTick
    global _acceptingTermConfig

    if (_nowAccepting == TRUE
        && elapsedTime > _acceptingTermConfig) {
        _nowAccepting := FALSE
        _recentTick := A_TickCount
        SendUiMsg("[페이즈 변경] 친구 삭제 페이즈로 변경")
        SendUiMsg("[안내] 현재 페이즈 경과 시간 - " . MillisecToTime(elapsedTime))
    }
    else if (_nowAccepting == FALSE) {
        _nowAccepting := TRUE
        _recentTick := A_TickCount
        SendUiMsg("[페이즈 변경]  친구 수락 페이즈로 변경")
        SendUiMsg("[안내] 현재 페이즈 경과 시간 - " . MillisecToTime(elapsedTime))
    }
}

InitLocation(Destination := "RequestList") {
    failCount := 0
    while failCount < 10 {
        match := ImageSearch(
            &matchedX
            , &matchedY
            , getScreenXbyWindowPercentage('2%')
            , getScreenYbyWindowPercentage('80%')
            , getScreenXbyWindowPercentage('24%')
            , getScreenYbyWindowPercentage('90%')
            , '*100 ' . _imageFile_friendMenuButton)
        if (match == 1) {
            targetX := matchedX - targetWindowX + 10
            targetY := matchedY - targetWindowY + 10
            ControlClick('X' . targetX . ' Y' . targetY, targetWindowHwnd, , 'Left', 1, 'NA', ,)
            delayXLong()
            if (Destination == "RequestList") {
                ControlClick('X' . getWindowXbyWindowPercentage('80%') . ' Y' . getWindowYbyWindowPercentage('86%'),
                targetWindowHwnd, , 'Left', 1, 'NA', ,)
                delayShort()
                return
            }
            else if (Destination == "FriendList") {
                return
            }
        }
        else if match == 0 {
            failCount := failCount + 1
            _clickCloseModalButton()
            delayLong()
        }
    }
    if (failCount >= 10) {
        SendUiMsg("[오류] 화면을 초기화할 수 없습니다.")
        return
    }
}

MillisecToTime(msec) {
    secs := Floor(Mod(msec / 1000, 60))
    mins := Floor(Mod(msec / (1000 * 60), 60))
    hour := Floor(Mod(msec / (1000 * 60 * 60), 24))
    days := Floor(msec / (1000 * 60 * 60 * 24))
    return Format("{}분 {:2}초", mins, secs)
}

; 디버그 메시지 표시
SendDebugMsg(Message) {
    global recentText, oldTexts, RecentTextCtrl, OldTextCtrl
    _logRecord(Message)
    if (recentText == "") {
    }
    else {
        oldTexts := recentText . (oldTexts ? "`n" . oldTexts : "")
        OldTextCtrl.Text := oldTexts
    }
    if (StrLen(oldTexts) > 2000) {
        oldTexts := ""
    }

    recentText := Message
    RecentTextCtrl.Text := recentText
    if (_debug == TRUE) {
        statusGUI.Show("NA")
    }
}

; ui 로그 창에 메시지 표시 & 기록
SendUiMsg(Message) {
    global messageQueue
    messageQueue.Push(Message)

    i := InStr(wv.Source, "/", , -1)
    w := SubStr(wv.source, i + 1)

    if (w == "index.html") {
        _messageQueueHandler()
    }
    else {
        SetTimer(_messageQueueHandler, 100)
    }
}

_messageQueueHandler() {
    global messageQueue

    for Message in messageQueue {
        wv.ExecuteScriptAsync("addLog('" Message "')")
        wv.ExecuteScriptAsync("adjustTextAreaHeight()")
        messageQueue.RemoveAt(1)
        _logRecord(Message)
    }
    SetTimer , 0
}

_logRecord(text) {
    global logfile
    FileAppend "[" . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . "] " . text .
        "`n",
        logfile, "UTF-8"
}

ToggleRunUiMode() {
    wv.ExecuteScriptAsync("SwitchUIMode('" _isRunning "')")
    return
}

ToggleRunMode() {
    global _isRunning
    _isRunning := NOT _isRunning
    wv.ExecuteScriptAsync("SwitchUIMode('" _isRunning "')")
    return
}

StartRun(startLogic) {
    global _isRunning
    _isRunning := TRUE
    wv.ExecuteScriptAsync("SwitchUIMode('" TRUE "')")
    SetTimer(() => _main(startLogic), -1)
    return
}

FinishRun() {
    global _isRunning
    _isRunning := FALSE
    wv.ExecuteScriptAsync("SwitchUIMode('" FALSE "')")
    ; SendUiMsg("⏹️ 동작을 중지합니다.")
}

TogglePauseMode() {
    global _isPausing
    _isPausing := NOT _isPausing
    wv.ExecuteScriptAsync("SwitchPauseMode('" _isPausing "')")
    return
}

ReadUserIni() {
    obj := {}
    obj.InstanceName := IniRead("Settings.ini", "UserSettings", "InstanceName")
    obj.Delay := IniRead("Settings.ini", "UserSettings", "Delay")
    obj.AcceptingTerm := IniRead("Settings.ini", "UserSettings", "AcceptingTerm")
    obj.BufferTerm := IniRead("Settings.ini", "UserSettings", "BufferTerm")
    return obj
}

UpdateUserIni(obj) {
    IniWrite obj.InstanceName, "Settings.ini", "UserSettings", "InstanceName"
    IniWrite obj.Delay, "Settings.ini", "UserSettings", "Delay"
    IniWrite obj.AcceptingTerm, "Settings.ini", "UserSettings", "AcceptingTerm"
    IniWrite obj.BufferTerm, "Settings.ini", "UserSettings", "BufferTerm"
}
