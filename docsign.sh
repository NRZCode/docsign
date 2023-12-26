#!/usr/bin/env bash
# -------------------------------------------
#       @script: docsign.sh
#         @link: https://github.com/NRZCode/docsign
#  @description: Shell interface (yad) to view and validate e-signatures info about document files.
#      @license: GNU/GPL v3.0
#      @version: 0.0.3
#       @author: NRZ Code <nrzcode@protonmail.com>
#      @created: 10/03/2023 01:50
#
# @requirements: yad,poppler-utils
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
#   docsign.sh [OPTIONS]
# -------------------------------------------
version='0.0.3'
usage='  Usage: docsign.sh [OPTIONS]

DESCRIPTION
  View and validate e-signatures info about document files.

OPTIONS
  General options
    -h, --help        Print this help usage and exit
    -v, --version     Display version information and exit
'

# functions ---------------------------------
is_file() [[ -f $1 ]]
export -f is_file

getinfo() {
    local info signature filename=$1
    is_file "$filename" \
        || filename=$(yad --window-icon application-pdf --title 'Selecione um arquivo pdf' --width 800 --height 600 --file --file-selection --mime-filter 'application/pdf')
    # @TODO: select window-icon para file-selection
    is_file "$filename" || return
    info=$(pdfinfo "$filename")
    signature=$(pdfsig "$filename")
    printf '%s\n' "1:$filename" "3:${info//$'\n'/\\n}" "4:${signature//$'\n'/\\n}"
}
export -f getinfo

main() {
    result=$(yad --image application-pdf --window-icon application-pdf \
        --text '<b><span font="20">Informações gerais e de assinatura digital</span></b>' \
        --text-align center \
        --always-print-result --borders 20 \
        --buttons-layout end --button 'Sair!gtk-cancel:1' --button 'Abrir arquivo!gtk-open:3' \
        --title 'PDF Info' --width 700 --height 550 --center --form \
        --field 'Arquivo:FL' '' --mime-filter='application/pdf' \
        --field 'Carregar informações!gtk-refresh:FBTN' '@bash -c "getinfo %1"' \
        --field 'Info:TXT' '' \
        --field 'Assinatura:TXT' ''
    )
    if [[ $? -eq 3 ]]; then
        filename=${result%%|*}
        is_file "$filename" && xdg-open "$filename"
    fi
}

# main --------------------------------------
yad() { /usr/bin/yad "$@"; }
main "$@"
