#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetMouseDelay, -1
SetBatchLines, -1
SetKeyDelay, -1
#UseHook

setInitialVariables:
overlapLength := 250
boldHotkey = b
italicsHotkey = i
refreshHotkey = r
prepareHotkey = p
smartQuotesHotkey = p
linksHotkey = l
emDashHotkey = -
enDashHotkey = -
numListsHotkey = 3
bulletListsHotkey = 8
GLThotkey = t
allHotkeys := {}
hotkeyList := {}
updateHotkeys()
return

; Begin functions
;================

;### Save a Sublime file as quickly as possible, without breaking on slow machines

Save()
{
	Send ^s
	internalSleep := 0
	Loop
	{
		WinGetTitle, windowTitle, ahk_class PX_WINDOW_CLASS
		IfNotInString, windowTitle, •
		{
	break
		}
		Sleep,%internalSleep%
		internalSleep += 10
	}
}

;### Get path of current Sublime file

;String-manipulation-only functions run at sleepLength := 0 unless they fail; then they run again, slower.

getFilePath()
{
	global filePath
	internalSleep := 0
	Loop
	{
		WinGetTitle, windowTitle
		Sleep,%internalSleep%
		foundPos := RegExMatch(windowTitle, "\s(?=([^\\\.]*)$)")
		Sleep,%internalSleep%
		StringLen, windowLen, windowTitle
		Sleep,%internalSleep%
		toTrim := windowLen - foundPos + 1
		Sleep,%internalSleep%
		StringTrimRight, filePath, windowTitle, %toTrim% ; Get file path
		Sleep,%internalSleep%
		StringLen, pathLen, filePath
		if (pathLen > 0)
		{
	break
		}
		internalSleep += 10
	}
}

;### Check if any text is highlighted

checkZero()
{
	; We can't just do ^c and then StringLen the clipboard--if there's nothing highlighted, ^c will capture the entire text block. So we expand the highlighted text by one and check that length instead.
	global
	previousClipboard = %ClipboardAll%
	Copy()
	moveHighlight("right")
	StringLen, characters, Clipboard
	Copy()
	moveHighlight("left")
	StringLen, zeroTest, Clipboard
	Clipboard = %previousClipboard%
	if (zeroTest > 2) or if (zeroTest < 0) or if (characters = 1) or if (characters = 2) or if (characters = 3)
	{
		highlighted = yes
	}
	else
	{
		highlighted = no
	}
}

;### Copy as quickly as possible, without breaking on slow computers

Copy()
{
	global
	Clipboard :=
	Send ^c
	ClipWait
	checkKey("control")
	checkKey("c")
}

;### Get type of current Sublime file

getFileType(filePath)
{
	global fileType
	internalSleep := 0
	Loop
	{
		foundPos:= RegExMatch(filePath, "\.(?=([^\.]*)$)")
		Sleep,%internalSleep%
		StringTrimLeft, fileType, filePath, %foundPos% ; Get file type
		Sleep,%internalSleep%
		StringLen, typeLen, fileType
		Sleep,%internalSleep%
		if (typeLen > 0)
		{
	break
		}
		internalSleep += 10
	}
}

;### Get directory of current Sublime file

getDirectory(filePath)
{
	global directory
	internalSleep := 0
	Loop
	{
		foundPos:= RegExMatch(filePath, "\\[^\\]*$")
		Sleep,%internalSleep%
		StringTrimLeft, fullName, filePath, %foundPos% ; Get full name
		Sleep,%internalSleep%
		StringLen, fullNameLen, fullName
		Sleep,%internalSleep%
		fullNameLen := fullNameLen + 1 ; And name's length, plus 1 for the leading \
		Sleep,%internalSleep%
		StringTrimRight, directory, filePath, %fullNameLen% ; Trim it to leave the directory, so we can cd into it
		Sleep,%internalSleep%
		typeLen += 1
		Sleep,%internalSleep%
		StringTrimRight, fileName, fullName, %typeLen%
		Sleep,%internalSleep%
		StringLen, nameLen, fileName
		Sleep,%internalSleep%
		if (nameLen > 0)
		{
	break
		}
		internalSleep += 10
	}
}

;### Turn filePath into valid AHK variable

filePathAsVariable(ByRef filePath)
{
	filePath := RegExReplace(filePath, "[^\w\d]", "")
}

;### Open given filePath in Chrome

