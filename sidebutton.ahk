#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Ánh xạ nút chuột bên cạnh đầu tiên (XButton1) thành phím mũi tên trái
XButton1::Left

; Ánh xạ nút chuột bên cạnh thứ hai (XButton2) thành phím mũi tên phải
XButton2::Right

; Nếu bạn muốn đảo ngược (XButton1 thành mũi tên phải và XButton2 thành mũi tên trái), hãy sử dụng code sau:
; XButton1::Right
; XButton2::Left

; Nếu bạn muốn sử dụng các phím mũi tên lên/xuống thay vì trái/phải, hãy thay thế bằng:
; XButton1::Up
; XButton2::Down