#!/bin/bash

function red() {
    echo -e "\033[1;31m$1\033[1;0m"
}

function green() {
    echo -e "\033[1;32m$1\033[1;0m"
}

function yellow() {
    echo -e "\033[1;33m$1\033[1;0m"
}

function blue() {
    echo -e"\033[1;34m$1\033[1;0m"
}

function magenta() {
    echo -e "\033[1;35m$1\033[1;0m"
}

function cyan() {
    echo -e "\033[1;36m$1\033[1;0m"
}

function double_underline() {
    echo -e "\033[1;21m$1\033[1;0m"
}

function bold() {
    echo -e "\033[1;1m$1\033[1;0m"
}

function dim() {
    echo -e "\033[1;2m$1\033[1;0m"
}

function italic() {
    echo -e "\033[1;3m$1\033[1;0m"
}

function underline() {
    echo -e "\033[1;4m$1\033[1;0m"
}

function previous_line() {
    echo -e "\033[1;F"
}

function next_line() {
    echo -e "\033[1;E"
}

RETURN=NULL

function read_keys() {
    escape_char=$(printf "\u1b")
    read -rsn1 mode # get 1 character
    if [[ $mode == $escape_char ]]; then
        read -rsn2 mode # read 2 more chars
    fi
    RETURN=$mode
}

function print_yes_no_menu() {
    local pos
    pos=$1
    if [[ "$pos" == 1 ]]; then
        echo -e "\033[1;1F\033[1;1F$(yellow ">")  $(cyan "Yes")"
    else
        cyan "\033[1;1F\033[1;1F   Yes"
    fi
    if [[ "$pos" == 2 ]]; then
        echo -e "$(yellow ">")  $(cyan "No")"
    else
        cyan "   No"
    fi
}

function install_grub_theme() {
    bold "$(underline "Installing grub theme...")"
    if [[ ! -d "/boot/grub/themes" ]]; then
        cyan "Creating /boot/grub/themes"
        mkdir /boot/grub/themes
    fi
    if [[ -d "/boot/grub/themes/corpauration" ]]; then
        cyan "Removing old installation of corpauration theme"
        rm -rf /boot/grub/themes/corpauration
    fi
    cp -r grub /boot/grub/themes/corpauration
    green "Files copied!"
    if [[ ! `grep -E "^GRUB_THEME=/boot/grub/themes/corpauration/" /etc/default/grub` ]]; then
        local choice
        local key
        choice=1
        key=0
        magenta "Do you want to modify /etc/default/grub to set corpauration theme in your config?"
        echo " "
        echo " "
        print_yes_no_menu 1
        while [[ "$key" != "" ]]; do
            read_keys
            case $mode in
                '[A') if [[ "$choice" > 1 ]]; then choice=$((choice - 1)); fi ;;
                '[B') if [[ "$choice" < 2 ]]; then choice=$((choice + 1)); fi ;;
                '') key="" ;;
            esac
            print_yes_no_menu $choice
        done
        case $choice in
            '1')
                if [[ `grep -E "^GRUB_THEME=" /etc/default/grub` ]]; then
                    local g
                    g=$(cat /etc/default/grub)
                    echo "$g" | sed "s/^GRUB_THEME=.*/GRUB_THEME=\/boot\/grub\/themes\/corpauration\/theme.txt/" > /etc/default/grub
                else
                    echo "GRUB_THEME=/boot/grub/themes/corpauration/theme.txt" >> /etc/default/grub
                fi
            ;;
            '2') exit 0 ;;
        esac
    fi
    cyan "Updating grub config"
    grub-mkconfig -o /boot/grub/grub.cfg
    green "Done!"
    exit 0
}

function print_main_menu() {
    local pos
    pos=$1
    if [[ "$pos" == 1 ]]; then
        echo -e "\033[1;1F\033[1;1F$(yellow ">")  $(cyan "Install grub theme")"
    else
        cyan "\033[1;1F\033[1;1F   Install grub theme"
    fi
    if [[ "$pos" == 2 ]]; then
        echo -e "$(yellow ">")  $(cyan "Install plymouth theme")"
    else
        cyan "   Install plymouth theme"
    fi
}

function main() {
    if [ "$EUID" -ne 0 ]; then
        red "Please run as root"
        exit 1
    fi
    local choice
    local key
    choice=1
    key=0
    bold "$(double_underline "CORPAURATION THEME INSTALLER")"
    echo " "
    echo " "
    print_main_menu 1
    while [[ "$key" != "" ]]; do
        read_keys
        case $mode in
            '[A') if [[ "$choice" > 1 ]]; then choice=$((choice - 1)); fi ;;
            '[B') if [[ "$choice" < 2 ]]; then choice=$((choice + 1)); fi ;;
            '') key="" ;;
        esac
        print_main_menu $choice
    done
    case $choice in
        '1') install_grub_theme ;;
        '2') install_plymouth_theme ;;
    esac
}

main
