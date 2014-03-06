#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetMouseDelay, -1
SetBatchLines, -1
SetKeyDelay, -1
#UseHook

; BUSINESS LOGIC
;===============

setInitialValues:
overlapLength := 250 ; Set how long the smart-quote hotkeys need to overlap before firing
refreshHotkey := new Hotkey("Refresh", "^", "r") ; First argument sets the action; second and third, the trigger
prepareHotkey := new Hotkey("Prepare", "^", "q")
smartQuotesHotkey := new Hotkey("smartQuotes", "^+", "q")
linksHotkey := new Hotkey("Links", "^", "l")
boldHotkey := new Hotkey("Bold", "^", "b")
italicsHotkey := new Hotkey("Italics", "^", "i")
numberedListsHotkey := new Hotkey("numberedLists", "^", "3")
bulletListsHotkey := new Hotkey("bulletLists", "^", "8")
GLThotkey := new Hotkey("GLT", "^+", "t")
emDashesHotkey := new Hotkey("emDashes", "^", "-")
enDashesHotkey := new Hotkey("enDashes", "^+", "-")
GUIhotkey := new Hotkey("GUI", "^+", "h")
hotkeysArray := [refreshHotkey, prepareHotkey, smartQuotesHotkey, linksHotkey, boldHotkey, italicsHotkey, numberedListsHotkey, bulletListsHotkey, GLThotkey, emDashesHotkey, enDashesHotkey, GUIhotkey] ; So we can loop through them all in activateHotkeys()
activateHotkeys()
return

;### Define the hotkey class

Class Hotkey 
{
	__new(action, prefix, key) ; From arguments passed in, set each hotkey's parameters
	{
		this.action := action, this.prefix := prefix, this.key := key
	}
	deactivatePrevious()
	{
		Hotkey, % this.prefix this.prevKey, % this.action, Off
	}
	activate()
	{
		if (this.toggle != 0)
		{
			Hotkey, % this.prefix this.key, % this.action, On
		}
		this.prevKey := this.key
	}
	sanitizeInput()
	{
		newKey := % this.key ; Since the object can't be manipulated as a true variable, we pass it through a variable...
		sanitizedKey := RegExReplace(newKey, "[^\w\d-]", "") ; Remove problem characters
		StringLen, keyLen, sanitizedKey
		StringTrimRight, sanitizedKey, sanitizedKey, (keyLen - 1) ; Trim input to just 1 character
		if (keyLen = 0)
		{
			sanitizedKey := this.prevKey ; Or reset empty field to previous value
		}
		this.key := sanitizedKey ;...and then take it back from the variable
	}
}

;### Fire up the key bindings!

activateHotkeys()
{
	global
	for index in hotkeysArray ; Turn all the previous hotkeys off (needs to be its own loop)
	{
		hotkeysArray[index].deactivatePrevious()
	}
	for index in hotkeysArray ; Turn the new hotkeys on
	{
		hotkeysArray[index].sanitizeInput()
		hotkeysArray[index].activate()
	}
}

;### Create GUI that lets users remap or turn off hotkeys

