#!/bin/perl
#INPUT
#Input order: directory, electrode X_Y_Z, TotalZLong,DeletaRation,Wall_gro,Wall_top,Ion_gro,Ion_top

@Dir1=("/home/lz/lz/Simulation/MXene_MD");
@Dir2_a=("EmimTf2N"); #Ion
#@Dir2_b=("Ti3C2","Ti3C2IF2","Ti3C2IOH2"); #Electrode
@Dir2_b=("Ti3C2IF2","Ti3C2IOH2");
#@Dir3=("NoRotate","Rotate_X","Rotate_XY");
@Dir3=("Rotate_X","Rotate_XY");
#@Dir3=("Rotate_XY");
$DetaBin=0.01;
$BulkDens=1545;
$Delete="-1_1_1";
$Dir_code=`pwd`;
chomp($Dir_code);

$NDir1=@Dir1;$NDir2_a=@Dir2_a;$NDir2_b=@Dir2_b;$NDir3=@Dir3;
#print "@Dir1\n@Dir2_a\n@Dir2_b\n@Dir3\n";
#print "$NDir1\n$NDir2_a\n$NDir2_b\n$NDir3\n";
$TDir=$NDir1*$NDir2_a*$NDir2_b*$NDir3;
$Ind=0;
for($a=0;$a<$NDir1;$a+=1){
  $Prex1=@Dir1[$a];
  for($b=0;$b<$NDir2_a;$b+=1){
    $Prex2="$Prex1/@Dir2_a[$b]";
    for($c=0;$c<$NDir2_b;$c+=1){
      $Prex3="$Prex2\_@Dir2_b[$c]";
        for($d=0;$d<$NDir3;$d+=1){
        $Prex4="$Prex3/@Dir3[$d]/";                                                                             
        @Prex[$Ind]=$Prex4;                                                                                     
        @Gro[$Ind]="Channel.gro";
        @Top[$Ind]="Channel.top"; 
        $Ind = $Ind + 1;                                                                                        
      }
    }
  }
}

for($i=0;$i<$TDir;$i+=1){
  system "cp *.sh *.py *.pl *.mdp @Prex[$i]";
  chdir @Prex[$i];
  system "perl main.pl @Gro[$i] @Top[$i] $DetaBin $BulkDens $Delete";                  
  system "rm -f bash.sh bash_multi.sh *.py *.sh *.pl STANDARD_EM.mdp STANDARD_NVT.mdp em.mdp initial.mdp tune.mdp";  
  chdir $Dir_code;
}
