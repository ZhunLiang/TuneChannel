#!/bin/perl
#INPUT
#Input order: directory, .gro, .top, detaBin, bulk density, delete ratio

system "cp *.sh *.py *.pl *.mdp $ARGV[0]";
chdir $ARGV[0];
system "perl main.pl $ARGV[1] $ARGV[2] $ARGV[3] $ARGV[4] $ARGV[5]"; 
system "rm -f *.mdp *.sh *.pl *.py *.xvg";
#system "rm -f *.sh *.pl *.py";
