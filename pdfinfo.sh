#!/usr/bin/env bash
# -------------------------------------------
#       @script: pdfinfo.sh
#         @link: https://github.com/NRZCode/pdfinfo
#  @description: ---
#      @license: GNU/GPL v3.0
#      @version: 0.0.1
#       @author: NRZ Code <nrzcode@protonmail.com>
#      @created: 10/03/2023 01:50
#
# @requirements: yad
#         @bugs: ---
#        @notes: ---
#     @revision: ---
# -------------------------------------------
# Copyright (C) 2023   NRZ Code <nrzcode@protonmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# -------------------------------------------
# USAGE
#   pdfinfo.sh [OPTIONS]
# -------------------------------------------
version='0.0.1'
usage='  Usage: pdfinfo.sh [OPTIONS]

DESCRIPTION
  Script Description

OPTIONS
  General options
    -h, --help        Print this help usage and exit
    -v, --version     Display version information and exit
'

# functions ---------------------------------
getinfo() {
    filename=$1
    [[ -f $filename ]] \
        || filename=$(yad --title "Selecione um arquivo pdf" --file-selection --mime-filter="application/pdf") \
        || return
    info=$(pdfinfo "$filename")
    signature=$(pdfsig "$filename")
    printf '%s\n' "1:$filename" "3:${info//$'\n'/\\n}" "4:${signature//$'\n'/\\n}"
}
export -f getinfo

main() {
    # FIXME: filechooser afeta apenas o field fn, não o yad --file-selection
    #     gsettings set org.gtk.Settings.FileChooser window-size '(600, 480)'
    result=$(yad --image application-pdf --window-icon application-pdf \
        --always-print-result \
        --buttons-layout end --button 'Abrir arquivo!gtk-open:3' --button 'Ok!gtk-ok:0' \
        --title 'PDF Info' --width 700 --height 550 --center --form \
        --field 'Arquivo:FL' '' --mime-filter='application/pdf' \
        --field 'Carregar informações!gtk-refresh:BTN' '@bash -c "getinfo %1"' \
        --field 'Info:TXT' '' \
        --field 'Assinatura:TXT' ''
    )
    if [[ $? -eq 3 ]]; then
        IFS='|' read filename _ <<< "$result"
        [[ -f $filename ]] && xdg-open "$filename"
    fi
}

# main --------------------------------------
main "$@"
