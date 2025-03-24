#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Things Quick Entry Autofill
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author danny-little
# @raycast.authorURL https://raycast.com/danny-little

on run argv	if not application "Things3" is running then		tell application "Things3"			show quick entry panel with autofill yes		end tell	end ifend run