#!/bin/sh
set -e

config="$HOME/.config/weight-tracker/config"

height=
if [ -e "$config" ]; then
  . "$config"
fi

datafile="$(mktemp)"
script="$(mktemp)"
trap 'rm -f "$datafile" "$script"' 0 1 2 13 15

sqlite3 "$HOME/.local/share/weight-tracker/weight.db" "
  select strftime('%s', time, 'localtime'), weight from weights order by time;
" >"$datafile"

cat >>"$script" <<E
  set term png transparent size 950, 400 enhanced
  set output '$1'

  set xdata time
  set timefmt '%s'
  set format x '%Y-%m-%d'

  set ylabel 'kg'

  set xtics rotate 86400
  set grid
  set datafile separator '|'
E

if [ -z "$height" ]; then
  cat >>"$script" <<E
    plot '$datafile' using 1:2 notitle with points, \
         '$datafile' using 1:2 notitle smooth bezier with lines
E
else
  cat >>"$script" <<E
    set y2tics
    set y2label 'BMI'

    plot '$datafile' using 1:2 notitle with points, \
         '$datafile' using 1:2 title "weight" smooth bezier with lines, \
         '$datafile' using 1:(\$2/$height**2) axes x1y2 title "BMI" smooth bezier with lines
E
fi

gnuplot "$script"