GUI:
Link := "" ; helps prevent conflict with GLT GUI
IfWinExist, ahk_class AutoHotkeyGUI
{
	WinClose, ahk_class AutoHotkeyGUI ; Again, to handle conflict with GLT GUI
}
; ### Call function that determines if a given feature is on or off; if on, returns " Checked" (not 1 or 0, the true toggle values) into GUI body, so the feature comes pre-checked
checkEnabled("refreshToggle")
checkEnabled("prepareToggle")
checkEnabled("linksToggle")
checkEnabled("boldToggle")
checkEnabled("italicsToggle")
checkEnabled("numberedListsToggle")
checkEnabled("GLTtoggle")
checkEnabled("twoKeysToggle")
checkEnabled("emDashesToggle")
Gui, font, s15, Verdana
Gui, Add, Text, x40, SUBLIME-ONLY HOTKEYS
Gui, font, s12, Verdana
;### Refresh
Gui, font, W700,,
Gui, Add, CheckBox, x10 vrefreshToggle%refreshToggleVerbose%, Control ; E.g., unless the hotkey is turned off, variable field fills in as "vrefreshToggle Checked"
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempRefreshHotkey, % refreshHotkey.key ; AHK doesn't permit the directed manipulation of objects as variables, so we're passing both .key and .toggle into placeholders--here, tempRefreshHotkey
Gui, Add, Text, X+5 Y+-22, for save and refresh
;### Prepare
Gui, font, W700,,
Gui, Add, CheckBox, x10 vprepareToggle%prepareToggleVerbose%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempPrepareHotkey, % prepareHotkey.key
Gui, Add, Text, X+5 Y+-22, to replace special characters,
;### Smart quotes
Gui, font, W700,,
Gui, Add, Text, X+5, control shift
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 vtempSmartQuotesHotkey, % smartQuotesHotkey.key
Gui, Add, Text, X+5 Y+-22, (experimental) 
Gui, Add, Text, x10 Y+5, to paste in smart quotes
;### Links
Gui, font, W700,,
Gui, Add, CheckBox, x10 vlinksToggle%linksToggleVerbose%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempLinksHotkey, % linksHotkey.key
Gui, Add, Text, X+5 Y+-22, for hyperlinks: hyperlink highlighted text, or toggle hyperlinks on and off
;### Bold
Gui, font, W700,,
Gui, Add, CheckBox, x10 vboldToggle%boldToggleVerbose%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempBoldHotkey, % boldHotkey.key
Gui, Add, Text, X+5 Y+-22, for bold: bold selected text, or toggle bold on and off
;### Italics
Gui, font, W700,,
Gui, Add, CheckBox, x10 vitalicsToggle%italicsToggleVerbose%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempItalicsHotkey, % italicsHotkey.key
Gui, Add, Text, X+5 Y+-22, for italics: italicize selected text, or toggle italics on and off
;### Numbered lists
Gui, font, W700,,
Gui, Add, CheckBox, x10 vnumberedListsToggle%numberedListsToggleVerbose%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempnumberedListsHotkey, % numberedListsHotkey.key
Gui, Add, Text, X+5 Y+-22, and
;### Bullet lists
Gui, font, W700,,
Gui, Add, Text, X+5, control
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 vtempBulletListsHotkey, % bulletListsHotkey.key
Gui, Add, Text, X+5 Y+-22, for fast lists
Gui, font, s15, Verdana
Gui, Add, Text, x40, GLOBAL HOTKEYS
Gui, font, s12, Verdana
;### GLT builder
Gui, font, W700,,
Gui, Add, CheckBox, x10 vGLTtoggle%GLTToggleVerbose%, Control shift
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempGLThotkey, % GLThotkey.key
Gui, Add, Text, X+5 Y+-22, for GLT builder
;### Em dashes
Gui, font, W700,,
Gui, Add, CheckBox, x10 vemDashesToggle%emDashesToggleVerbose%, Control
Gui, font, W100,,
Gui, Add, Edit, X+0 Y+-22 w22 vtempEmDashesHotkey, % emDashesHotkey.key
Gui, Add, Text, X+5 Y+-22, for em dash, 
;### En dashes 
Gui, font, W700,,
Gui, Add, Text, X+5, control shift
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 vtempEnDashesHotkey, % enDashesHotkey.key
Gui, Add, Text, X+5 Y+-22, for en dash
;### GUI
Gui, font, W700,,
Gui, Add, Text, X10, Control shift
Gui, font, W100,,
Gui, Add, Edit, X+5 Y+-22 w22 vtempGUIhotkey, % GUIhotkey.key
Gui, Add, Text, X+5 Y+-22, for the customization console
;### Two-key hotkeys: smart quotes, etc.
Gui, Add, CheckBox, x10 vtwoKeysToggle%twoKeysToggleVerbose%, Two-key smart quotes: hold down 
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
Gui, Add, Text, X+5, for ’, 
Gui, font, W700,,
Gui, Add, Text, X30 Y+5,t and b
Gui, font, W100,,
Gui, Add, Text, X+5, for target="_blank", and
Gui, font, W700,,
Gui, Add, Text, X+5,n and b
Gui, font, W100,,
Gui, Add, Text, X+5, for &&nbsp; (a nonbreaking space), plus 
Gui, Add, Text, X30 Y+5, (Sublime-only) 
Gui, font, W700,,
Gui, Add, Text, X+5,c and d
Gui, font, W100,,
Gui, Add, Text, X+5, to open the command line in the current directory
;### Overlap length
Gui, Add, Text, X30, Adjust how long the two trigger keys should be required to overlap, in milliseconds`n(100–400 recommended):
Gui, Add, Edit, w55 voverlapLength, %overlapLength%
;### Close script
Gui, Add, CheckBox, x10 vExit, Or close the entire script (!)
Gui, Add, Button, w100 default xm, Legit
Gui, Show, w800 h625, SublimeScript Help and Customization
return
ButtonLegit:
2h:GuiClose:
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
enDashesToggle := emDashesToggle ; Because these two share checkboxes with their predecessors
bulletListsToggle := numberedListsToggle
;  To get the new values back, we *could* just do "refreshHotkey.key := tempRefreshHotkey", "refreshHotkey.toggle := refreshToggle", etc., but that's long and boring, so...
for index in hotkeysArray
{
	currentAction := hotkeysArray[index].action ; e.g., "Bold"
	hotkeysArray[index].key := temp%currentAction%Hotkey ; Passes contents of tempBoldHotkey--say, "b"--back to boldHotkey.key
	hotkeysArray[index].toggle := %currentAction%Toggle
}
activateHotkeys() ; Loop through them all
checkkey(GUIhotkey.prefix) ; Make sure control and shift aren't being accidentally held down by some script glitch
return

; END BUSINESS LOGIC; BEGIN HOTKEY ACTIONS
;=========================================

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
		if (filePath != prevFilePath) ; It's a new Sublime file, so...
		{
			openInChrome(filePath) ; Just open (not reload) every time
		}
		else ; Sublime file isn't new
		{
			IfWinExist, %windowName% ; Is that previously observed window open anywhere? If so, refresh it
			{
				WinActivate %windowName%
				WinWait ahk_class Chrome_WidgetWin_1
				Send {f5}
				WinActivate ahk_class PX_WINDOW_CLASS
			}
			else ; It's the same Sublime doc, but the Chrome version isn't open--just open it anew.
			{
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
	else if (fileType = "bat")
	{
		getDirectory(filePath)
		openInCommandLine(directory)
		Send %fullName%
	}
	prevFilePath = %filePath%
}
else
{
	Send % refreshHotkey.prefix refreshHotkey.key
}
checkKey(refreshHotkey.prefix)
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
	FileRead, fileContents, %filePath% ; So we can read that sucker ahead of time, check without visible search box
	charactersArray := {}
	charactersIndex := 1
	addCharactersArray("á", "&aacute;")
	addCharactersArray("Á", "&Aacute;")
	addCharactersArray("é", "&eacute;")
	addCharactersArray("É", "&Eacute;")
	addCharactersArray("í", "&iacute;")
	addCharactersArray("Í", "&Iacute;")
	addCharactersArray("ó", "&oacute;")
	addCharactersArray("Ó", "&Oacute;")
	addCharactersArray("ú", "&uacute;")
	addCharactersArray("Ú", "&Uacute;")
	addCharactersArray("ñ", "&ntilde;")
	addCharactersArray("Ñ", "&Ntilde;")
	addCharactersArray("ü", "&uuml;")
	addCharactersArray("¿", "&iquest;")
	addCharactersArray("¡", "&iexcl;")
	addCharactersArray("’", "&rsquo;")
	addCharactersArray("‘", "&lsquo;")
	addCharactersArray("”", "&rdquo;")
	addCharactersArray("“", "&ldquo;")
	addCharactersArray("—", "&mdash;")
	addCharactersArray("–", "&ndash;")
	addCharactersArray("©", "&copy;")
	addCharactersArray("®", "&reg;")
	addCharactersArray("™", "&trade;")
	addCharactersArray("& ", "&amp; ") ; Can't just search for "&"; that would replace, say, &ndash; with &amp;ndash;
	addCharactersArray("&&", "&amp;&") ; For cases like &&nbsp;[word]
	addCharactersArray(" . . .", "&nbsp;.&nbsp;.&nbsp;.")
	for index in charactersArray
	{
	    checkIfPresent(charactersArray[index].find)
	    Replace(charactersArray[index].find, charactersArray[index].replace, toReplace, "0")
	}
	Tooltip Success: you’re ready for the web!
	Sleep,2000
	Tooltip ; Remove the tooltip
}
else
{
	Send % prepareHotkey.prefix prepareHotkey.key
}
checkKey(prepareHotkey.prefix)
return

;### Ugly but powerful: swap in smart quotes and nonbreaking spaces

smartQuotes:
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	toggleRegex("on")
	;### Put smart-quote regex pairs in an array
	smartQuotesArray := {}
	smartQuotesArray.insert("(?<=[>\s\-;])(""|(&quot;))(?=[{^}\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|</span|<br|<ol))", "&ldquo;")
	smartQuotesArray.insert("(?<=[\w\d\.\{!},:?'&rsquo;>])(""|(&quot;))(?=((&mdash;|&ndash;)?,?(\s)?(\s|:|""|&rdquo;|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\{!}|</p>)[\w\d]*\s*(\s|""|'|-|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|\w|<|-|&|\.|\?|\s*\w*&)", "&rdquo;")
	smartQuotesArray.insert("(?<=[>\s\-;""])'(?=[{^}\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|<br|</span))", "&lsquo;")
	smartQuotesArray.insert("(?<=[\w\d\.\{!},?:>])'(?=((&mdash;|&ndash;|\w*)?,?(\s)?(\s|:|""|&rdquo;|\w|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\{!}|</p>)[\w\d]*\s*(\s|""|'|-|&rdquo;|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|""|<|-|&|\.|\?|\s*\w*&)", "&rsquo;")
	smartQuotesArray.insert("\s(?=(\$\d*\.?(\d*)?|w*)\b(\$\d*\.?\d*|\w*)(\.*|{!}*|\?*|:|\s*|&rdquo;|&rsquo;|\w|.)?(&rdquo;|&rsquo;)?(\.*|{!}*|\?*|\s*|&rdquo;|&rsquo;|:|\w)?(\s*)?(</\w*>)?(</p|</li|</h1|</h2|</h3|</h4|<br))", "&nbsp;")
	for key, value in smartQuotesArray
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
}
else
{
	Send % smartQuotesHotkey.prefix smartQuotesHotkey.key
}
checkKey(smartQuotesHotkey.prefix)
Return

; Base regexes (without escape / raw-input characters), for comparison
; 	&ldquo; = (?<=[>\s\-;])("|(&quot;))(?=[^\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|</span|<br|<ol))
; 	&rdquo; = (?<=[\w\d\.\!,:?'&rsquo;>])("|(&quot;))(?=((&mdash;|&ndash;)?,?(\s)?(\s|:|"|&rdquo;|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\!|</p>)[\w\d]*\s*(\s|"|'|-|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|\w|<|-|&|\.|\?|\s*\w*&)
; 	&lsquo; = (?<=[>\s\-;"])'(?=[^\s>](\s|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|&nbsp;|</span>)*.*(\n)*(\t)*(</p|</h1|</h2|</h3|</h4|</li|<br|</span))
; 	&rsquo; = (?<=[\w\d\.\!,?:>])'(?=((&mdash;|&ndash;|\w*)?,?(\s)?(\s|:|"|&rdquo;|\w|</strong>|&nbsp;|</em>|</a>|</p>|</h1>|</h2>|</h3>|</h4>|</li>|</span>|\!|</p>)[\w\d]*\s*(\s|"|'|-|&rdquo;|&rsquo;|&ldquo;|&lsquo;|,|\.|<|</a>|&nbsp;|</em>|</strong>).*(\n)*(\t)*(</p>|</h1|</h2|</h3|</h4|</li|<br|</span|<ol|</td))|"|<|-|&|\.|\?|\s*\w*&)
; 	&nbsp; = \s(?=(\$\d*\.?(\d*)?|w*)\b(\$\d*\.?\d*|\w*)(\.*|!*|\?*|:|\s*|&rdquo;|&rsquo;|\w|.)?(&rdquo;|&rsquo;)?(\.*|!*|\?*|\s*|&rdquo;|&rsquo;|:|\w)?(\s*)?(</\w*>)?(</p|</li|</h1|</h2|</h3|</h4|<br))

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
}
else
{
	Send % linksHotkey.prefix linksHotkey.key
}
checkKey(linksHotkey.prefix)
return

;### Bold selected text, or toggle bold on and off

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
}
else
{
	Send % boldHotkey.prefix boldHotkey.key
}
checkKey(boldHotkey.prefix)
return

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
}
else
{
	Send % italicsHotkey.prefix italicsHotkey.key
}
checkKey(italicsHotkey.prefix)
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
}
else
{
	Send % numberedListsHotkey.prefix numberedListsHotkey.key
}
checkKey(numberedListsHotkey.prefix)
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
}
else
{
	Send % bulletListsHotkey.prefix bulletListsHotkey.key
}
checkkey(bulletListsHotkey.prefix)
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

;### GLT builder

GLT:
Link := ""
IfWinExist, ahk_class AutoHotkeyGUI
{
	WinClose, ahk_class AutoHotkeyGUI
}
Gui, font, s12, Verdana
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
foundPos:= RegExMatch(Link, "(&|\?)$") ; If there's a & or ? at the end, remove it
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
checkKey(GLThotkey.prefix)
return

;### Smart quotes, etc.

~r & ~d::
if (twoKeysToggle != 0)
{
	sleep,%overlapLength%
	GetKeyState, state, R
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
	GetKeyState, state, R
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
	GetKeyState, state, L
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
	GetKeyState, state, L
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
	GetKeyState, state, T
	If state = D
	{
		Send {BS 2}
		Send {space}
		Send target="_blank"
	}
}
return

~c & ~d::
IfWinActive, ahk_class PX_WINDOW_CLASS
{
	if (twoKeysToggle != 0)
	{
		sleep,%overlapLength%
		GetKeyState, state, C
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

; END HOTKEY ACTIONS; BEGIN COMPONENT FUNCTIONS
;==============================================

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

;### Copy as quickly as possible, without breaking on slow computers

Copy()
{
	global
	Clipboard :=
	Send ^c
	ClipWait
	checkKey("^")
}

;### Get path of current Sublime file
; (String-manipulation-only functions run at sleepLength := 0 unless they fail; then they run again, slower.)

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
	; Strange bug: WinGetTitle, var, ahk_class Chrome_WidgetWin_1 *not* working in some machines. Workaround:
	;WinWait, ahk_class Chrome_WidgetWin_1
	;WinActivate ahk_class PX_WINDOW_CLASS ; Return to Sublime *before* getting window name for #speed
	; ### Wait to get window name until the correct name has arrived
	Loop 
	{
		WinGetTitle, windowName, A ; Used to be Chrome_WidgetWin_1
		IfInString, windowName, Chrome
		{
			IfNotInString, windowName, Untitled - Google Chrome ; Used to be Chrome_WidgetWin_1
			{
				WinGetTitle, windowName, A
	break
			}
		}
	}
	WinActivate ahk_class PX_WINDOW_CLASS ; Temporarily moved to end
}

;### Check if any text is highlighted

checkZero()
{
	; We can't just do ^c and then StringLen the clipboard--if there's nothing highlighted, ^c will capture the text of the entire line. So we expand the highlighted text by one and check that length instead.
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

;### cd into a given filePath's directory in the Windows command line

openInCommandLine(directory)
{
	IfWinExist, C:\Windows\system32\cmd.exe ; Specific name here, to distinguish Windows command line from Git, etc.
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

;### Make sure a key isn't still depressed

checkKey(key)
{
	increasing := 0
	StringLen, keyLen, key
	if (keyLen > 1) ; If multiple characters in prefix, split into individual chars and check them recursively
	{
		StringSplit, keys, key,,
		Loop %keys0%
		{
			checkKey(keys%a_index%)
		}
	}
	if (key = "^")
	{
		keyName = control
	}
	else if (key = "+")
	{
		keyName = shift
	}
	Loop
	{
		GetKeyState, state, %keyName%
		if state = D
		{
			Send %key%
			Sleep,%increasing%	
			increasing += 10
		}
		else
		{
	break
		}
	}
}

;### For a given feature, check if off; return " Checked" into GUI if not

checkEnabled(feature)
{
	status = % %feature%
	if (%status% != 0)
	{
		%feature%Verbose := " Checked"
	}
	else
	{
		%feature%Verbose :=
	}
	return %featureVerbose%
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

;### Add a pair of characters to charactersArray

addCharactersArray(find, replace)
{
	global
	current := {}
	current.find := find
	current.replace := replace
	charactersArray[charactersIndex] := current
	charactersIndex += 1
}