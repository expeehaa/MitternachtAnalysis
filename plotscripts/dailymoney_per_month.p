set term pngcairo size 640,640 enhanced font 'Verdana,9'

ticx(n) = (GPVAL_X_MAX-GPVAL_X_MIN)/n

set style line 11 lc rgb '#606060' lt 1
set border 3 back ls 11
set tics nomirror
set style line 12 lc rgb '#606060' lt 0 lw 1
set grid back ls 12
set style line 1 lc rgb 'blue' pt 6 ps 0.5 lt 1 lw 2

set title "Dailymoney per month"
set xlabel "Month"
set ylabel "Times Dailymoney was collected"

set xdata time
set timefmt "%Y-%m"
set format x "%Y-%m"

set yrange[0:]

set datafile separator ","

set output ARG2

set table $Dummy
  plot ARG1 u 1:2 w l ls 1 title "Dailymoney per month"
unset table
set xtics ticx(4.0)
replot
