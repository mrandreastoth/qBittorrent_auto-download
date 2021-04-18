; qBittorent Auto-Download
;   AutoHotkey 1.1.33.06 script for Windows by Andreas Toth
;   Auto-adds torrent link in sequential order with first and last pieces first - configurable via tray icon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

app_info_text := ["qBittorent Auto-Download", "By: Andreas Toth", "At: 2021-04-18 20:30"]
app_menu_info_separator_before := true
app_menu_info_separator_after := true

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The following configuration data was obtained from qBittorent 4.3.4.1 running under Windows 10
; Note that widgets cannot be queried dynamically as they are not native controls

; qBitttorent add torrent link dialog
win_bin := "qbittorrent.exe"
win_class := "Qt5152QWindowIcon"
win_exclude_title_base := "qBittorrent"
win_exclude_titles := ["Torrent is already present", "Download from URLs", "Manage Cookies", "Options", "About qBittorrent"]
win_min_width := 446
win_min_height := 593

; Offset corrections
x_offset := 0
y_offset := 0

index_base := 1

; Check-box
cbx_SequentialOrder_index := index_base + 0
cbx_SequentialOrder_text := "Download in sequential order"
cbx_SequentialOrder_menu_text := "Click '" . cbx_SequentialOrder_text . "'"
cbx_SequentialOrder_x := x_offset + 150
cbx_SequentialOrder_y := y_offset + 272
cbx_SequentialOrder_init_enabled := true

; Check-box
cbx_EndingsFirst_index := index_base + 1
cbx_EndingsFirst_text := "Download first and last pieces first"
cbx_EndingsFirst_menu_text := "Click '" . cbx_EndingsFirst_text . "'"
cbx_EndingsFirst_x := cbx_SequentialOrder_x
cbx_EndingsFirst_y := y_offset + 305
cbx_EndingsFirst_init_enabled := true

; Button (bottom-right coordinates calculated from values obtained from an arbitrary window size)
btn_OK_index := index_base + 2
btn_OK_text := "OK"
btn_OK_menu_text := "Click '" . btn_OK_text . "'"
btn_OK_rx := 916 - (x_offset + 759)
btn_OK_by := 662 - (y_offset + 631)
btn_OK_init_enabled := true

; Mouse
mouse_Restore_index := index_base + 3
mouse_Restore_menu_text := "Restore mouse position"
mouse_Restore_init_enabled := true

; Option values
global option_enabled := [false, false, false, false]
option_enabled[cbx_SequentialOrder_index] := cbx_SequentialOrder_init_enabled
option_enabled[cbx_EndingsFirst_index] := cbx_EndingsFirst_init_enabled
option_enabled[btn_OK_index] := btn_OK_init_enabled
option_enabled[mouse_Restore_index] := mouse_Restore_init_enabled

; Menu text
menu_text := ["", "", "", ""]
menu_text[cbx_SequentialOrder_index] := cbx_SequentialOrder_menu_text
menu_text[cbx_EndingsFirst_index] := cbx_EndingsFirst_menu_text
menu_text[btn_OK_index] := btn_OK_menu_text
menu_text[mouse_Restore_index] := mouse_Restore_menu_text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

global menu_pos_index_offset = app_Info.MaxIndex
gosub menu_main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
WinWaitActive, ahk_exe %win_bin% ahk_class %win_class%, , , %win_exclude_title_base%

MouseGetPos, mouse_x, mouse_y
WinGetPos, win_x, win_y, win_width, win_height

if ((win_width < win_min_width) | (win_height < win_min_height))
{
  goto, main
}

WinGetTitle, win_title

for index, value in win_exclude_titles
{
  if (win_title = value)
  {
    goto, main
  }
}

if (option_enabled[cbx_SequentialOrder_index])
{
  click_x := win_x + cbx_SequentialOrder_x
  click_y := win_y + cbx_SequentialOrder_y
  Click, %click_x% %click_y%
}

if (option_enabled[cbx_EndingsFirst_index])
{
  click_x := win_x + cbx_EndingsFirst_x
  click_y := win_y + cbx_EndingsFirst_y
  Click, %click_x% %click_y%
}

if (option_enabled[btn_OK_index])
{
  click_x := win_x + win_width - btn_OK_rx
  click_y := win_y + win_height - btn_OK_by
  Click, %click_x% %click_y%
}

WinWaitNotActive, ahk_class %win_class%

if (option_enabled[mouse_Restore_index])
{
  MouseMove, %mouse_x%, %mouse_y%
}

goto, main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu_main:
Menu, Tray, DeleteAll

menu_pos := 0

if (app_menu_info_separator_before)
{
  Menu, Tray, Add
  menu_pos := menu_pos + 1
}

menu_tip := ""
delimiter := ""

for index, value in app_info_text
{
  Menu, Tray, Add, %value%, menu_item_nop
  menu_pos := menu_pos + 1

  Menu, Tray, Disable, %menu_pos%&

  menu_tip := menu_tip . delimiter . value
  delimiter := "`r`n"
}

Menu, Tray, Tip, %menu_tip%

if (app_menu_info_separator_after)
{
  Menu, Tray, Add
  menu_pos := menu_pos + 1
}

menu_pos_index_offset := menu_pos
BoundMenuItem := Func("menu_item").Bind()

for index, value in menu_text
{
  Menu, Tray, Add, %value%, % BoundMenuItem
  menu_pos := menu_pos + 1
;  pos := index + menu_pos_index_offset

  if (option_enabled[index])
  {
    Menu, Tray, Check, %menu_pos%&
  }
  else
  {
    Menu, Tray, Uncheck, %menu_pos%&
  }
}

return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu_item(ItemName, ItemPos, MenuName)
{
  index := ItemPos - menu_pos_index_offset
  option_enabled[index] := not option_enabled[index]
  value := option_enabled[index]
  gosub, menu_main
}

menu_item_nop:
return