openInChrome(filePath)
{
	global
	Run chrome.exe "%filePath%"
	DetectHiddenText, On
	SetTitleMatchMode, Slow
	WinWait, ahk_class Chrome_WidgetWin_1
	; Return to Sublime *before* getting window name for #speed
	WinActivate ahk_class PX_WINDOW_CLASS
	Loop 
	{
		; Wait to get window name until the correct name has arrived
		WinGetTitle, windowName, ahk_class Chrome_WidgetWin_1
		; Pt. 1: is there text in the window name?
		IfInString, windowName, Chrome
		{
			; Pt. 2: placeholder name is "Untitled - Google Chrome", so wait for that to be replaced w/ real name
			IfNotInString, windowName, Untitled -
			{
				WinGetTitle, windowName, ahk_class Chrome_WidgetWin_1
	break
			}
		}
	}
}

;### cd into a given filePath's directory in the Windows command line

openInCommandLine(directory)
{
	; Cygwin support is on its way!
	IfWinExist, C:\Windows\system32\cmd.exe ; Specific name here, to distinguish Windows command line from Git/Bitbucket, etc.
	{
		WinActivate C:\Windows\system32\cmd.exe
	}
	else IfWinExist, C:\Windows\system64\cmd.exe
	{
		WinActivate C:\Windows\system64\cmd.exe
	}
	else
	{
		Run cmd.exe
	}
	WinWaitActive
	Send cd %directory%
	Send {Enter}
}

;### Check if a given special character exists in the current doc

checkIfPresent(character)
{
	global
	toReplace = no
	IfInString, fileContents, %character%
	{
		toReplace = yes
	}
}

;### For a given feature, check if off; return " Checked" into GUI if not

checkEnabled(feature, status)
{
	if (%status% != 0)
	{
		%feature%Status := " Checked"
	}
	else
	{
		%feature%Status :=
	}
	return %featureStatus%
}

;### Make sure a key isn't still depressed

checkKey(key)
{
	increasing := 0
	if (key = "control")
	{
		send = ^
		keyState = %key%
	}
	else
	{
		send = {%key% up}
		StringUpper, keyState, key
	}
	Loop
	{
		GetKeyState, state, %keyState%
		if state = D
		{
			Send %send%
			Sleep,%increasing%	
			increasing += 10
		}
		else
		{
	break
		}
	}
}

;### Average out runtime of a given hotkey, for testing

speedCheck(toggle)
{
global
	if (toggle = "start")
	{
		i += 1
		startTime = %A_Sec%.%A_Msec%
		startMin = %A_Min%
		startSec = %A_Sec%
	}
	else if (toggle = "finish")
	{
		endTime = %A_Sec%.%A_Msec%
		endMin = %A_Min%
		endSec = %A_Sec%
		if (startMin != endMin)
		{
			MsgBox Minute ticked over: redo test!
		}
		runTime := endTime - startTime
		if (totalRunTime > 0)
		{
			totalRunTime := runTime + totalRunTime
		}
		else
		{
			totalRunTime := runTime
		}
		Tooltip %runTime%
		if (i >= 20)
		{
			Tooltip
			avgRunTime := totalRunTime / i
			Clipboard = %avgRunTime%
			MsgBox Average runtime: %totalRunTime% sec divided by %i% runs = %avgRunTime% sec per run.`n`n(Value copied to clipboard.)`n`nRestart the script to clear the test.
		}
	}
}

;### Expand highlighted text by one character

moveHighlight(direction)
{
	Send {shift down}
	Sleep,0
	Send {%direction%}
	Sleep,0
	Send {shift up}
}

;### Start a list of a given type

startList(listType)
{
	Send <%listType%>
	Send {Enter}
	Send ^]
	Send <li>
	global filePath
	list%filePath% = true
	return list%filePath%
}

;### Close a list of a given type

