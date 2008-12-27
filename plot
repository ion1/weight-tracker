#!/bin/sh
set -e

cd "$(dirname "$0")"

datafile="$(mktemp)"
trap 'rm -f "$datafile"' 0 1 2 13 15

sqlite3 weight.db "
  select strftime('%s', time, 'localtime'), weight from weights order by time;
" >"$datafile"

printf "%s" "
  set term png transparent size 950, 400 enhanced
  set output '$1'

  set xdata time
  set timefmt '%s'
  set format x '%Y-%m-%d'

  set ylabel 'kg'

  set xtics rotate 86400
  set grid

  set datafile separator '|'
  plot '$datafile' using 1:2 notitle with points, \
       '$datafile' using 1:2 notitle smooth bezier with lines
" | gnuplot
