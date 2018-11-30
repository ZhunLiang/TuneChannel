#!/bin/perl
#INPUT
#Input order: directory, folder name prefix, .gro, .top, detabin, bulk dens, delete ratio

$Dir_code=`pwd`;
chomp($Dir_code);

chdir $ARGV[0];
@folder=<{$ARGV[1]*/}>;

chdir $Dir_code;

$test_folder = "$ARGV[0]@folder[0]";
if(-e $test_folder){
  print "$ARGV[0]\n";
}else{
  print "#-------ERROR-------#\n";
  print "No director $ARGV[0] or $ARGV[0] should end at / \n";
  print "#--------end--------#\n";
  exit();
}

foreach $temp_folder(@folder){
  $temp="$ARGV[0]$temp_folder";
  system "cp *.sh *.py *.pl *.mdp $temp";
  chdir $temp;
  system "perl main.pl $ARGV[2] $ARGV[3] $ARGV[4] $ARGV[5] $ARGV[6]";
  system "rm -f *.sh *.py *.pl *.mdp";
  chdir $Dir_code;
}