endList(listType)
{
	Send <li>
	Send {left 3}
	Send /
	Send {right 3}
	Send {Enter}
	Send ^[
	Send <%listType%>
	Send {left 3}
	Send /
	Send {right 3}
	global filePath
	list%filePath% = false
	return list%filePath%
}

;### Close a tag of a given type

closeTag(tagType)
{
	global
	Send <%tagType%>
	Sleep,0
	StringLen, tagLen, tagType
	tagLen := tagLen + 1
	Send {left %tagLen%}
	Sleep,0
	Send /
	Sleep,0
	if (highlighted = "yes")
	{
		Send {right %tagLen%}
	}
	else
	{
		Send {left 2}
	}
}

;### Check if regex enabled; turn it on and off as needed

toggleRegex(state = "")
{
	global
	if (state = "on")
	{
		Send ^{Home}
		Sleep,50
		Send ^f
		Sleep,50
		Send .
		Sleep,50
		Send {Enter}
		Sleep,50
		Send {Esc}
		Sleep,50
		previousClipboard = %ClipboardAll%
		Sleep,50
		Copy()
		Sleep,50
		Results = %Clipboard%
		Sleep,50
		if (Results = .)
		{
			toggleRegex()
			regexEnabled = false ; Status before, that is
		}
		else
		{
			regexEnabled = true
		}
	}
	else if (state = "off")
	{
		if (regexEnabled = "false")
		{
			toggleRegex()
		}
	}
	else if (state = "")
	{
		Send ^h
		Send {BS}
		Sleep,100
		Send {alt down}
		Sleep,100
		Send r
		Sleep,100
		Send {alt up}
		Sleep,100
		Send {Esc}
	}
}

;### Find and replace a given pair of words

Replace(find, replace, toReplace, internalSleep)
{
	global
	if (toReplace = "yes")
	{
		Send ^h
		Send %find%
		Sleep,%internalSleep%
		Send {tab}
		Send ^a ; highlight existing word
		Send %replace%
		Send ^!{Enter}
	}
}

;### Add a hotkey to the allHotkeys array

defineHotkey(action, toggle, fullTrigger, prevFullTrigger)
{
	global
	current := {}
	current.action := action
	current.toggle := toggle
	current.fullTrigger := fullTrigger
	current.prevFullTrigger := prevFullTrigger
	hotkeyList[current.action] := current
	allHotkeys.hotkey := hotkeyList
}

;### Turn hotkeys on and off

updateHotkeys()
{
	global
	; Put all the hotkeys, and their component variables/values, in one array
	defineHotkey("Bold", boldToggle, "^"boldHotkey, "^"prevBoldHotkey)
	defineHotkey("Italics", italicsToggle, "^"italicsHotkey, "^"prevItalicsHotkey)
	defineHotkey("Refresh", refreshToggle, "^"refreshHotkey, "^"prevRefreshHotkey)
	defineHotkey("Prepare", prepareToggle, "^"prepareHotkey, "^"prevPrepareHotkey)
	defineHotkey("smartQuotes", prepareToggle, "^+"smartQuotesHotkey, "^+"prevSmartQuotesHotkey)
	defineHotkey("Links", linksToggle, "^"linksHotkey, "^"prevLinksHotkey)
	defineHotkey("emDashes", dashesToggle, "^"emDashHotkey, "^"prevEmDashHotkey)
	defineHotkey("enDashes", dashesToggle, "^+"enDashHotkey, "^+"prevEnDashHotkey)
	defineHotkey("bulletLists", listsToggle, "^"bulletListsHotkey, "^"prevBulletListsHotkey)
	defineHotkey("numberedLists", listsToggle, "^"numListsHotkey, "^"prevNumListsHotkey)
	defineHotkey("GLTbuilder", GLTtoggle, "^+"GLThotkey, "^+"prevGLThotkey)
	; Loop through the array, turning the right hotkeys on
	for index, hotkey in allHotkeys
	{
	 	; Turns out we need to turn them all off at once, not off and on in pairs
	 	/*
	 	for index, element in hotkey
	 	{
		 	How to check if hotkey input is acceptable?
	 	}
	 	*/
	 	for index, element in hotkey
	 	{
	 		Hotkey, % element.prevFullTrigger, % element.action, Off
	 	}
	 	for index, element in hotkey
	 	{
	 		if (element.toggle != 0)
	 		{
		 		Hotkey, % element.fullTrigger, % element.action, On
	 		}
	 	}
	}
}

; End functions
;==============

; Begin global hotkeys
;=====================

;### Display cheat sheet / console of all the hotkeys

^+h::
Link =
IfWinExist, ahk_class AutoHotkeyGUI
{
	WinClose, ahk_class AutoHotkeyGUI
}
;Set the previous links, to turn them off
prevLinksHotkey = %linksHotkey%
prevBoldHotkey = %boldHotkey%
prevItalicsHotkey = %italicsHotkey%
prevRefreshHotkey = %refreshHotkey%
prevPrepareHotkey =%prepareHotkey%
prevSmartQuotesHotkey = %smartQuotesHotkey%
prevBulletListsHotkey = %bulletListsHotkey%
prevNumListsHotkey = %numListsHotkey%
prevGLThotkey = %GLThotkey%
prevEmDashHotkey = %emDashHotkey%
prevEnDashHotkey = %enDashHotkey%
; Call functions that check if a given feature is enabled and, if so, return " Checked" into the GUI
checkEnabled("linksToggle", linksToggle)
checkEnabled("boldToggle", boldToggle)
checkEnabled("italicsToggle", italicsToggle)
checkEnabled("refreshToggle", refreshToggle)
checkEnabled("prepareToggle", prepareToggle)
checkEnabled("listsToggle", listsToggle)
checkEnabled("GLTtoggle", GLTtoggle)
checkEnabled("twoKeysToggle", twoKeysToggle)
checkEnabled("dashesToggle", dashesToggle)
Gui, font, s15, Verdana
Gui, Add, Text, x40, SUBLIME-ONLY HOTKEYS
Gui, font, s12, Verdana
Gui, font, W700,,
Gui, Add, CheckBox, x10 vlinksToggle%linksToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vlinksHotkey, %linksHotkey%
Gui, Add, Text, X+5 Y+-22, for hyperlinks: hyperlink highlighted text, or toggle hyperlinks on and off
Gui, font, W700,,
Gui, Add, CheckBox, x10 vboldToggle%boldToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vboldHotkey, %boldHotkey%
Gui, Add, Text, X+5 Y+-22, for bold: bold selected text, or toggle bold on and off
Gui, font, W700,,
Gui, Add, CheckBox, x10 vitalicsToggle%italicsToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vitalicsHotkey, %italicsHotkey%
Gui, Add, Text, X+5 Y+-22, for italics: italicize selected text, or toggle italics on and off
Gui, font, W700,,
Gui, Add, CheckBox, x10 vrefreshToggle%refreshToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vrefreshHotkey, %refreshHotkey%
Gui, Add, Text, X+5 Y+-22, for refresh
Gui, font, W700,,
Gui, Add, CheckBox, x10 vprepareToggle%prepareToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vprepareHotkey, %prepareHotkey%
Gui, Add, Text, X+5 Y+-22, to replace special characters,
Gui, font, W700,,
Gui, Add, Text, X+5, control shift
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 vsmartQuotesHotkey, %smartQuotesHotkey%
Gui, Add, Text, X+5 Y+-22, to paste in smart quotes
Gui, font, W700,,
Gui, Add, CheckBox, x10 vlistsToggle%listsToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vnumListsHotkey, %numListsHotkey%
Gui, Add, Text, X+5 Y+-22, and        
Gui, font, W700,,
Gui, Add, Text, X+5, control
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 vbulletListsHotkey, %bulletListsHotkey%
Gui, Add, Text, X+5 Y+-22, for fast lists
Gui, font, s15, Verdana
Gui, Add, Text, x40, GLOBAL HOTKEYS
Gui, font, s12, Verdana
Gui, font, W700,,
Gui, Add, CheckBox, x10 vGLTtoggle%GLTtoggleStatus%, Control shift
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vGLThotkey, %GLThotkey%
Gui, Add, Text, X+5 Y+-22, for GLT builder
Gui, Add, CheckBox, x10 vtwoKeysToggle%twoKeysToggleStatus%, Two-key smart quotes: hold down 
Gui, font, W700,,
Gui, Add, Text, X+0, l and d
Gui, font, W100,,
Gui, Add, Text, X+5, for “, 
Gui, font, W700,,
Gui, Add, Text, X+5,r and d
Gui, font, W100,,
Gui, Add, Text, X+5, for ”, 
Gui, font, W700,,
Gui, Add, Text, X+5,l and s
Gui, font, W100,,
Gui, Add, Text, X+5, for ‘, 
Gui, font, W700,,
Gui, Add, Text, X+5,r and s
Gui, font, W100,,
Gui, Add, Text, X+5, for ’, and 
Gui, font, W700,,
Gui, Add, Text, X30 Y+5,t and b
Gui, font, W100,,
Gui, Add, Text, X+5, for target="_blank", plus (Sublime-only) 
Gui, font, W700,,
Gui, Add, Text, X+5,n and b
Gui, font, W100,,
Gui, Add, Text, X+5, to send a nonbreaking space and 
Gui, font, W700,,
Gui, Add, Text, X30 Y+5,c and d
Gui, font, W100,,
Gui, Add, Text, X+5, to open the command line
Gui, Add, Text, X10, Adjust how long the two keys should be required to overlap, in milliseconds`n(100–400 recommended):
Gui, Add, Edit, w45 voverlapLength, %overlapLength%
Gui, font, W700,,
Gui, Add, CheckBox, x10 vdashesToggle%dashesToggleStatus%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vemDashHotkey, %emDashHotkey%
Gui, Add, Text, X+5 Y+-22, for em dash,  
Gui, font, W700,,
Gui, Add, Text, X+5, control shift
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 venDashHotkey, %enDashHotkey%
Gui, Add, Text, X+5 Y+-22, for en dash
Gui, Add, CheckBox, x10 vExit, Or close the entire script (!)
Gui, Add, Button, w100 default xm, Legit
Gui, Show, w800 h575, SublimeScript Help and Customization
return
ButtonLegit:
2h:GuiClose:
GuiEscape:
Gui, Submit
Gui Destroy
if (Exit = 1)
{
	MsgBox, 4,, Are you sure you want to turn SublimeScript off?
	IfMsgBox Yes
	{
		Exitapp
	}
}
updateHotkeys()
return

;### Smart quotes

~r & ~d::
if (twoKeysToggle != 0)
{
	sleep,%overlapLength%
	GetKeyState, state, D
	If state = D
	{
		Send {BS 2}
		IfWinActive, ahk_class PX_WINDOW_CLASS
		{
			Send &rdquo;
		}
		else
		{
			Send ”
		}
	}
}
return

~r & ~s::
if (twoKeysToggle != 0)
{
	sleep,%overlapLength%
	GetKeyState, state, S
	If state = D
	{
		Send {BS 2}
		IfWinActive, ahk_class PX_WINDOW_CLASS
		{
			Send &rsquo;
		}
		else
		{
			Send ’
		}
	}
}
return

~l & ~d::
if (twoKeysToggle != 0)
{
	sleep,%overlapLength%
	GetKeyState, state, D
	If state = D
	{
		Send {BS 2}
		IfWinActive, ahk_class PX_WINDOW_CLASS
		{
			Send &ldquo;
		}
		else
		{
			Send “
		}
	}
}
return

~l & ~s::
if (twoKeysToggle != 0)
{
	Sleep,%overlapLength%
	GetKeyState, state, S
	If state = D
		{
		Send {BS 2}
		IfWinActive, ahk_class PX_WINDOW_CLASS
		{
			Send &lsquo;
		}
		else
		{
			Send ‘
		}
	}
}
return

~t & ~b::
if (twoKeysToggle != 0)
{
	sleep,%overlapLength%
	GetKeyState, state, B
	If state = D
	{
		Send {BS 2}
		Send {space}
		Send target="_blank"
	}
}
return

;### GLT builder

GLTbuilder:
Link =
IfWinExist, ahk_class AutoHotkeyGUI
{
	WinClose, ahk_class AutoHotkeyGUI
}
Gui, font, s12, Verdana
/*
previousClipboard = %Clipboard%
inChrome = no
IfWinActive ahk_class Chrome_WidgetWin_1
{
	Send {f6}
	Sleep,250
	Send ^a
	Sleep,10
	Copy()
	;Send {tab}
	currentURL = %Clipboard%
	Clipboard = %previousClipboard%
	inChrome = yes
}
*/
; Set indicator text for entry fields
Gui, Add, Text, w250, Target URL:`n(leave blank if you want)
Gui, Add, Text,, Source:
Gui, Add, Text,, Medium:
Gui, Add, Text,, Content:
Gui, Add, Text,, Campaign:
; Add entry fields
Gui, Add, Edit, vLink ym ; ym starts new column
Gui, Add, Edit, vSource
Gui, Add, Edit, vMedium
Gui, Add, Edit, vContent
Gui, Add, Edit, vCampaign
Gui, Add, Button, default, Create
Gui, Show,, GLT Builder
/*
if (inChrome = "yes")
{
	Send %currentURL%
	Send {Tab}
}
*/
return  ; Script idle until user does something.
GuiClose:
ButtonCreate:
Gui, Submit  ; Save user input
Gui Destroy ; So we can do it again
; Check if any field empty
StringLen, sourceLength, Source
StringLen, mediumLength, Medium
StringLen, contentLength, Content
StringLen, campaignLength, Campaign
GLT = ?
if (sourceLength > 0)
{
	GLT = %GLT%utm_source=%Source%&
}
if (mediumLength > 0)
{
	GLT = %GLT%utm_medium=%medium%&
}
if (contentLength > 0)
{
	GLT = %GLT%utm_content=%content%&
}
if (campaignLength > 0)
{
	GLT = %GLT%utm_campaign=%campaign%
}
Gui Destroy ; So we can do it again
StringLower GLT, GLT ; Eliminate capitalized GLT elements
Link = %Link%%GLT%
; If there's a & or ? at the end, remove it
foundPos:= RegExMatch(Link, "(&|\?)$")
if (foundPos != 0)
{
	StringTrimRight, Link, Link, 1
}
StringLen, linkLen, Link
if (linkLen > 1)
{
	Clipboard = %Link%
	MsgBox Added to clipboard:`n`n%Clipboard%
}
return

; ### Dictionary searches

#d::
InputBox, search, What word would you like to look up?
StringLen, searchLen, search
if (searchLen > 0)
{
	Run chrome.exe "http://www.merriam-webster.com/dictionary/%search%"
}
return

; Begin Sublime-only hotkeys
;===========================

~c & ~d::
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	if (twoKeysToggle != 0)
	{
		sleep,%overlapLength%
		GetKeyState, state, D
		if state = D ; = {d} is down
		{
			Send {BS 2}
			getFilePath()
			IfNotExist, %filePath%
			{
				MsgBox Looks like this file has never been saved before. Save it and then try again!
				return
			}
			getFileType(filePath)
			getDirectory(filePath)
			openInCommandLine(directory)
		}
	}
}
return

