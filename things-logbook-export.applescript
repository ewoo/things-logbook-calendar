on extractThings()
	set extractedThings to ""
	tell application "Things"
		set completedTasks to to dos of list "Logbook"
		repeat with task in completedTasks
			set extractedThings to extractedThings & (name of task) & "	"
			set extractedThings to extractedThings & (id of task) & "	"
			set extractedThings to extractedThings & (creation date of task) & "	"
			set extractedThings to extractedThings & (completion date of task) & "	"
			set extractedThings to extractedThings & (cancellation date of task) & "	"
			--			set extractedThings to extractedThings & (status of task) & "\t"
			--			set extractedThings to extractedThings & (tag names of task) & "\t"
			--			set extractedThings to extractedThings & (name of area of task) & "\t"
			--			set extractedThings to extractedThings & (name of project of task) & "\t"
			--			set extractedThings to extractedThings & (notes of task) & "\t"
			set extractedThings to extractedThings & "

"
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