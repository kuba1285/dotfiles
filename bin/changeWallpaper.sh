#!/bin/bash 

function getDefinedVariables() {
	loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
	wallpaper_store_path="/Users/${loggedInUser}/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
	screenSaverBase64=$(plutil -extract AllSpacesAndDisplays xml1 -o - "${wallpaper_store_path}" | awk '/<data>/,/<\/data>/' | xargs | tr -d " " | tr "<" "\n" | tail -2 | head -1 | cut -c6-)
	wallpaperBase64=$(plutil -extract AllSpacesAndDisplays xml1 -o - "${wallpaper_store_path}" | awk '/<data>/,/<\/data>/' | xargs | tr -d " " | tr "<" "\n" | head -2 | tail -1 | cut -c6-)
	getStarterVariables
}

function getStarterVariables() {
	# Do not edit these variables.
	currentRFC3339UTCDate="$(date -u '+%FT%TZ')"
	loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
	wallpaperStoreDirectory="/Users/${loggedInUser}/Library/Application Support/com.apple.wallpaper/Store"
	wallpaperStoreFile="Index.plist"
	wallpaperStoreFullPath="${wallpaperStoreDirectory}/${wallpaperStoreFile}"
	setScreenSaverSettings
}

function setScreenSaverSettings() {
	aerialDesktopAndScreenSaverSettingsPlist="$(plutil -create xml1 - |
		plutil -insert 'Desktop' -dictionary -o - - |
		plutil -insert 'Desktop.Content' -dictionary -o - - |
		plutil -insert 'Desktop.Content.Choices' -array -o - - |
		plutil -insert 'Desktop.Content.Choices' -dictionary -append -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Configuration' -data "${wallpaperBase64}" -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Files' -array -o - - |
		plutil -insert 'Desktop.Content.Choices.0.Provider' -string 'com.apple.wallpaper.choice.aerials' -o - - |
		plutil -insert 'Desktop.Content.Shuffle' -string '$null' -o - - |
		plutil -insert 'Desktop.LastSet' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Desktop.LastUse' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Idle' -dictionary -o - - |
		plutil -insert 'Idle.Content' -dictionary -o - - |
		plutil -insert 'Idle.Content.Choices' -array -o - - |
		plutil -insert 'Idle.Content.Choices' -dictionary -append -o - - |
		plutil -insert 'Idle.Content.Choices.0.Configuration' -data "${screenSaverBase64}" -o - - |
		plutil -insert 'Idle.Content.Choices.0.Files' -array -o - - |
		plutil -insert 'Idle.Content.Choices.0.Provider' -string 'com.apple.wallpaper.choice.screen-saver' -o - - |
		plutil -insert 'Idle.Content.Shuffle' -string '$null' -o - - |
		plutil -insert 'Idle.LastSet' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Idle.LastUse' -date "${currentRFC3339UTCDate}" -o - - |
		plutil -insert 'Type' -string 'individual' -o - -)"
	makeScreenSaverDirectory
}

function makeScreenSaverDirectory() {
	# Create the path to the screen saver/wallpaper Index.plist.
	mkdir -p "${wallpaperStoreDirectory}"
	createIndexPlist
}

function createIndexPlist() {
	# Create the Index.plist
	plutil -create binary1 - |
		plutil -insert 'AllSpacesAndDisplays' -xml "${aerialDesktopAndScreenSaverSettingsPlist}" -o - - |
		plutil -insert 'Displays' -dictionary -o - - |
		plutil -insert 'Spaces' -dictionary -o - - |
		plutil -insert 'SystemDefault' -xml "${aerialDesktopAndScreenSaverSettingsPlist}" -o "${wallpaperStoreFullPath}" -
	killWallpaperAgent
}

function killWallpaperAgent() {
	# Kill the wallpaperAgent to refresh and apply the screen saver/wallpaper settings.
	killall WallpaperAgent
	WAL_IMGS=($(ls -d /Users/mymac/Pictures/*))
	SEC=`date +%S`
	I=$((SEC%$(echo ${#WAL_IMGS[@]})+1))
	osascript -e "
	tell application \"System Events\"
		tell every desktop
  		set picture to \"${WAL_IMGS[$I]}\"
	    end tell
	end tell"
	wal -qni ${WAL_IMGS[$I]}
}

function showVariables() {
	echo "screenSaverBase64: ${screenSaverBase64}"
	echo "wallpaperBase64: ${wallpaperBase64}"
	echo "$(date) - Setting screen saver settings..."
	echo "$(date) - screenSaverBase64: ${screenSaverBase64}"
	echo "$(date) - wallpaperBase64: ${wallpaperBase64}"
	echo "$(date) - currentRFC3339UTCDate: ${currentRFC3339UTCDate}"
	echo "$(date) - Logged in user: ${loggedInUser}"
	echo "$(date) - wallpaperStoreDirectory: ${wallpaperStoreDirectory}"
	echo "$(date) - wallpaperStoreFile: ${wallpaperStoreFile}"
	echo "$(date) - wallpaperStoreFullPath: ${wallpaperStoreFullPath}"
	echo "$(date) - Creating screen saver directory..."
	echo "$(date) - Creating screen saver Index.plist..."
	echo "$(date) - Restarting wallpaper agent..."
}

echo ""
getDefinedVariables