~n & ~b::
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	if (twoKeysToggle != 0)
	{
		sleep,%overlapLength%
		GetKeyState, state, B
		If state = D
		{
			Send {BS 2}
			Send &nbsp;
		}
	}
}
return

;### Prepare document for the web: find and replace special characters

Prepare:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	IfNotExist, %filePath%
	{
		MsgBox Looks like this file has never been saved before. Save it and then check again! `n`n(No need to save *every* time you check for special characters—we just need an initial file name to work with.)
		return
	}
	FileEncoding, UTF-8 ; So we can search for Spanish characters
	Save()
	FileRead, fileContents, %filePath% ; Now that we have file path, read that sucker so we can search for special characters without visible ^f
	charactersArray := Object()
	charactersArray.insert("á", "&aacute;")
	charactersArray.insert("é", "&eacute;")
	charactersArray.insert("í", "&iacute;")
	charactersArray.insert("ó", "&oacute;")
	charactersArray.insert("ú", "&uacute;")
	charactersArray.insert("ñ", "&ntilde;")
	charactersArray.insert("ü", "&uuml;")
	charactersArray.insert("¿", "&iquest;")
	charactersArray.insert("¡", "&iexcl;")
	charactersArray.insert("’", "&rsquo;")
	charactersArray.insert("‘", "&lsquo;")
	charactersArray.insert("”", "&rdquo;")
	charactersArray.insert("“", "&ldquo;")
	charactersArray.insert("—", "&mdash;")
	charactersArray.insert("–", "&ndash;")
	charactersArray.insert("©", "&copy;")
	charactersArray.insert("®", "&reg;")
	charactersArray.insert("™", "&trade;")
	charactersArray.insert("& ", "&amp; ") ; We can't just search for "&", because that would replace, say, &ndash; with &amp;ndash;
	charactersArray.insert("&&", "&amp;&") ; For cases like &&nbsp;[word]
	charactersArray.insert(" . . .", "&nbsp;.&nbsp;.&nbsp;.")
	; Still need to add case-sensitive searches. Easy to toggle case-sensitivity; how to check its state?
	For key, value in charactersArray
	{
	    checkIfPresent(key)
	    Replace(key, value, toReplace, "0")
	}
	checkKey("control")
	checkKey("%prepareHotkey%")
	Tooltip Success: you’re ready for the web!
	Sleep,2000
	Tooltip ; Remove the tooltip
}
else
{
	Send ^%prepareHotkey%
}
return

