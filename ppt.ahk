#IfWinActive ahk_class screenClass ; Áp dụng khi đang ở chế độ trình chiếu (Slide Show)

LButton::Send {Right}   ; Chuột trái để chuyển tới slide sau
RButton::Send {Left}    ; Chuột phải để quay lại slide trước

#IfWinActive  ; Kết thúc khối điều kiện
