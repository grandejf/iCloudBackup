--- set backupFile to (((path to documents folder) as string) & "NotesBackup.html")

set backupDir to POSIX path of (path to home folder) & "Dropbox/iCloudBackups"

set backupFile to POSIX file (backupDir & "/NotesBackup.html")

if not fileExists(POSIX path of backupDir) then
	display dialog backupDir & " does not exist."
end if

my write_to_file("", backupFile, false)

set wasRunning to is_running("Notes")

tell application "Notes"
	repeat with aNote in notes
		set noteText to "<!-- ### Start Note ### -->
"
		set noteText to noteText & ("<h1>" & name of aNote as string) & "</h1>
"
		set noteText to noteText & ("<p>Creation Date: " & creation date of aNote as string) & "</p>
"
		set noteText to noteText & ("<p>Modification Date: " & modification date of aNote as string) & "</p>
"
		set noteText to (noteText & body of aNote as string) & "

"
		
		my write_to_file(noteText, backupFile, true)
	end repeat
	if not wasRunning then
		quit
	end if
end tell

on write_to_file(this_data, target_file, append_data)
	try
		set the target_file to the target_file as string
		set the open_target_file to open for access file target_file with write permission
		if append_data is false then set eof of the open_target_file to 0
		write this_data to the open_target_file starting at eof
		close access the open_target_file
		return true
	on error
		try
			close access file target_file
		end try
		return false
	end try
end write_to_file

on fileExists(posixPath)
	return ((do shell script "if test -e " & quoted form of posixPath & "; then
echo 1;
else
echo 0;
fi") as integer) as boolean
end fileExists

on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running