;### Ugly but powerful: swap in smart quotes and nonbreaking spaces

smartQuotes:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	;SoundGet, masterVolume
	;SoundSet, mute
	toggleRegex("on")
	smartQuotesArray := Object()
	smartQuotesArray.insert("(?<=[>\s\-;])(""|(&quot;))(?=[{^}\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|</span|<br|<ol))", "&ldquo;")
	smartQuotesArray.insert("(?<=[\w\d\.\{!},:?'&rsquo;>])(""|(&quot;))(?=((&mdash;|&ndash;)?,?(\s)?(\s|:|""|&rdquo;|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\{!}|</p>)[\w\d]*\s*(\s|""|'|-|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|\w|<|-|&|\.|\?|\s*\w*&)", "&rdquo;")
	smartQuotesArray.insert("(?<=[>\s\-;""])'(?=[{^}\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|<br|</span))", "&lsquo;") ; legit
	smartQuotesArray.insert("(?<=[\w\d\.\{!},?:>])'(?=((&mdash;|&ndash;|\w*)?,?(\s)?(\s|:|""|&rdquo;|\w|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\{!}|</p>)[\w\d]*\s*(\s|""|'|-|&rdquo;|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|""|<|-|&|\.|\?|\s*\w*&)", "&rsquo;")
	smartQuotesArray.insert("\s(?=(\$\d*\.?(\d*)?|w*)\b(\$\d*\.?\d*|\w*)(\.*|{!}*|\?*|:|\s*|&rdquo;|&rsquo;|\w|.)?(&rdquo;|&rsquo;)?(\.*|{!}*|\?*|\s*|&rdquo;|&rsquo;|:|\w)?(\s*)?(</\w*>)?(</p|</li|</h1|</h2|</h3|</h4|<br))", "&nbsp;")
	For key, value in smartQuotesArray
	{
		IfWinNotActive ahk_class PX_WINDOW_CLASS
		{
			Msgbox You’ve left Sublime, so we’re stopping the script before it messes up your other work. When you return to Sublime, you’ll want to uncheck .* ( = regular expressions) in the search bar (lower left).
			return
		}
		Replace(key, value, "yes", "1000")
	}
	toggleRegex("off")
	Clipboard = %previousClipboard%
	checkKey("control")
	checkKey("%smartQuotesHotkey%")
	;Sleep,500
	;SoundSet, %masterVolume%
}
else
{
	Send ^+%smartQuotesHotkey%
}
Return

