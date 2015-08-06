on extractThings()
	set extractedThings to ""
	
	tell application "Things"
		set doneTodos to to dos of list "Logbook"
		
		-- Set the column descriptions.
		set extractedThings to extractedThings & "Task ID" & "	"
		set extractedThings to extractedThings & "Task Name" & "	"
		set extractedThings to extractedThings & "Create Date" & "	"
		set extractedThings to extractedThings & "Completion Date" & "	"
		set extractedThings to extractedThings & "Cancellation Date" & "	"
		set extractedThings to extractedThings & "Project Name" & "	"
		
		set extractedThings to extractedThings & "Area Name" & linefeed
		--log extractedThings
		--log (count doneTodos)
		
		--		set i to 1
		repeat with task in doneTodos
			
			set extractedThings to extractedThings & (id of task) & "	"
			set extractedThings to extractedThings & (name of task) & "	"
			
			set shortdate to (creation date of task)
			set extractedThings to extractedThings & (short date string of shortdate) & "	"
			
			set shortdate to (completion date of task)
			set extractedThings to extractedThings & (short date string of shortdate) & "	"
			
			set shortdate to (cancellation date of task)
			set extractedThings to extractedThings & (short date string of shortdate) & "	"
			
			-- set i to i + 1
			-- if i > 10 then exit repeat
			
			set p to project of task
			if p exists then
				set extractedThings to extractedThings & (name of p) & "	"
			else
				set extractedThings to extractedThings & "	"
			end if
			
			set a to area of task
			if a exists then
				set extractedThings to extractedThings & (name of a) & "	"
			else
				set extractedThings to extractedThings & "	"
			end if
			
			-- Add line break
			set extractedThings to extractedThings & linefeed
		end repeat
	end tell
	
	return extractedThings	
end extractThings

on writeToFile(scriptOutput)
	-- configures the file where output is stored
	set theFilePath to (path to desktop as Unicode text) & "Things-logbook-dump.csv"
	set theFile to (open for access file (theFilePath) with write permission)
	set eof of theFile to 0
	write scriptOutput to theFile
	close access theFile
end writeToFile

if application "Things" is not running then tell application "Things" to activate

if application "Things" is running then
	set output to extractThings()
	writeToFile(output)
	-- log output
end if
