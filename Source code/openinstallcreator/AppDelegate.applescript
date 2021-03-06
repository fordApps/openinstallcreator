--
--  AppDelegate.applescript
--  openinstallcreator
--
--  Created by Ford on 4/2/20.
--  Copyright © 2020 MinhTon. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
	property NSAlert : class "NSAlert"
	
	-- View 1
	property createNormalInstallersView : missing value
	property selectVolumePopUp0 : missing value
	property selectInstallerButton0 : missing value
	property progressBar0 : missing value
	property progressText0 : missing value
	property continueButton0 : missing value
	property continueText0 : missing value
	property statusText0 : missing value
	property readybutton0 : missing value
	
	-- View 2
	property downloadAppleInstallersView : missing value
	property selectOSVersionPopUp : missing value
	property continueButton1 : missing value
	property continueText1 : missing value
	property progressBar1 : missing value
	property statusText1 : missing value
	property progressText1 : missing value
	property readybutton1 : missing value
	property browseSaveFolder : missing value
	
	on alertDidEnd()
	end alertDidEnd
    
    on awakeFromNib()
        downloadAppleInstallersView's setHidden:true
        progressText0's setHidden:true
        continueButton0's setEnabled:false
        progressBar0's setHidden:true
    end awakeFromNib
	
	-----------------------------------------------------------------------------------
	--  FIRST VIEW  -  NORMAL BOOTABLE INSTALLER --
	
	on SelectVolumePopUp0Clicked:sender
		set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
		set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		do shell script "defaults write " & (quoted form of flagspath) & " SelectedVolume " & (quoted form of selectedVolume)
	end SelectVolumePopUp0Clicked:
	
    on refreshVolumeList:sender
        tell selectVolumePopUp0's |menu|() to removeAllItems()
        set VolumesList to (get paragraphs of (do shell script "ls /Volumes"))
        selectVolumePopUp0's addItemsWithTitles:VolumesList
        set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
        set selectedVolume to quoted form of selectedVolume
        set flagspath to "/tmp/openinstallcreatorflags.plist"
        set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
        do shell script "defaults write " & (quoted form of flagspath) & " SelectedVolume " & (quoted form of selectedVolume)
    end refreshVolumeList:
    
	on selectInstallerButton0Clicked:sender
		set InstallerPath to choose file with prompt "Please select a macOS or OS X Installer to process:" of type {"app"}
		set InstallerPath to POSIX path of InstallerPath
		statusText0's setStringValue:"Now, please select the I'm ready button to continue."
		set InstallerPath to (do shell script "echo " & (quoted form of InstallerPath) & "| sed 's/ /\\\\ /g'")
		
		set valid to (do shell script "defaults read " & InstallerPath & "Contents/Info.plist CFBundleIconFile")
		if valid = "InstallAssistant" then
			set myAlert to NSAlert's alertWithMessageText:"Successfully verified as a genuine Installer." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Press I'm ready to Continue."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
            set flagspath to "/tmp/openinstallcreatorflags.plist"
            do shell script "defaults write " & (quoted form of flagspath) & " InstallerPath " & (quoted form of InstallerPath)
		else
			set myAlert to NSAlert's alertWithMessageText:"Failed to verify the selected Installer." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"This is not a macOS or OS X Installer. Please try again."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
		end if
	end selectInstallerButton0Clicked:
	
	on readybutton0Clicked:sender
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		set InstallerPath to (do shell script "defaults read " & (quoted form of flagspath) & " InstallerPath")
		if InstallerPath = "unavailable" then
			set myAlert to NSAlert's alertWithMessageText:"Have you selected an Apple Installer?" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Oops... Seems like you forgot to choose an Installer."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
		else
			set myAlert to NSAlert's alertWithMessageText:"Create Bootable Installer" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Warning: All contents on the destination disk will be erased. Please backup all of your important data before proceeding."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
			continueButton0's setEnabled:true
			selectVolumePopUp0's setEnabled:false
			selectInstallerButton0's setEnabled:false
			readybutton0's setEnabled:false
			statusText0's setStringValue:"Press the Continue button to start the creation process."
		end if
	end readybutton0Clicked:
	
	on continueButton0Clicked:sender
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		set InstallerPath to (do shell script "defaults read " & (quoted form of flagspath) & " InstallerPath")
		set OriginalInstallerPath to InstallerPath
		set InstallerPath to (do shell script "echo " & InstallerPath & "| sed 's/ /\\\\ /g' | rev | cut -c 2- | rev")
		set selectedVolume to (do shell script "defaults read " & (quoted form of flagspath) & " SelectedVolume")
		set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
		set selectedVolume to ("/Volumes/" & selectedVolume)
		statusText0's setStringValue:"openinstallcreator is creating a Bootable macOS/OS X Installer..."
		CreateNormalInstallMedia(InstallerPath, selectedVolume, flagspath)
	end continueButton0Clicked:
	
	on AboutButtonClicked:sender
		set theController to current application's class "NSWindowController"'s alloc()'s init()
		current application's class "NSBundle"'s loadNibNamed:"About" owner:theController
	end AboutButtonClicked:
	
	-----------------------------------------------------------------------------------
	-- SECOND VIEW - DOWNLOAD APPLE INSTALLERS --
	
	on selectOSVersionPopUpClicked:sender
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		set SelectedOSVersion to ((selectOSVersionPopUp's indexOfSelectedItem()) as string) as integer
		do shell script "defaults write " & (quoted form of flagspath) & " SelectedOSVersion " & SelectedOSVersion
	end selectOSVersionPopUpClicked:
	
	on browseSaveFolderClicked:sender
		set SavePath to choose folder with prompt "Please select a folder to save the Installer:"
		set SavePath to POSIX path of SavePath
		set writable to do shell script "test -w " & (quoted form of SavePath) & "; echo $?"
		if writable = "1" then
			set myAlert to NSAlert's alertWithMessageText:"Destination is not writable." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please choose a writable destination folder to save the Apple Installer later."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
		else if writable = "0" then
			set flagspath to "/tmp/openinstallcreatorflags.plist"
			do shell script "defaults write " & (quoted form of flagspath) & " SavePath " & (quoted form of SavePath)
			set myAlert to NSAlert's alertWithMessageText:"Successfully verified as a writable folder." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Press I'm ready to Continue."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
		end if
	end browseSaveFolderClicked:
	
	on readybutton1Clicked:sender
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		set SavePath to (do shell script "defaults read " & (quoted form of flagspath) & " SavePath")
		if SavePath = "unavailable" then
			set myAlert to NSAlert's alertWithMessageText:"No destination folder has been specified." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Try to click the Folder Icon and browse for a folder to save the macOS/OS X Installer."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
		else
			set myAlert to NSAlert's alertWithMessageText:"Download Apple Installers" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"This will begin downloading macOS/OS X directly from Apple. This is about a 6GB download, and will take some time to complete depending on your Internet Connection Speed."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
			selectOSVersionPopUp's setEnabled:false
			readybutton1's setEnabled:false
			browseSaveFolder's setEnabled:false
			continueButton1's setEnabled:true
			statusText1's setStringValue:"Press the Continue button to start the download process."
		end if
	end readybutton1Clicked:
	
	on continueButton1Clicked:sender
		statusText1's setStringValue:"openinstallcreator is downloading an Apple macOS/OS X Installer..."
		downloadAppleInstallers()
	end continueButton1Clicked:
	
	-----------------------------------------------------------------------------------
	-- BASIC FUNCTIONS FOR EACH VIEW --
	
	on CreateNormalInstallMedia(InstallerPath, selectedVolume, flagspath)
		
		progressText0's setHidden:false
		readybutton0's setHidden:true
		continueButton0's setEnabled:false
		progressBar0's setHidden:false
		
		-- Ask root permission
		progressText0's setStringValue:"Starting Helper..."
		delay 3
		do shell script "echo" with administrator privileges
		
		-- Installer name
		progressText0's setStringValue:"Unpacking Installer..."
		delay 3
		set Installer_App_Name to (do shell script "basename " & InstallerPath)
		set Installer_App_Name_Partial to (do shell script "echo " & Installer_App_Name & " | rev | cut -c5- | rev")
		set Installer_SharedSupport_Path to InstallerPath & "/Contents/SharedSupport"
		tell progressBar0 to setDoubleValue:5
		
		-- Check installer structure
		progressText0's setStringValue:"Checking Installer Structure..."
		try
			delay 3
			do shell script "hdiutil attach " & Installer_SharedSupport_Path & "/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse" with administrator privileges
		on error
			set myAlert to NSAlert's alertWithMessageText:"Couldn't mount InstallESD.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available free space."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
			statusText0's setStringValue:"Press the Reset Application button to retry."
			progressText0's setHidden:true
			progressBar0's setHidden:true
			error number -128
		end try
		
		set CheckStructure to (do shell script "defaults read " & (quoted form of flagspath) & " CheckStructure")
		set StructureReturned to (do shell script CheckStructure)
		if StructureReturned = "tmp" then
			set Installer_Image_Path to "/tmp/InstallESD"
		else
			set Installer_Image_Path to Installer_SharedSupport_Path
		end if
		tell progressBar0 to setDoubleValue:10
		
		
		-- Mount BaseSystem.dmg
		progressText0's setStringValue:"Mounting BaseSystem.dmg"
		try
			delay 3
			do shell script "hdiutil attach " & Installer_Image_Path & "/BaseSystem.dmg -mountpoint /tmp/Base\\ System -nobrowse" with administrator privileges
		on error
			set myAlert to NSAlert's alertWithMessageText:"Couldn't mount BaseSystem.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available free space."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
			statusText0's setStringValue:"Press the Reset Application button to retry."
			progressText0's setHidden:true
			progressBar0's setHidden:true
			error number -128
		end try
		tell progressBar0 to setDoubleValue:20
		
		-- Check installer version
		progressText0's setStringValue:"Reading Installer Version..."
		delay 3
		set Installer_Version to (do shell script "defaults read /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion")
		set Installer_Version_Short to (do shell script "defaults read /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
		tell progressBar0 to setDoubleValue:25
		
		if Installer_Version = "10.7" or Installer_Version_Short = "10.8." then
			delay 1
			progressText0's setStringValue:"Restoring Disk Image... (Disk will be unusable if abort)"
			
			delay 3
			try
				do shell script "asr restore -source " & Installer_SharedSupport_Path & "/InstallESD.dmg -target " & selectedVolume & " -noprompt -noverify -erase" with administrator privileges
                
                set MountainLionICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/MountainLion.icns"
                set LionICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Lion.icns"
                
                if Installer_Version_Short = "10.8." then
                    do shell script "cp -a " & (quoted form of MountainLionICNS) & " /Volumes/Mac\\ OS\\ X\\ Install\\ ESD/.VolumeIcon.icns" with administrator privileges
                else if Installer_Version = "10.7" then
                    do shell script "cp -a " & (quoted form of LionICNS) & " /Volumes/Mac\\ OS\\ X\\ Install\\ ESD/.VolumeIcon.icns" with administrator privileges
                end if
                
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't restore disk image to target." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please ensure that your destination disk is at least 8GB."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			delay 1
			progressText0's setStringValue:"Unmounting Disk Images..."
			try
				do shell script "hdiutil detach /tmp/Base\\ System" with administrator privileges
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't unmount BaseSystem." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"This is an unknown error."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			try
				do shell script "hdiutil detach /tmp/InstallESD" with administrator privileges
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't unmount InstallESD." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"This is an unknown error."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			progressText0's setStringValue:"Operation Completed."
			display notification "Successfully created an Install Mac OS X Bootable Installer." with title "openinstallcreator" sound name "Opening"
			progressBar0's setDoubleValue:100
		end if
		
		-- This is for 10.9 to 10.15 only
		if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12", "10.13", "10.14", "10.15"} then
			
			-- Erase Installer Volume
			progressText0's setStringValue:"Erasing Installer Volume..."
			delay 3
			try
				do shell script "diskutil eraseVolume HFS+ " & (quoted form of Installer_App_Name_Partial) & " " & selectedVolume with administrator privileges
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't erase Installer Disk." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Use another disk to create a Bootable Installer."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			set Installer_Volume_Name to Installer_App_Name_Partial
			set Installer_Volume_Path to "/Volumes/" & Installer_Volume_Name
			tell progressBar0 to setDoubleValue:35
			
			-- Creating installer folders
			progressText0's setStringValue:"Creating Installer Folders..."
			delay 3
			try
				set Installer_Volume_Path to quoted form of Installer_Volume_Path
				do shell script "mkdir -p " & Installer_Volume_Path & "/Library/Preferences/SystemConfiguration" with administrator privileges
				do shell script "mkdir -p " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
				do shell script "mkdir -p " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
				
				if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
					do shell script "mkdir " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
				end if
				
				if Installer_Version_Short is in {"10.9.", "10.10"} then
					do shell script "mkdir -p " & Installer_Volume_Path & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
				end if
				
				if Installer_Version_Short is in {"10.12", "10.13", "10.14", "10.15"} then
					do shell script "mkdir -p " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
				end if
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't create Installer Folders" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please ensure that your destination disk is at least 8GB."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			tell progressBar0 to setDoubleValue:40
			
			-- Copy installer files
			progressText0's setStringValue:"Copying Installer Files..."
			delay 3
			
			try
				with timeout of 86400 seconds
					try
						do shell script "cp -R " & InstallerPath & " " & Installer_Volume_Path & "/" with administrator privileges
						tell progressBar0 to setDoubleValue:55
					end try
				end timeout
				
				if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/PlatformSupport.plist" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist" & " " & Installer_Volume_Path & "/.IABootFilesSystemVersion.plist" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
				end if
				delay 1
				tell progressBar0 to setDoubleValue:58
				
				if Installer_Version_Short is in {"10.9.", "10.10"} then
					do shell script "cp /tmp/Base\\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache" & " " & Installer_Volume_Path & "/System/Library/Caches/com.apple.kext.caches/Startup" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
				end if
				delay 1
				tell progressBar0 to setDoubleValue:60
				
				if Installer_Version_Short is in {"10.11", "10.12"} then
					do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
				end if
				delay 1
				tell progressBar0 to setDoubleValue:63
				
				if Installer_Version_Short is in {"10.13", "10.14", "10.15"} then
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi*" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/bootbase.efi*" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/BridgeVersion.bin" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/prelinkedkernel" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
					do shell script "cp /tmp/Base\\ System/System/Library/PrelinkedKernels/immutablekernel*" & " " & Installer_Volume_Path & "/System/Library/PrelinkedKernels" with administrator privileges
					do shell script "cp -R /tmp/Base\\ System/usr/standalone/i386/SecureBoot.bundle" & " " & Installer_Volume_Path & "/usr/standalone/i386" with administrator privileges
				end if
				delay 1
				tell progressBar0 to setDoubleValue:65
				
				do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/boot.efi" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
				do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/PlatformSupport.plist" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
				do shell script "cp /tmp/Base\\ System/System/Library/CoreServices/SystemVersion.plist" & " " & Installer_Volume_Path & "/System/Library/CoreServices" with administrator privileges
				delay 1
				
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't copy Installer Files." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please ensure that your destination disk is at least 8GB."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			tell progressBar0 to setDoubleValue:70
			
			-- Create Installer Files
			progressText0's setStringValue:"Creating Installer Boot Files..."
			
			try
				delay 3
				do shell script "echo " & Installer_Version_Short & " >> /tmp/installer_version_short" with administrator privileges
				do shell script "echo " & Installer_App_Name & " >> /tmp/installer_application_name" with administrator privileges
				do shell script "echo " & Installer_Volume_Path & " >> /tmp/installer_volume_path" with administrator privileges
				set createinstallfilessh to POSIX path of (path to current application as text) & "Contents/Resources/createinstallfiles.sh"
                set createinstallfilessh to (do shell script "echo " & (quoted form of createinstallfilessh) & "| sed 's/ /\\\\ /g'")
				do shell script "chmod +x " & createinstallfilessh with administrator privileges
				do shell script createinstallfilessh with administrator privileges
				do shell script "rm /tmp/installer*" with administrator privileges
				
				tell progressBar0 to setDoubleValue:75
				
				
				if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
					do shell script "cp " & Installer_Volume_Path & "/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" & " " & Installer_Volume_Path & "/.IABootFiles" with administrator privileges
				end if
				
				do shell script "touch " & Installer_Volume_Path & "/.metadata_never_index" with administrator privileges
				tell progressBar0 to setDoubleValue:80
				
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't create Installer Boot Files." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please ensure that your destination disk is at least 8GB."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			-- Making disk bootable
			
			progressText0's setStringValue:"Making Installer Bootable..."
			
			try
				delay 3
				if Installer_Version_Short is in {"10.9.", "10.10", "10.11", "10.12"} then
					do shell script "bless --folder " & Installer_Volume_Path & "/.IABootFiles --label " & (quoted form of Installer_Volume_Name) with administrator privileges
				end if
				
				if Installer_Version_Short is in {"10.13", "10.14", "10.15"} then
					do shell script "bless --folder " & Installer_Volume_Path & "/System/Library/CoreServices --label " & (quoted form of Installer_Volume_Name) with administrator privileges
				end if

				do shell script "chflags hidden " & Installer_Volume_Path & "/System" with administrator privileges
				do shell script "chflags hidden " & Installer_Volume_Path & "/Library" with administrator privileges
				do shell script "chflags hidden " & Installer_Volume_Path & "/usr" with administrator privileges
				
				set CatalinaICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Catalina.icns"
                
				set MojaveICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Mojave.icns"
                
				set HighSierraICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/HighSierra.icns"
                
				set SierraICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Sierra.icns"
                
				set ElCapitanICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/ElCapitan.icns"
                
				set YosemiteICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Yosemite.icns"
                
				set MavericksICNS to POSIX path of (path to current application as text) & "Contents/Resources/volumeicon.bundle/Mavericks.icns"
				
				if Installer_Version_Short = "10.10" then
					do shell script "cp -a " & (quoted form of YosemiteICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				else if Installer_Version_Short = "10.11" then
					do shell script "cp -a " & (quoted form of ElCapitanICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				else if Installer_Version_Short = "10.12" then
					do shell script "cp -a " & (quoted form of SierraICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				else if Installer_Version_Short = "10.13" then
					do shell script "cp -a " & (quoted form of HighSierraICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				else if Installer_Version_Short = "10.14" then
					do shell script "cp -a " & (quoted form of MojaveICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				else if Installer_Version_Short = "10.15" then
					do shell script "cp -a " & (quoted form of CatalinaICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				else if Installer_Version_Short = "10.9." then
					do shell script "cp -a " & (quoted form of MavericksICNS) & " " & Installer_Volume_Path & "/.VolumeIcon.icns" with administrator privileges
				end if
				
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't make Installer Bootable." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please ensure that your destination disk is at least 8GB."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			tell progressBar0 to setDoubleValue:90
			
			-- Unmount disk images
			progressText0's setStringValue:"Unmounting Disk Images..."
			
			try
				delay 3
				do shell script "hdiutil detach /tmp/Base\\ System" with administrator privileges
				do shell script "hdiutil detach /tmp/InstallESD" with administrator privileges
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't unmount Disk Images." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"This is an unknown error."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				statusText0's setStringValue:"Press the Reset Application button to retry."
				progressText0's setHidden:true
				progressBar0's setHidden:true
				error number -128
			end try
			
			
			tell progressBar0 to setDoubleValue:100
			progressText0's setStringValue:"Operation Completed."
			display notification "Successfully created an " & Installer_Volume_Name & " Bootable Installer." with title "openinstallcreator" sound name "Opening"
			-- The End.
			
		end if -- End creating for 10.9 to 10.15
		
	end CreateNormalInstallMedia
	
	on downloadAppleInstallers()
		
		delay 3
		progressText1's setStringValue:"Starting helper..."
		progressBar1's setHidden:false
		progressBar1's startAnimation:me
		continueButton1's setEnabled:false
		readybutton1's setHidden:true
		progressText1's setHidden:false

		set flagspath to "/tmp/openinstallcreatorflags.plist"
		-- set installerdownload to (do shell script "defaults read " & (quoted form of flagspath) & " installerdownload")
		-- set installerprep to (do shell script "defaults read " & (quoted form of flagspath) & " installerprep")
		
		delay 3
		set SavePath to (do shell script "defaults read " & (quoted form of flagspath) & " SavePath")
		set OriginalSavePath to SavePath
		set SavePath to (do shell script "echo " & SavePath & "| sed 's/ /\\\\ /g' | rev | cut -c 2- | rev")
		set SelectedOSVersion to (do shell script "defaults read " & (quoted form of flagspath) & " SelectedOSVersion")
		
		-- Check system version
		progressText1's setStringValue:"Reading System Version..."
		delay 3
		set Volume_Version to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion")
		set Volume_Version_Short to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
		set Volume_Build to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductBuildVersion")
		
		-- Check internet connection
		progressText1's setStringValue:"Checking Internet Connection..."
		delay 3
		repeat with i from 1 to 2
			try
				do shell script "ping -o -t 2 www.google.com"
				exit repeat
			on error
				if i = 2 then
					set myAlert to (NSAlert's alertWithMessageText:"No Internet Connection." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Please connect to the Internet to download the Installer.")
					(myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value))
					(progressText1's setHidden:true)
					(progressBar1's setHidden:true)
					(statusText1's setStringValue:"Press the Reset Application button to retry.")
					error number -128
				end if
			end try
		end repeat
		
		-- Prepare resources
		progressText1's setStringValue:"Preparing Resources..."
		delay 3
		try
            set pbzx to POSIX path of (path to current application as text) & "Contents/Resources/pbzx"
            set Curl to POSIX path of (path to current application as text) & "Contents/Resources/curl"
            do shell script "cp " & (quoted form of Curl) & " /tmp"
            do shell script "chmod +x /tmp/curl"
            set cacert to POSIX path of (path to current application as text) & "Contents/Resources/cacert.pem"
            do shell script "cp " & (quoted form of cacert) & " /tmp"
            set Curl to "/tmp/curl --cacert /tmp/cacert.pem"
			do shell script "cp " & (quoted form of pbzx) & " /tmp"
			do shell script "chmod +x /tmp/pbzx"
		on error
			set myAlert to NSAlert's alertWithMessageText:"Failed to prepare resources." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Couldn't copy file to temporary folder."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
			progressText1's setHidden:true
			progressBar1's setHidden:true
			statusText1's setStringValue:"Press the Reset Application button to retry."
			error number -128
		end try
		
		-- Input Installer Version
		progressText1's setStringValue:"Preparing Catalog..."
		delay 3
		try
			if SelectedOSVersion = "0" then
				set Installer_URL to "53/58/061-96006-A_D2HTVCGUD8/gdt4thee08sjbckqx4p9efpww12qgz3w98"
				set Installer_Name to "Install macOS Catalina"
				set InstallerVer to "10.15"
			end if
			
			if SelectedOSVersion = "1" then
				set Installer_URL to "17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el"
				set Installer_Name to "Install macOS Mojave"
				set InstallerVer to "10.14"
			end if
			
			if SelectedOSVersion = "2" then
				set Installer_URL to "06/50/041-91758-A_M8T44LH2AW/b5r4og05fhbgatve4agwy4kgkzv07mdid9"
				set Installer_Name to "Install macOS High Sierra"
				set InstallerVer to "10.13"
			end if
			
			if SelectedOSVersion = "3" then
				set Installer_URL to "http://updates-http.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg"
				set Installer_Name to "Install macOS Sierra"
				set InstallerVer to "10.12"
			end if
			
			if SelectedOSVersion = "4" then
				set Installer_URL to "http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg"
				set Installer_Name to "Install OS X El Capitan"
				set InstallerVer to "10.11"
			end if
			
			if SelectedOSVersion = "5" then
				set Installer_URL to "http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg"
				set Installer_Name to "Install OS X Yosemite"
				set InstallerVer to "10.10"
			end if
			
		on error
			set myAlert to NSAlert's alertWithMessageText:"Failed to prepare Catalog file." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Couldn't get connections to Apple's server ready."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
			progressText1's setHidden:true
			progressBar1's setHidden:true
			statusText1's setStringValue:"Press the Reset Application button to retry."
			error number -128
		end try
		
		delay 3
		do shell script "mkdir -p /tmp/" & (quoted form of Installer_Name)
		
		-- Download & Prepare Installer
		progressText1's setStringValue:"Downloading Installer..."
		delay 3
		
		set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/downloadosflags.plist"
		do shell script "rsync -a -v --ignore-existing " & (quoted form of flagspath) & " " & "/tmp/" & (quoted form of Installer_Name) & "/"
		
		set flagspath to "/tmp/" & (quoted form of Installer_Name) & "/downloadosflags.plist"
		set installassistantauto to (do shell script "defaults read " & flagspath & " installassistantauto")
		set applediagnosticschunk to (do shell script "defaults read " & flagspath & " applediagnosticschunk")
		set applediagnosticsdmg to (do shell script "defaults read " & flagspath & " applediagnosticsdmg")
		set basesystemchuck to (do shell script "defaults read " & flagspath & " basesystemchuck")
		set basesystemdmg to (do shell script "defaults read " & flagspath & " basesystemdmg")
		set installesd to (do shell script "defaults read " & flagspath & " installesd")
		set installdmg to (do shell script "defaults read " & flagspath & " installdmg")
		set installpkg to (do shell script "defaults read " & flagspath & " installpkg")
		
		if InstallerVer is in {"10.13", "10.14", "10.15"} then
			
			do shell script "touch /tmp/download.log"
			
			-- Download InstallAssistantAuto.pkg
			if not (installassistantauto = "1") then
				try
					progressText1's setStringValue:"Downloading InstallAssistantAuto.pkg..."
					delay 3
					do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/InstallAssistantAuto.pkg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/InstallAssistantAuto.pkg >> /tmp/download.log 2>&1"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't download InstallAssistantAuto.pkg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " installassistantauto 1"
			end if
			
			-- Download AppleDiagnostics.chunklist
			if not (applediagnosticschunk = "1") then
				try
					progressText1's setStringValue:"Downloading AppleDiagnostics.chunklist..."
					delay 3
					do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.chunklist http://swcdn.apple.com/content/downloads/" & Installer_URL & "/AppleDiagnostics.chunklist >> /tmp/download.log 2>&1"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't download AppleDiagnostics.chunklist" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " applediagnosticschunk 1"
			end if
			
			-- Download AppleDiagnostics.dmg
			if not (applediagnosticsdmg = "1") then
				try
					progressText1's setStringValue:"Downloading AppleDiagnostics.dmg..."
					delay 3
					do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.dmg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/AppleDiagnostics.dmg >> /tmp/download.log 2>&1"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't download AppleDiagnostics.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " applediagnosticsdmg 1"
			end if
			
			-- Download BaseSystem.chunklist
			if not (basesystemchuck = "1") then
				try
					progressText1's setStringValue:"Downloading BaseSystem.chunklist..."
					delay 3
					do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.chunklist http://swcdn.apple.com/content/downloads/" & Installer_URL & "/BaseSystem.chunklist >> /tmp/download.log 2>&1"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't download BaseSystem.chunklist" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " basesystemchuck 1"
			end if
			
			
			-- Download BaseSystem.dmg
			if not (basesystemdmg = "1") then
				with timeout of 86400 seconds
					try
						progressText1's setStringValue:"Downloading BaseSystem.dmg..."
                        progressBar1's setHidden:false
						delay 3
						do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.dmg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/BaseSystem.dmg >> /tmp/download.log 2>&1"
					on error
						set myAlert to NSAlert's alertWithMessageText:"Couldn't download BaseSystem.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
						myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
						progressText1's setHidden:true
						progressBar1's setHidden:true
						statusText1's setStringValue:"Press the Reset Application button to retry."
						error number -128
					end try
				end timeout
				do shell script "defaults write " & flagspath & " basesystemdmg 1"
			end if
			
			-- Download InstallESD.dmg
			if not (installesd = "1") then
				progressText1's setStringValue:"Downloading InstallESD.dmg..."
				with timeout of 86400 seconds
					try
                        progressBar1's setHidden:false
						delay 3
						do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/InstallESD.dmg http://swcdn.apple.com/content/downloads/" & Installer_URL & "/InstallESDDmg.pkg >> /tmp/download.log 2>&1"
					on error
						set myAlert to NSAlert's alertWithMessageText:"Couldn't download InstallESD.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
						myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
						progressText1's setHidden:true
						progressBar1's setHidden:true
						statusText1's setStringValue:"Press the Reset Application button to retry."
						error number -128
					end try
				end timeout
				do shell script "defaults write " & flagspath & " installesd 1"
				do shell script "rm /tmp/download.log"
			end if
			
			-- Prepare Installer
			progressText1's setStringValue:"Extracting Installer from package..."
			
			if not (installassistantauto = "2") then
				try
					delay 3
					do shell script "cd /tmp/" & (quoted form of Installer_Name) & " && /tmp/pbzx /tmp/" & (quoted form of Installer_Name) & "/InstallAssistantAuto.pkg | cpio -i"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Failed to extract Installer files from downloaded packages." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " installassistantauto 2"
			end if
			
			progressText1's setStringValue:"Copying files to destination..."
			
			if not (installassistantauto = "3") then
				try
					delay 3
					do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_Name) & ".app " & SavePath
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't extract Installer files from downloaded packages." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " installassistantauto 3"
			end if
			
			progressText1's setStringValue:"Copying AppleDiagnostics.chunklist to destination..."
			
			if not (applediagnosticschunk = "3") then
				try
					delay 3
					do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.chunklist " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't copy AppleDiagnostics.chunklist to destination." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " applediagnosticschunk 3"
			end if
			
			progressText1's setStringValue:"Copying AppleDiagnostics.dmg to destination..."
			
			if not (applediagnosticsdmg = "3") then
				try
					delay 3
					do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/AppleDiagnostics.dmg " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't copy AppleDiagnostics.dmg to destination." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " applediagnosticsdmg 3"
			end if
			
			progressText1's setStringValue:"Copying BaseSystem.chunklist to destination..."
			
			if not (basesystemchuck = "3") then
				try
					delay 3
					do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.chunklist " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't copy BaseSystem.chunklist to destination." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " basesystemchuck 3"
			end if
			
			progressText1's setStringValue:"Copying BaseSystem.dmg to destination..."
			
			if not (basesystemdmg = "3") then
				with timeout of 86400 seconds
					try
						delay 3
						do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/BaseSystem.dmg " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
					on error
						set myAlert to NSAlert's alertWithMessageText:"Couldn't copy BaseSystem.dmg to destination." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
						myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
						progressText1's setHidden:true
						progressBar1's setHidden:true
						statusText1's setStringValue:"Press the Reset Application button to retry."
						error number -128
					end try
				end timeout
				do shell script "defaults write " & flagspath & " basesystemdmg 3"
			end if
			
			progressText1's setStringValue:"Copying InstallESD.dmg to destination..."
			
			if not (installesd = "3") then
				with timeout of 86400 seconds
					try
						delay 3
						do shell script "mv /tmp/" & (quoted form of Installer_Name) & "/InstallESD.dmg " & SavePath & "/" & (quoted form of Installer_Name) & ".app/Contents/SharedSupport"
					on error
						set myAlert to NSAlert's alertWithMessageText:"Couldn't copy InstallESD.dmg to destination." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
						myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
						progressText1's setHidden:true
						progressBar1's setHidden:true
						statusText1's setStringValue:"Press the Reset Application button to retry."
						error number -128
					end try
				end timeout
				do shell script "defaults write " & flagspath & " installesd 3"
			end if
			
		end if
		
		if InstallerVer is in {"10.12", "10.11", "10.10"} then
			
			do shell script "touch /tmp/download.log"
			
			-- Download InstallOS.dmg
			progressText1's setStringValue:"Downloading InstallOS.dmg..."
			
			if not (installdmg = "1") then
				with timeout of 86400 seconds
					try
                        progressBar1's setHidden:false
						delay 3
						do shell script Curl & " -o /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_Name & ".dmg") & " " & Installer_URL & " >> /tmp/download.log 2>&1"
					on error
						set myAlert to NSAlert's alertWithMessageText:"Couldn't download InstallOS.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your Internet Connection and/or available disk space."
						myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
						progressText1's setHidden:true
						progressBar1's setHidden:true
						statusText1's setStringValue:"Press the Reset Application button to retry."
						error number -128
					end try
				end timeout
				do shell script "defaults write " & flagspath & " installdmg 1"
			end if
			
			
			do shell script "rm /tmp/download.log"
			
			-- Prepare Installer
			progressText1's setStringValue:"Mounting Disk Image..."
			
			delay 3
			try
				do shell script "hdiutil attach /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_Name & ".dmg") & " -mountpoint /tmp/" & (quoted form of Installer_Name & "_dmg") & " -nobrowse"
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't mount InstallOS.dmg" defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				progressText1's setHidden:true
				progressBar1's setHidden:true
				statusText1's setStringValue:"Press the Reset Application button to retry."
				error number -128
			end try
			
			set Installer_PKG to (do shell script "ls /tmp/" & (quoted form of Installer_Name & "_dmg"))
			set Installer_PKG_Partial to (do shell script "echo " & (quoted form of Installer_PKG) & " | cut -f1 -d.")
			
			progressText1's setStringValue:"Expanding Packages..."
			
			if not (installpkg = "1") then
				try
					delay 3
					do shell script "pkgutil --expand /tmp/" & (quoted form of Installer_Name & "_dmg") & "/" & (quoted form of Installer_PKG) & " /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_PKG_Partial)
					do shell script "tar -xf /tmp/" & (quoted form of Installer_Name) & "/" & (quoted form of Installer_PKG_Partial) & "/" & (quoted form of Installer_PKG) & "/Payload -C " & SavePath
				on error
					set myAlert to NSAlert's alertWithMessageText:"Couldn't expand Installer Packages." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
					myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
					progressText1's setHidden:true
					progressBar1's setHidden:true
					statusText1's setStringValue:"Press the Reset Application button to retry."
					error number -128
				end try
				do shell script "defaults write " & flagspath & " installpkg 1"
			end if
			
			progressText1's setStringValue:"Copying InstallESD.dmg to destination..."
			
			if not (installesd = "1") then
				with timeout of 86400 seconds
					try
						delay 3
						do shell script "cp /tmp/" & (quoted form of Installer_Name & "_dmg") & "/" & (quoted form of Installer_PKG) & " " & SavePath & "/" & (quoted form of Installer_Name & ".app") & "/Contents/SharedSupport/InstallESD.dmg"
					on error
						set myAlert to NSAlert's alertWithMessageText:"Couldn't copy InstallESD.dmg to destination." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Check your available disk space."
						myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
						progressText1's setHidden:true
						progressBar1's setHidden:true
						statusText1's setStringValue:"Press the Reset Application button to retry."
						error number -128
					end try
				end timeout
				do shell script "defaults write " & flagspath & " installesd 1"
			end if
			
			progressText1's setStringValue:"Unmounting Disk Image..."
			
			try
				delay 3
				do shell script "hdiutil detach /tmp/" & (quoted form of Installer_Name & "_dmg")
			on error
				set myAlert to NSAlert's alertWithMessageText:"Couldn't unmount InstallOS.dmg." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"This is an unknown error."
				myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
				progressText1's setHidden:true
				progressBar1's setHidden:true
				statusText1's setStringValue:"Press the Reset Application button to retry."
				error number -128
			end try
		end if
		
		-- Remove temporary files
		progressText1's setStringValue:"Removing Temporary Files..."
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		delay 3
		do shell script "rm -R /tmp/Install*"
		do shell script "rm /tmp/pbzx"
        do shell script "rm /tmp/cacert.pem"
        do shell script "rm /tmp/curl"
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		progressText1's setStringValue:"Operation Completed."
		display notification "Successfully downloaded " & Installer_Name & ".app Installer from Apple." with title "openinstallcreator" sound name "Opening"
		progressBar1's stopAnimation:me
		
	end downloadAppleInstallers
	
	-------------------------------------------------------------------------------------
	-- SIDE BAR ACTIONS --
	
	on createNormalInstallersViewClicked:sender
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		set View1Status to (do shell script "defaults read " & (quoted form of flagspath) & " View1Status")
		set View4Status to (do shell script "defaults read " & (quoted form of flagspath) & " View4Status")
		if View4Status = "1" then
			downloadAppleInstallersView's setHidden:true
			createNormalInstallersView's setHidden:false
			set ViewStatus to "0"
			do shell script "defaults write " & (quoted form of flagspath) & " View4Status " & ViewStatus
			set ViewStatus to "1"
			do shell script "defaults write " & (quoted form of flagspath) & " View1Status " & ViewStatus
		end if
	end createNormalInstallersViewClicked:
	
	on downloadAppleInstallersViewClicked:sender -- Only for 10.7
		set Volume_Version_Short to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
		if Volume_Version_Short is in {"10.7.", "10.8.", "10.9.", "10.10", "10.11", "10.12", "10.13", "10.14", "10.15"} then
			set flagspath to "/tmp/openinstallcreatorflags.plist"
			set View1Status to (do shell script "defaults read " & (quoted form of flagspath) & " View1Status")
			set View4Status to (do shell script "defaults read " & (quoted form of flagspath) & " View4Status")
			if View1Status = "1" then
				createNormalInstallersView's setHidden:true
				downloadAppleInstallersView's setHidden:false
				progressBar1's setHidden:true
				set SelectedOSVersion to ((selectOSVersionPopUp's indexOfSelectedItem()) as string) as integer
				do shell script "defaults write " & (quoted form of flagspath) & " SelectedOSVersion " & SelectedOSVersion
				do shell script "defaults write " & (quoted form of flagspath) & " SavePath unavailable"
				set ViewStatus to "0"
				do shell script "defaults write " & (quoted form of flagspath) & " View1Status " & ViewStatus
				set ViewStatus to "1"
				do shell script "defaults write " & (quoted form of flagspath) & " View4Status " & ViewStatus
			end if
		else
			set myAlert to NSAlert's alertWithMessageText:"Your version of OS X is not capable of transferring files over the Internet." defaultButton:"OK" alternateButton:"" otherButton:"" informativeTextWithFormat:"Requires OS X 10.7 or later to download Apple Installers. Please update to OS X 10.7."
			myAlert's beginSheetModalForWindow:theWindow modalDelegate:me didEndSelector:"alertDidEnd" contextInfo:(missing value)
		end if
	end downloadAppleInstallersViewClicked:
	
	on resetApplicationClicked:sender
		
		selectVolumePopUp0's setEnabled:true
		selectInstallerButton0's setEnabled:true
		progressBar0's setHidden:true
		progressText0's setHidden:true
		continueButton0's setEnabled:false
		readybutton0's setHidden:false
        readybutton0's setEnabled:true
		
		selectOSVersionPopUp's setEnabled:true
		continueButton1's setEnabled:false
		progressBar1's setHidden:true
		progressText1's setHidden:true
		readybutton1's setHidden:false
        readybutton1's setEnabled:true
		browseSaveFolder's setEnabled:true
        
        set flagspath to "/tmp/openinstallcreatorflags.plist"
        do shell script "defaults write " & (quoted form of flagspath) & " SavePath unavailable"
        do shell script "defaults write " & (quoted form of flagspath) & " InstallerPath unavailable"
        tell selectVolumePopUp0's |menu|() to removeAllItems()
        set VolumesList to (get paragraphs of (do shell script "ls /Volumes"))
        selectVolumePopUp0's addItemsWithTitles:VolumesList
        set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
        set selectedVolume to quoted form of selectedVolume
        set flagspath to "/tmp/openinstallcreatorflags.plist"
        set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
        do shell script "defaults write " & (quoted form of flagspath) & " SelectedVolume " & selectedVolume
        
        statusText1's setStringValue:"Click the Folder icon to select a save folder..."
        statusText0's setStringValue:"Click the OS X icon to browse for a macOS Installer... (10.7 to 10.15)"
		
	end resetApplicationClicked:
	
	------------------------------------------------------------------------------------
	-- MENU BAR ACTIONS --
	
	on AboutMenuClicked:sender
		set theController to current application's class "NSWindowController"'s alloc()'s init()
		current application's class "NSBundle"'s loadNibNamed:"About" owner:theController
	end AboutMenuClicked:
	
	-----------------------------------------------------------------------------------
	-- STARTUP AND QUIT PROCESSES --
	
	on applicationWillFinishLaunching:aNotification
            
		-- First view (createnormalbootableinstaller)
		set VolumesList to (get paragraphs of (do shell script "ls /Volumes"))
		selectVolumePopUp0's addItemsWithTitles:VolumesList
		set selectedVolume to selectVolumePopUp0's titleOfSelectedItem() as text
		set selectedVolume to quoted form of selectedVolume
		
		set flagspath to POSIX path of (path to current application as text) & "Contents/Resources/openinstallcreatorflags.plist"
		do shell script "cp " & (quoted form of flagspath) & " /tmp"
		
		set flagspath to "/tmp/openinstallcreatorflags.plist"
		set selectedVolume to (do shell script "echo " & selectedVolume & "| sed 's/ /\\\\ /g'")
		do shell script "defaults write " & (quoted form of flagspath) & " SelectedVolume " & selectedVolume
		set InstallerPath to "unavailable"
		do shell script "defaults write " & (quoted form of flagspath) & " InstallerPath " & InstallerPath
		POSIX path of (path to current application as text)
		-- View controllers
		set ViewStatus to "1"
		do shell script "defaults write " & (quoted form of flagspath) & " View1Status " & ViewStatus
		
		set Volume_Version_Short to (do shell script "defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5")
		
        if Volume_Version_Short is in {"10.6.","10.7."} then
		else
			try
				set connection to "yes"
                set Curl to POSIX path of (path to current application as text) & "Contents/Resources/curl"
                do shell script "cp " & (quoted form of Curl) & " /tmp"
                set Curl to "/tmp/curl"
                do shell script "chmod +x " & Curl
                set cacert to POSIX path of (path to current application as text) & "Contents/Resources/cacert.pem"
                do shell script "cp " & (quoted form of cacert) & " /tmp"
                set Curl to "/tmp/curl --cacert /tmp/cacert.pem"
				do shell script Curl & " -L -s -o /tmp/softwareupdate.sh https://raw.githubusercontent.com/Minh-Ton/openinstallcreator/master/SUdownload/softwareupdate.sh"
			on error
				set connection to "no"
			end try
            if connection = "yes" then
                do shell script "chmod +x /tmp/softwareupdate.sh"
                set interver to (do shell script "/tmp/softwareupdate.sh")
                set infoplist to POSIX path of (path to current application as text) & "Contents/Info.plist"
                set currentver to (do shell script "defaults read " & (quoted form of infoplist) & " CFBundleShortVersionString")
                if not (interver = currentver) then
                    activate
                    display alert "A new version of openinstallcreator is available. Go to the GitHub page to download it now." message "Always update to new versions of openinstallcreator to have the latest features as well as bugs fix. You won't be able to use the app if you're using an older version."
                    if the button returned of the result is "OK" then
                        open location "https://github.com/Minh-Ton/openinstallcreator"
                        do shell script "killall openinstallcreator"
                    else
                        do shell script "killall openinstallcreator"
                    end if
                end if
            end if
		end if
		
	end applicationWillFinishLaunching:
	
	on applicationShouldTerminate:sender
		-- Insert code here to do any housekeeping before your application quits
		return current application's NSTerminateNow
	end applicationShouldTerminate:
	
	on applicationShouldTerminateAfterLastWindowClosed:sender
		return true
	end applicationShouldTerminateAfterLastWindowClosed:
	
end script
