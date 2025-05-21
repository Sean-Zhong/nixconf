{ pkgs }:
    pkgs.writeShellScriptBin "mountdata" ''
    notify-send "antivirus-scan" "starting scan..."

    log_file=$HOME/.clamscan.log
    cpulimit -l 30 -- clamscan -iv --max-filesize=100M --max-scansize=100M -r "$HOME" -l $log_file
    result_code=$?
    title=

    [ $result_code -eq 1 ] && title="antivirus-scan found virus"
    [ $result_code -gt 1 ] && title="antivirus-scan failed"
    [ "$title" != "" ] && notify-send --urgency=critical "$title" "See $log_file for details" && exit 1
    exit 0
''
