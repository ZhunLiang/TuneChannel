#!/bin/perl

#INPUT
#Input order: director folder_prefix .gro, .top, detaBin, bulk density, delete ratio
#like : perl bash_MoS2.sh /home/lz/lz/Simulation/MoS2/build/1T-MoS2/ 1T_MoS2_ @Gro[$i] @Top[$i] $DetaBin $BulkDens $Delete
#main.pl order: perl main.pl @Gro[$i] @Top[$i] $DetaBin $BulkDens $Delete

$Dir_code=`pwd`;
chomp($Dir_code);

sub GetFolder{                                                                                                                                             
  my @temp;                                                                                                                                                
  if($_[0]){                                                                                                                                               
    chdir $_[0];                                                                                                                                           
    @folder=<{$_[1]*/}>;                                                                                                                                        
    foreach $folder(@folder){                                                                                                                              
      @temp = (@temp,"$_[0]$folder");                                                                                                                      
    }                                                                                                                                                      
    chdir $Dir_code;                                                                                                                                      
  }                                                                                                                                                        
  return @temp;                                                                                                                                            
}

@folder=GetFolder($ARGV[0],$ARGV[1]);

foreach $folder(@folder){
  system "cp *.sh *.py *.pl *.mdp $folder";
  chdir $folder;
  system "perl main.pl $ARGV[2] $ARGV[3] $ARGV[4] $ARGV[5] $ARGV[6]";
  system "rm -f bash.sh bash_MoS2.sh bash_multi.sh *.py *.sh *.pl STANDARD_EM.mdp STANDARD_NVT.mdp em.mdp initial.mdp tune.mdp";
  #system "rm -f bash.sh bash_MoS2.sh bash_multi.sh *.py *.sh *.pl STANDARD_EM.mdp STANDARD_NVT.mdp em.mdp";
  chdir $Dir_code;
}


#for($i=0;$i<$TDir;$i+=1){
#  system "cp *.sh *.py *.pl *.mdp @Prex[$i]";
#  chdir @Prex[$i];
#  system "perl main.pl @Gro[$i] @Top[$i] $DetaBin $BulkDens $Delete";                  
#  system "rm -f bash.sh bash_multi.sh *.py *.sh *.pl STANDARD_EM.mdp STANDARD_NVT.mdp em.mdp initial.mdp tune.mdp";  
#  chdir $Dir_code;
#}
