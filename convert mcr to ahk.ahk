;PLEASE READ
;the converter does not convert images
;This is because idfk how jitbit compiles images and how to convert them into a .png or .jpg(or other image formats)
;You will have to manually put the images and manage the ENDIFLABEL's before distributing


#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
FileSelectFile,filename
file := "Converted.ahk"

FileAppend,#include functions.ahk, %file%
FileAppend,SendMode Input, %file%
FileAppend,#SingleInstance force, %file%

for each, line in StrSplit(FileOpen(filename, "r").Read(), "`n", "`r")
{
	f_ = %A_Loopfield%
	group_ := StrSplit(line, " : ")
	c:= group_[1] ;command
	k:= group_[2] ;key/arguements 1
	a:=group_[3] ;arguements 2
	if(c == "Keyboard")
	{
			if(a == "KeyPress")
			{
				FileAppend,KeyPress(%k%)`n,%file%
			}
			if(a == "KeyUp")
			{
				FileAppend,Send`,`{%k% up}`n,%file%
			}
			if(a == "KeyDown")
			{
				FileAppend,Send`,`{%k% down}`n,%file%
			}
	}
	if(c == "DELAY")
	{
	FileAppend,Sleep`,` %k%`n,%file%
	}
	if(c == "Label")
	{
		FileAppend,%k%`n,%file%
	}
	if(c == "IF IMAGE")
	{
	FileAppend,ImageSearch`,` `,` `,` 0 `,` 0 `,` A_ScreenWIdth `,` A_ScreenHeight `,` image.png `nIf(ErrorLevel == 1){goto `,` ENDIFLABEL} `n,%file%
	}
	if(c == "COMMENT")
	{
	FileAppend,;%k%`n,%file%	
	}
	if(c == "REPEAT")
	{
		FileAppend,Loop`,` %k% {`n,%file%
	}
	if(c == "ENDREPEAT")
	{
	FileAppend,}`n,%file%
	}
	if(c == "ENDIF")
	{
	FileAppend,ENDIFLABEL:`n,%file%
	}
}
MsgBox, All done, You may close this now.
