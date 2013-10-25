

script theScript
	set backupDir to POSIX path of (path to home folder) & "Dropbox/iCloudBackups"
	
	set backupFile to POSIX file (backupDir & "/RemindersBackup.html")
	
	if not fileExists(POSIX path of backupDir) then
		display dialog backupDir & " does not exist."
	end if
	
	set wasRunning to is_running("Reminders")
	
	my write_to_file("", backupFile, false)
	tell application "Reminders"
		set todo_lists to get every list
		
		repeat with aList in todo_lists
			repeat with rType in {"", "Completed"}
				set reminderText to ""
				set rTypeText to ""
				set rType to text of rType
				if rType = "Completed" then
					set rTypeText to rType & " "
				end if
				set reminderText to reminderText & ("<h1>" & rTypeText & my htmlize(name of aList) & "</h1>\n")
				my htmlize(reminderText)
				repeat with aReminder in reminders in aList
					set keep to false
					if (rType is "" and not completed of aReminder) then
						set keep to true
					end if
					if (rType is "Completed" and completed of aReminder) then
						set keep to true
					end if
					if keep then
						set theText to name of aReminder
						set checked to ""
						if completed of aReminder then
							set cDate to completion date of aReminder
							set theText to theText & " [" & my dateStamp(cDate) & "]"
							set checked to "checked"
						end if
						set reminderText to reminderText & ("<input type=checkbox " & checked & "><span>" & my htmlize(theText) & "</span><br>\n")
					end if
				end repeat
				my write_to_file(reminderText, backupFile, true)
			end repeat
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
		return ((do shell script "if test -e " & quoted form of posixPath & "; then\necho 1;\nelse\necho 0;\nfi") as integer) as boolean
	end fileExists
	
	on is_running(appName)
		tell application "System Events" to (name of processes) contains appName
	end is_running
	
	on dateStamp(mydate)
		set y to text -4 thru -1 of ("0000" & (year of mydate))
		set m to text -2 thru -1 of ("00" & ((month of mydate) as integer))
		set d to text -2 thru -1 of ("00" & (day of mydate))
		set hour to text -2 thru -1 of ("00" & (hours of mydate))
		set sec to text -2 thru -1 of ("00" & (minutes of mydate))
		return y & "-" & m & "-" & d & " " & hour & ":" & sec
	end dateStamp
	
	on htmlize(this_text)
		return this_text
		set this_text to replace_chars(this_text, "&", "&amp;")
		set this_text to replace_chars(this_text, ">", "&gt;")
		set this_text to replace_chars(this_text, "<", "&lt;")
		return this_text
	end htmlize
	
	on replace_chars(this_text, search_string, replacement_string)
		set AppleScript's text item delimiters to the search_string
		set the item_list to every text item of this_text
		set AppleScript's text item delimiters to the replacement_string
		set this_text to the item_list as string
		set AppleScript's text item delimiters to ""
		return this_text
	end replace_chars
end script

run script theScript