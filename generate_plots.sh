#!/bin/bash

gnuplot -c plotscripts/dailymoney_per_week.p data/dailymoney_per_week.csv plots/dailymoney_per_week.png 
gnuplot -c plotscripts/dailymoney_per_month.p data/dailymoney_per_month.csv plots/dailymoney_per_month.png 