/* 
Base regexes (without escape / raw-input characters), for comparison
	&ldquo; = (?<=[>\s\-;])("|(&quot;))(?=[^\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|</span|<br|<ol))
	&rdquo; = (?<=[\w\d\.\!,:?'&rsquo;>])("|(&quot;))(?=((&mdash;|&ndash;)?,?(\s)?(\s|:|"|&rdquo;|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\!|</p>)[\w\d]*\s*(\s|"|'|-|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|\w|<|-|&|\.|\?|\s*\w*&)
	&lsquo; = (?<=[>\s\-;"])'(?=[^\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|<br|</span))
	&rsquo; = (?<=[\w\d\.\!,?:>])'(?=((&mdash;|&ndash;|\w*)?,?(\s)?(\s|:|"|&rdquo;|\w|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\!|</p>)[\w\d]*\s*(\s|"|'|-|&rdquo;|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|"|<|-|&|\.|\?|\s*\w*&)
	&nbsp; = \s(?=(\$\d*\.?(\d*)?|w*)\b(\$\d*\.?\d*|\w*)(\.*|!*|\?*|:|\s*|&rdquo;|&rsquo;|\w|.)?(&rdquo;|&rsquo;)?(\.*|!*|\?*|\s*|&rdquo;|&rsquo;|:|\w)?(\s*)?(</\w*>)?(</p|</li|</h1|</h2|</h3|</h4|<br))

*/

