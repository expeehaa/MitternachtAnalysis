set term pngcairo size 1280,720 enhanced font 'Verdana,9'

ticx(n) = (GPVAL_X_MAX-GPVAL_X_MIN)/n

set style line 11 lc rgb '#606060' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#606060' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb 'blue' pt 6 ps 0.5 lt 1 lw 2

set title "Dailymoney per week"
set xlabel "Week starting at date"
set ylabel "Times Dailymoney was collected"

set xdata time
set timefmt "%Y-%m-%d"
set format x "%Y-%m-%d"

set yrange[0:]

set datafile separator ","

set output ARG2

set table $Dummy
  plot ARG1 u 1:2 w l ls 1 title "Dailymoney per week"
unset table
set xtics ticx(4.0)
replot
