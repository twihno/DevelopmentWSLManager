Function Get-YesNoAnswer($question)
{
    $msg = $question + " [y/n]"
    do {
        $response = Read-Host -Prompt $msg
        if ($response -eq 'y') {
            return $true
        }
    } until ($response -eq 'n')
    return $false
}

Function Get-DistroImage($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = “tar files | *.tar”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
}

Function Get-ValidDistroImageVisual()
{
    Do {
        $error_encountered = $false

        $wsl_image_path = Get-DistroImage -initialDirectory $PWD

        if($wsl_image_path -eq ""){
            Write-Host "Selection aborted. Exiting script"
            exit
        }

    } While ($error_encountered)

    return $wsl_image_path
}

Function Get-ValidDistroImageCMD()
{
    Do {
        $error_encountered = $false

        $wsl_image_path = Read-Host "Enter the path to the .tar with the WSL image you want to install"
        $image_path_existst = Test-Path -Path $wsl_image_path -PathType Leaf
        
        if(!($image_path_existst)){
            $error_encountered = $true
            Write-Host "ERROR: image file not found"
        }

        if(!([IO.Path]::GetExtension($wsl_image_path) -eq '.tar')){
            $error_encountered = $true
            Write-Host "ERROR: file not a .tar file"
        }

    } While ($error_encountered)

    return $wsl_image_path
}

Function Get-InstallPath()
{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.SelectedPath
}

Function Get-ValidInstallPathVisual()
{
    Do {
        $error_encountered = $false

        $wsl_install_path = Get-InstallPath

        if($wsl_install_path -eq $null){
            Write-Host "Selection aborted. Exiting script"
            exit
        }

    } While ($error_encountered)

    return $wsl_install_path
}

Function Get-ValidInstallPathCMD()
{
    Do {
        $error_encountered = $false

        $wsl_install_path = Read-Host "Enter the path where you want to install the WSL instance"
        $install_path_existst = Test-Path -Path $wsl_install_path -PathType Container
        
        if(!($install_path_existst)){
            $error_encountered = $true
            Write-Host "ERROR: folder not found"
        }
    } While ($error_encountered)

    return $wsl_install_path
}

#---------------------------------

Write-Host "Development WSL manager (2021-06-09)"
Write-Host "------------------------------------"
Write-Host "DISCLAIMER: This script is not affiliated with Microsoft.`nI just wrote it to make creating and deleting (new) WSL instance easier.`n"

Do {
    $script_mode= Read-Host "Delete existing or create new instance? [del/new]"
} While ($script_mode -notmatch "del|new")

if($script_mode -eq "new"){

    Do {
        $script_interaction_mode= Read-Host "Use graphical windows or only command line? [cmd/ui]"
    } While ($script_interaction_mode -notmatch "cmd|ui")

    # WSL Name
    $wsl_name = Read-Host "Please enter the desired name for the new instance"

    # WSL Version
    # Only allow Version 1 or 2 as input
    Do {
        $wsl_version = Read-Host "Select WSL Version [1/2]"
    } While ($wsl_version -notmatch "1|2")

    # WSL .tar image
    if($script_interaction_mode -eq "cmd"){
        $wsl_image_path = Get-ValidDistroImageCMD
    } else{
        Write-Host "Select the .tar with the WSL image you want to install"
        $wsl_image_path = Get-ValidDistroImageVisual
    }

    # WSL install location
    if($script_interaction_mode -eq "cmd"){
        $wsl_install_path = Get-ValidInstallPathCMD
    } else{
        Write-Host "Select the path where you want to install the WSL instance"
        $wsl_install_path = Get-ValidInstallPathVisual
    }

    Write-Host "`n$("Creating WSL instance *")$wsl_name$("*")"
    
    $wsl_create_return = wsl --import $wsl_name $wsl_install_path $wsl_image_path

    if($wsl_create_return -eq $null){
        Write-Host "`n$("Created WSL instance *")$wsl_name$("*")"

        Write-Host "`nBeginning post-install setup`n"

        Do {
            $dist_type= Read-Host "Please select the type of the distribution [debian-ubuntu/other]"
        } While ($dist_type -notmatch "debian-ubuntu|other")

        if($dist_type -eq "debian-ubuntu"){
            $deb_username = Read-Host "Please enter the desired UNIX username"

            # Add user
            wsl -d $wsl_name adduser $deb_username

            # Add sudo privileges
            wsl -d $wsl_name sudo usermod -a -G sudo $deb_username

            # Set standard user to the new user
            $wsl_conf = "$("printf '[user]\ndefault=")$($deb_username)$("\n' > /etc/wsl.conf")"
            wsl -d $wsl_name /bin/bash -c "`"$wsl_conf`""

            # "Restart" WSL instanfce
            wsl --terminate $wsl_name
        }else{
            Write-Host "Distribution isn't supported by this script. Please perform the post-install setup manually."
        }
    }else{
        Write-Host $wsl_create_return
        Write-Error "unknown error"
    }
    
}else{
    # WSL Name
    $wsl_name = Read-Host "Please enter the name for the instance you want to delete"

    $delete_confirmation = Get-YesNoAnswer("Do you really want to delete " + $wsl_name + "?")

    if($delete_confirmation){
        Write-Host "$("Deleting ")$($wsl_name)"
        wsl --unregister $wsl_name
    }
}

Read-Host -Prompt "`nPress any key to continue..."