;### See your changes: open document or refresh it

Refresh:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	IfNotExist, %filePath%
	{
		MsgBox Looks like this file has never been saved before. This first save you’ll have to do on your own!`n`n(After that, we’ll save automatically whenever you refresh the file.)
		return
	}
	Save()
	getFileType(filePath)
	if (fileType = "html")
	{
		if (filePath != prevFilePath)
		{
			; Since we're in a new Sublime doc, just open (not reload) every time
			openInChrome(filePath)
		}
		else ; Behavior if Sublime file isn't new
		{
			IfWinExist, %windowName%
			{
				; Is that previously observed window open anywhere? If so, hop over to it, refresh it, hop back.
				WinActivate %windowName%
				WinWait ahk_class Chrome_WidgetWin_1
				Send {f5}
				WinActivate ahk_class PX_WINDOW_CLASS
			}
			else
			{
				; So it's the same Sublime doc, but the Chrome version isn't open--just open it anew.
				openInChrome(filePath)
			}
		}
	}
	else if (fileType = "ahk")
	{
		; If it takes arguments, it needs to be run from the command line:
		FileRead, fileContents, %filePath%
		IfInString, fileContents, `%1`% 
		{
			getDirectory(filePath)
			getFileType(filePath)
			openInCommandLine(directory)
			Send %fullName%
		}
		else
		{
			Run %filePath%
		}
	}
	else if (fileType = "css")
	{
		IfWinExist, ahk_class Chrome_WidgetWin_1
		{
			; Not nearly as smart as the HTML version, but still useful
			WinActivate ahk_class Chrome_WidgetWin_1
			WinWait ahk_class Chrome_WidgetWin_1
			Send {f5}
			WinActivate ahk_class PX_WINDOW_CLASS
		}
	}
	else if (fileType = "bat")
	{
		getDirectory(filePath)
		openInCommandLine(directory)
		Send %fullName%
	}
	/*
	else if (fileType = "scss")
	{
	; Simply open command line?
	; The syntax for a new .scss watch: sass --watch %fileName%.scss:%fileName%.css
	}
	*/
	prevFilePath = %filePath%
	checkKey("control")
	checkKey("refreshHotkey")
}
else
{
	Send ^%refreshHotkey%
}
return

