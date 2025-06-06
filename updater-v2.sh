#!/bin/bash
#WaveRift - BETA Emulators autoinstall script for Linux users
#BSD 3-Clause License
#Copyright (c) 2024, Alex&Indie
#This program is free software: you can redistribute it and/or modify
#it under the terms of the BSD 3-Clause License under written permission.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

[ -d "$HOME/Apps" ] || mkdir -p "$HOME/Apps"
notify() { notify-send -a "Application Updater" "$1" && echo "$1"; }

check_modification_time() {
    local file_path=$1
    local local_modification_time=$(stat -c %Y "$file_path")
    local remote_modification_time=$(curl -sI "${url[0]}" | awk '/^Last-Modified:/ {print $2 " " $3 " " $4}')
    
    # Compare modification times
    if [[ $local_modification_time -lt $(date -d "$remote_modification_time" +%s) ]]; then
        echo "true"  # Remote file is newer
    else
        echo "false"  # Local file is newer or same
    fi
}

download_notify() {
    cd "$HOME/Apps" || exit
    local app_name=$1
    local url
    local file_name
    
    case $app_name in
        Citron)
            mapfile -t urls < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/Samueru-sama/Citron-AppImage-test/releases | \
                    jq -r '[.[] | select(.tag_name == "nightly")][].assets[] | select(.browser_download_url | test("anylinux-x86_64_v3.AppImage")) | .browser_download_url')
            file_name="Citron.AppImage"
            ;;
        Ryujinx)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/Ryubing/Canary-Releases/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("x64.AppImage")) | .browser_download_url')
            file_name="Ryujinx.AppImage"
            ;;
        Cemu)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/cemu-project/Cemu/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("AppImage")) | .browser_download_url')
            file_name="Cemu.AppImage"
            ;;
        Panda3DS)
            url="https://nightly.link/wheremyfoodat/Panda3DS/workflows/Qt_Build/master/Linux%20executable.zip"
            file_name="Panda3DS.zip"
            ;;
        DolphinDev)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/qurious-pixel/dolphin/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("AppImage")) | .browser_download_url')
            file_name="DolphinDev.AppImage"
            ;;
        RMG)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/Rosalie241/RMG/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("AppImage")) | .browser_download_url')
            file_name="RMG.AppImage"
            ;;
        melonDS)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/melonDS-emu/melonDS/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("linux_x64")) | .browser_download_url')
            file_name="melonDS.zip"
            ;;
        SkyEmu)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/skylersaleh/SkyEmu/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("Linux")) | .browser_download_url')
            file_name="SkyEmu.zip"
            ;;
        mGBAdev)
            url="https://s3.amazonaws.com/mgba/mGBA-build-latest-appimage-x64.appimage"
            file_name="mGBAdev.AppImage"
            ;;
        mandarine)
            url="https://nightly.link/mandarine3ds/mandarine/workflows/build/master/linux-appimage.zip"
            file_name="mandarine.zip"
            ;;
        azahar)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/azahar-emu/azahar/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("appimage")) | .browser_download_url')
            file_name="azahar.tar.gz"
            ;;
        gearboy)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/drhelius/Gearboy/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("ubuntu")) | .browser_download_url')
            file_name="gearboy.zip"
            ;;
        bsnes)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/bsnes-emu/bsnes/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("ubuntu")) | .browser_download_url')
            file_name="bsnes.zip"
            ;;
        sudachi)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/emuplace/sudachi.emuplace.app/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("linux")) | .browser_download_url')
            file_name="sudachi.7z"
            ;;
        snes9x)
            mapfile -t url < <(curl -s -H "Accept: application/vnd.github+json" -G -d 'per_page=1' https://api.github.com/repos/snes9xgit/snes9x/releases | \
                    jq -r '.[].assets[] | select(.browser_download_url | test("AppImage")) | .browser_download_url')
            file_name="snes9x.AppImage"
            ;;
        *)
            ;;
    esac

    notify "Checking for updates for $app_name..." # Debugging output

    local download_required=false

    # Check if the file exists and if it's older than the remote file
    if [[ ! -f "$HOME/Apps/$file_name" || $(check_modification_time "$HOME/Apps/$file_name") == "true" ]]; then
        download_required=true
    fi

    if [[ "$download_required" == true ]]; then
        notify "Updating $app_name..."  # Debugging output
        curl -s -L -o "$HOME/Apps/$file_name" "${url[0]}"
        if [ $? -eq 0 ]; then
            notify "Update successful: $app_name"
            # Extract and set permissions
            case $app_name in
                Cemu | DolphinDev | RMG | mGBAdev | snes9x | Citron | Ryujinx)
                    chmod +x "$HOME/Apps/$file_name"
                    ;;
                Panda3DS | melonDS | SkyEmu)
                    7z x "$HOME/Apps/$file_name" -y
                    mv -f "$HOME/Apps/Alber-x86_64.AppImage" "$HOME/Apps/Panda3DS.AppImage" && chmod +x "$HOME/Apps/Panda3DS.AppImage"
                    chmod +x "$HOME/Apps/$app_name"
                    ;;
                gearboy | bsnes | sudachi)
                    7z x "$HOME/Apps/$file_name" -o* -y
                    chmod +x "$HOME/Apps/$app_name/$app_name" "$HOME/Apps/$app_name/$app_name-cmd" "$HOME/Apps/$app_name/tzdb2nx" "$HOME/Apps/$app_name/bsnes-nightly/$app_name"
                    ;;
                azahar)
                    [ -d "$HOME/Apps/$app_name" ] || mkdir -p "$HOME/Apps/$app_name"
                    tar xf "$HOME/Apps/$file_name" -C "$HOME/Apps/Azahar" --strip-components=1
                    chmod +x "$HOME/Apps/$app_name/$app_name.AppImage" "$HOME/Apps/$app_name/$app_name-room.AppImage"
                    ;;
                mandarine)
                    [ -d "$HOME/Apps/$app_name" ] || mkdir -p "$HOME/Apps/$app_name"
                    7z x "$HOME/Apps/$file_name" -y
                    mv -f "$HOME/Apps/$app_name-linux-appimage-*.tar.gz" "$HOME/Apps/$app_name.tar.gz"
                    tar xf "$HOME/Apps/$app_name.tar.gz" -C "$HOME/Apps/$app_name" --strip-components=1 
                    rm -f "$HOME/Apps/$app_name.tar.gz"
                    chmod +x "$HOME/Apps/mandarine/$app_name.AppImage" "$HOME/Apps/mandarine/$app_name-qt.AppImage" "$HOME/Apps/mandarine/$app_name-room.AppImage"
                    ;;
                *)
                    ;;
            esac
        else
            notify "Update failed: $app_name"
        fi
    else
        notify "$app_name is already up to date."
    fi
}

#Flatpak
#------------
notify "Flatpak updating"
flatpak update -y --noninteractive | sed -e '/Info\:/d' -e '/^$/d'

# Update applications
# -------------------
download_notify Cemu
download_notify Citron
download_notify Ryujinx
download_notify sudachi
download_notify Panda3DS
download_notify DolphinDev
download_notify RMG
download_notify melonDS
download_notify SkyEmu
download_notify mGBAdev
download_notify azahar
download_notify gearboy 
download_notify bsnes 
download_notify snes9x
download_notify mandarine
