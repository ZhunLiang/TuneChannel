#!/bin/perl
$GroFile=$ARGV[0];
$TopFile=$ARGV[1];
$DetaBin=$ARGV[2];
$BulkDens=$ARGV[3];
@MoleName=("TiC","Emi","f2N");   #mole name in .top and the same order
@MoleAtomNum=(10,19,15);
@DeleteNum=(0 ,0, 0); #It should be positive
@DeleteRatio=(0,1,1);
$ChannelLong=8;
$OutTop="end.top";
$MoleTypeNum=@MoleName;
$Kmax=0.99;
$Kmin=0.97;
#print "$Residu\t$IndexName\n";
$RUNTIME=0;
@GroXYZ=split/\s+/,`tail -1 $GroFile`;
#print "@GroXYZ[3]\t$DetaBin\n";
$BinNum=@GroXYZ[3]/$DetaBin;
#Generate New top file
sub GeneraTop {
    for($i=0;$i<$MoleTypeNum;$i=$i+1){
    	@temp=split/\s+/,`grep -w @MoleName[$i] end.top`;
    	@MoleNum[$i]=@temp[1];                          #obtain now topol.top number
    	@NewMoleNum[$i]=@MoleNum[$i]-@DeleteNum[$i];    #obtain new topol.top number
    	$match="@MoleName[$i]\\s\\+\\([0-9]\\+\\)";
    	$replace="@MoleName[$i]\t@NewMoleNum[$i]";
        if($i==0){system "sed 's/$match/$replace/g' end.top > start.top";} #generate new topol.top
    	else{system "sed -i 's/$match/$replace/g' start.top";}
	#system "rm end.top";
    	#print "$match\t$replace\n";
    	#print "@MoleNum[$i]\t@NewMoleNum[$i]\n";
    }
    #system "rm end.top";
}

#Generate New gro file
sub GeneraGro{
     StrPara();
     #print "$DeleteNumT\n";
     #print "$AtomNumT\n$MoleNumT\n$DeleteNumT\n";
    `/opt/python/bin/python ~/Simulation/Code/Tune_Channel/DelMole3.py -i end.gro -a $AtomNumT -n $MoleNumT -d $DeleteNumT -o start.gro`;
    system "rm end.gro";
    system "rm end.top";
}

#Generate New index file
sub GeneraNdx{
    for($i=1;$i<$MoleTypeNum;$i=$i+1){
    	if($i==1){
        	$Residu=@MoleName[$i];
        	$temp=uc @MoleName[$i];
        	$IndexName=$temp;
	}
    	else{
         	$Residu="$Residu @MoleName[$i]";
        	$temp=uc @MoleName[$i];
         	$IndexName="$IndexName\_$temp";
	}
    }
    #print "$Residu\t$IndexName\n";
    `echo -e "r $Residu\nq" | make_ndx -f start.gro -o index.ndx`;   #make_ndx
}

sub RunGmx{
    system "gmx grompp -f start.mdp -c start.gro -p start.top -n index.ndx -maxwarn 1 -o end.tpr";
    system "gmx mdrun -s end.tpr -v -deffnm end -ntmpi 16";
    if($_[0] == 1){
	system "echo 0 | gmx density -f end.trr -s end.tpr -sl $BinNum -o dens.xvg";
	system "mv dens.xvg ../";
    }
    system "echo 0 | gmx trjconv -f end.gro -s end.tpr -pbc mol -o end.gro";
    system "cp end.gro ../;cp start.top ../end.top";
}

sub StrPara{
    $AtomNumT="";
    $MoleNumT="";
    $DeleteNumT="";
    $DeleteRatioT="";
    for($i=0;$i<$MoleTypeNum;$i=$i+1){
        @temp=split/\s+/,`grep -w @MoleName[$i] end.top`;
        @MoleNum[$i]=@temp[1];
    	$AtomNumT="$AtomNumT @MoleAtomNum[$i]";
    	$MoleNumT="$MoleNumT @MoleNum[$i] ";
    	$DeleteNumT="$DeleteNumT @DeleteNum[$i]";
    	$DeleteRatioT="$DeleteRatioT @DeleteRatio[$i]";
    }
    $TTT='"';
    $AtomNumT="$TTT$AtomNumT$TTT";
    $MoleNumT="$TTT$MoleNumT$TTT";
    $DeleteNumT="$TTT$DeleteNumT$TTT";
    $DeleteRatioT="$TTT$DeleteRatioT$TTT";
}

sub CalDelNum{
    StrPara();
    #print "$MoleNumT\n$DeleteRatioT\n$BulkDens\n$BinNum\n";
   `/opt/python/bin/python ~/Simulation/Code/Tune_Channel/DensXvgs.py -i dens.xvg -n $MoleNumT -d $DeleteRatioT -b $BulkDens -B $BinNum -C $ChannelLong -T @GroXYZ[3] --Kmax $Kmax --Kmin $Kmin >> PyOut`;
   @Delete=split/\s+/,`tail -1 PyOut`;
   $TotalDeleta=0;
   for($i=0;$i<$MoleTypeNum;$i=$i+1){
       @DeleteNum[$i]=@Delete[$i];
       $TotalDeleta=$TotalDeleta+@DeleteNum[$i];
   } 
}

if ($RUNTIME==0){
    #em
    system "mkdir em/";
    system "cp $GroFile em/start.gro;cp $TopFile em/start.top;cp *.itp em/;cp em.mdp em/start.mdp";
    chdir "em/";
    GeneraNdx();
    RunGmx(0);
    chdir "../";
    system "rm -rf em/";
    #Initial
    system "mkdir Initial/";
    system "mv end.gro Initial/start.gro;cp end.top Initial/start.top;cp *.itp Initial/";
    system "sed 's/DDDTTT/0.001/g' tune_channel.mdp > start.mdp";
    system "sed -i 's/NSTEPS/5000/g' start.mdp;mv start.mdp Initial/";
    chdir "Initial/";
    GeneraNdx();
    RunGmx(0);
    system "cp index.ndx ../";
    chdir "../";
    system "rm -rf Initial/";
    $RUNTIME=$RUNTIME+1;
}
system "sed 's/DDDTTT/0.002/g' tune_channel.mdp > start.mdp";
system "sed -i 's/NSTEPS/1000000/g' start.mdp";
if ($RUNTIME==1){
    system "mkdir tune/";
    system "mv end.top tune/start.top;mv end.gro tune/start.gro;cp *.itp start.mdp tune;mv index.ndx tune/";
    chdir "tune/";
    RunGmx(1);
    chdir "../";
    system "rm -rf tune/";
    $RUNTIME=$RUNTIME+1;
}
while($RUNTIME>1 && $RUNTIME<5){
    CalDelNum();
    if($TotalDeleta!=0){
        system "mkdir tune/";
        system "rm dens.xvg";
        system "cp end.gro end.top tune/;cp *.itp start.mdp tune/";
        chdir "tune/";
        GeneraTop();
        GeneraGro();
        GeneraNdx();
        RunGmx(1);
        chdir "../";
        system "rm -rf tune/";
    }
    $RUNTIME=$RUNTIME+1;
}
