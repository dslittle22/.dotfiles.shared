#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Things Quick Entry
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author danny-little
# @raycast.authorURL https://raycast.com/danny-little

on run argv	if not application "Things3" is running then		tell application "Things3"			show quick entry panel		end tell	end ifend run