;### Bold selected text, or toggle bold on and off
/*
;### Not public-facing: just a way to automate testing

^q::
Loop
{
	GoSub, autoTester
	Sleep,500
	Send {right} ; Or multiple right with ^l
	Sleep,500
}
autoTester:
	Goto Bold ; Or whichever hotkey we're speed-checking
return
*/
;### End test automater

Bold:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	filePathAsVariable(filePath)
	checkZero()
	if (highlighted = "yes")
	{
		Send {left}
		Send <strong>
		Send {right %characters%}
		closeTag("strong")
	} 
	else
	{
		Send <strong>
		closeTag("strong")
	}
	checkKey("control")
	checkKey("%boldHotkey%")
}
else
{
	Send ^%boldHotkey%
}
return

;### Italics

Italics:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	filePathAsVariable(filePath)
	checkZero()
	if (highlighted = "yes")
	{
		Send {left}
		Send <em>
		Send {right %characters%}
		closeTag("em")
	} 

	else
	{
		Send <em>
		closeTag("em")
	}
	checkKey("control")
	checkKey("%italicsHotkey%")
}
else
{
	Send ^%italicsHotkey%
}
return

;### Hyperlinks

Links:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	filePathAsVariable(filePath)
	checkZero()
	if (highlighted = "yes")
	{
		Send {right}
		closeTag("a")
		characters := characters + 4
		Send {left %characters%}
		Send <a href="">
		Send {left 2}
	} 
	else
	{
		closeTag("a")
		Send <a href="">
		Send {left 2}
	}
	checkKey("control")
	checkKey("%linksHotkey%")
}
else
{
	Send ^%linksHotkey%
}
return

;### Toggle bulleted lists

bulletLists:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	filePathAsVariable(filePath)
	if (list%filePath% != "true")
	{
		startList("ul")
	} else if (list%filePath% = "true")
	{
		endList("ul")
	}
	checkKey("control")
	checkKey("bulletListsHotkey")
}
else
{
	Send ^%bulletListsHotkey%
}
return

;### Toggle numbered lists

numberedLists:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	filePathAsVariable(filePath)
	if (list%filePath% != "true")
	{
		startList("ol")
	} else if (list%filePath% = "true")
	{
		endList("ol")
	}
	checkKey(%control%)
	checkKey("%numListsHotkey%")
}
else
{
	Send ^%numListsHotkey%
}
return

;### If we're in the middle of a list, enter = new <li>

Enter::
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	getFilePath()
	filePathAsVariable(filePath)
	if (list%filePath% = "true")
	{
		Send <li>
		Send {left 3}
		Send /
		Send {right 3}
		Send {Enter}
		Send <li>
	}
	else
	{
		Send {Enter}
	}
}
else
{
	Send {Enter}
}
return

;### Em and en dashes

emDashes:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	Send &mdash;
}
else
{
	Send —
}
return

enDashes:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	Send &ndash;
}
else
{
	Send –
}
return