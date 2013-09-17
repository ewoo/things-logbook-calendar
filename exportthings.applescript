-- ExportThings - for exporting Things database to the Desktop as Things Backup.txt
-- Dexter Ang - @thepoch on Twitter
-- Copyright (c) 2012, Dexter Ang
--
-- Somewhat based on "Export Things to text file (ver 1)" by John Wittig
-- and from reading the Things AppleScript Guide (rev 13).
--
-- With contributions by Rob de Jonge - @robdejonge on Twitter
--
-- Tested with Things 2.0.1 and OS X Mountain Lion
--
-- TODO:
-- - Get Repeating ToDos (currently no way via AppleScript).
-- - Make tags tab delimited by heirarchy.
-- - Export Areas. Maybe.
-- - For each exported ToDo, also include their tags and areas. Maybe.

-- ------------------------------------------------------------------------------
-- settings
-- ------------------------------------------------------------------------------

global theList, outputAppend, outputHeader, outputSectionHeaderPrefix, soundCompleted

-- configures which areas of Things should be included in output
-- options are {"Inbox", "Today", "Next", "Scheduled", "Someday", "Projects"}
-- original script set {"Inbox", "Today", "Next", "Scheduled", "Someday", "Projects"}
set theList to {"Inbox", "Today", "Next", "Scheduled", "Someday", "Projects"}

-- configures what should be added to the end of the output
-- original script set outputAppend to linefeed & "----------" & linefeed
set outputAppend to linefeed & "----------" & linefeed

-- configures the output of file and section headers
-- original script set outputHead to "----------" & linefeed
set outputHeader to "----------" & linefeed
set outputSectionHeaderPrefix to "| "

-- configures the file where output is stored
set theFilePath to (path to desktop as Unicode text) & "Things Backup.txt"

-- set to TRUE, script will play a sound when completed
property togglePlaysound : true
set soundCompleted to "/System/Library/Sounds/Glass.aiff"

-- set to TRUE, output will also list all active tags
property toggleTags : true

-- set to TRUE, output for todo items will include due dates when set
property toggleDue : true

-- set to TRUE, output for todo items will include notes when set
property toggleNotes : true

-- set to TRUE, output will include a header for each new section
property toggleSectionHeader : true

-- set to TRUE, overdue tasks will be listed at the top of each section and marked as configured
property togglePrioritizeOverdue : true
property appendOverdue : " (overdue)"

-- set to TRUE, script will log completed items and empty the trash in Things
property toggleCleanUp : true

-- set to TRUE, script will activate Things if it isn't running
-- set to FALSE and Things is not running, script will attempt to read previous output from disk
property toggleActivateIfNotRunning : true

-- set to TRUE, script will show output on screen
property toggleShowOutput : false

-- ------------------------------------------------------------------------------
-- script
-- ------------------------------------------------------------------------------

on extractThings()
	
	local extractedThings, theListItem, toDo, toDos, tdName, tdDueDate, tdNotes, noteParagraph, prToDo, prToDos, prtdName, prtdDueDate, prtdNotes, prnoteParagraph
	
	set extractedThings to ""
	
	tell application "Things"
		
		repeat with theListItem in theList
			
			if toggleSectionHeader is true then
				
				set extractedThings to outputHeader & outputSectionHeaderPrefix & theListItem & ":" & linefeed & linefeed
				
			end if
			
			set toDos to to dos of list theListItem
			
			repeat with toDo in toDos
				
				set tdName to the name of toDo
				set tdDueDate to the due date of toDo
				set tdNotes to the notes of toDo
				
				if togglePrioritizeOverdue is true and tdDueDate is not missing value and tdDueDate is less than (current date) then
					
					set extractedThings to "- " & tdName & appendOverdue & linefeed & extractedThings
					
				else
					
					set extractedThings to extractedThings & "- " & tdName & linefeed
					
				end if
				
				
				if tdDueDate is not missing value and toggleDue is true then
					
					
					
					set extractedThings to extractedThings & ">> Due: " & date string of tdDueDate & linefeed
					
				end if
				
				if tdNotes is not "" and toggleNotes is true then
					
					repeat with noteParagraph in paragraphs of tdNotes
						
						set extractedThings to extractedThings & tab & noteParagraph & linefeed
						
					end repeat
				end if
				
				if (theListItem as string = "Projects") then
					
					set prToDos to to dos of project tdName
					
					repeat with prToDo in prToDos
						
						set prtdName to the name of prToDo
						set prtdDueDate to the due date of prToDo
						set prtdNotes to the notes of prToDo
						
						if togglePrioritizeOverdue is true and prtdDueDate is not missing value and prtdDueDate is less than (current date) then
							
							set extractedThings to "- " & prtdName & appendOverdue & linefeed & extractedThings
							
						else
							
							set extractedThings to extractedThings & "- " & prtdName & linefeed
							
						end if
						
						
						if prtdDueDate is not missing value then
							
							set extractedThings to extractedThings & tab & ">> Due: " & date string of prtdDueDate & linefeed
							
						end if
						
						if prtdNotes is not "" then
							
							repeat with prnoteParagraph in paragraphs of prtdNotes
								
								set extractedThings to extractedThings & tab & tab & prnoteParagraph & linefeed
								
							end repeat
						end if
					end repeat
				end if
			end repeat
			
			set extractedThings to extractedThings & outputAppend
			
		end repeat
		
		if toggleTags is true then
			
			set extractedThings to extractedThings & outputSectionHeaderPrefix & "Tags:" & linefeed & linefeed
			
			repeat with aTag in tags
				
				set extractedThings to extractedThings & "- " & name of aTag & linefeed
				
			end repeat
		end if
		
	end tell
	
	return extractedThings
	
end extractThings

set scriptOutput to ""

if (toggleActivateIfNotRunning is true and application "Things" is not running) then tell application "Things" to activate

if application "Things" is running then
	
	tell application "Things"
		
		if toggleCleanUp is true then
			
			log completed now
			empty trash
			
		end if
	end tell
	
	set scriptOutput to scriptOutput & extractThings()
	
	set theFile to (open for access file (theFilePath) with write permission)
	set eof of theFile to 0
	write scriptOutput to theFile
	close access theFile
	
else
	
	try
		
		set theFile to (open for access file (theFilePath))
		set scriptOutput to (read theFile)
		close access theFile
		
	on error
		
		tell application "Finder" to delete file theFilePath
		set scriptOutput to ""
		
	end try
end if

if (toggleShowOutput is true and scriptOutput is not "") then
	
	return scriptOutput
	
end if

if togglePlaysound is true then
	
	do shell script "/usr/bin/afplay " & soundCompleted
	
end if
