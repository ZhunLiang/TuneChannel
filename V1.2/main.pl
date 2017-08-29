#!/bin/perl
#need add work direction
#change function with input parameter
#need write bash.sh like BuildChannel
###############Initial#################

$Python = "\\/opt\\/python\\/bin\\/python";
$Gromacs = "";
@sh_files=<{*.sh}>;
foreach $sh_files(@sh_files){
  system "sed -i 's/PYTHON/$Python/g' $sh_files";
  system "sed -i 's/GROMACS/$Gromacs/g' $sh_files";
}

###############Get MSD Parameter############################
sub GetMSD{
    my @TEMP = split/\s+/,`grep $_[0] MSD_out.dat`;
    my $TEMP_num = @TEMP;
    my @Out;
    for($i=1;$i<$TEMP_num;$i=$i+1){
        $j=$i-1;
        @Out[$j] = @TEMP[$i];
    }
    return @Out;
}

#control parameter
$RUNEM=1;
$RUNINITIAL=1;
$RUNTIME=1;
$MAXRUN=6;
$COMBINE=1;
##############GetPara############################
require('pretreat.sh');

###############Load Function################################
require('function.sh');

###############     Run    ################################
if ($RUNEM==1){
GeneraNdx("end.gro");
RunGmx("em",0);
}

if ($RUNINITIAL==1){
GeneraNdx("end.gro");
RunGmx("initial",0);
}

if ($RUNTIME==1){
GeneraNdx("end.gro");
RunGmx("tune",1);
$RUNTIME += 1;
}

while($RUNTIME>1 && $RUNTIME<$MAXRUN){
    $TotalDeleta = CalDelNum("end.top");
    if($TotalDeleta!=0){
        system "rm dens.xvg";
        GeneraGro();
        GeneraTop("end.top");
        GeneraNdx("end.gro");
        RunGmx("tune",1);
    }
    $RUNTIME=$RUNTIME+1;
}

GeneraNdx("end.gro");
RunGmx("initial",0);

if($COMBINE==1){
    require('combine.sh');
}
