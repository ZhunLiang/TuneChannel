#!/bin/perl
#need add work direction
#change function with input parameter
#need write bash.sh like BuildChannel

sub GetTopNum{
  my $count = 0;
  my ($temp,@temp2,@Out);
  for(my $i=0;$i<$TopTypeNum;$i+=1){
    $temp = `grep -w @Name_Out[$i] $_[0]`;
    if($temp){
      @temp2 = split/\s+/,$temp;
      @Out[$count] = @temp2[1];
      $count += 1;
    }
  }
  return @Out;
}

sub GeneraNdx{   #change with @Ratio,also need change .mdp file
    #$_[0] input gro
    my ($Solid,$Liquid,$temp);
    $Solid="";
    $Liquid="";
    for($i=0;$i<$TopTypeNum;$i=$i+1){
    	if(@Ratio[$i]<0){
        	$Solid="$Solid @Name_Out[$i]";
	}
    	else{
         	$Liquid="$Liquid @Name_Out[$i]";
	}
    }
    `echo -e "r $Solid\nq" | GROMACSgmx make_ndx -f $_[0] -o index_temp.ndx`; 
    `echo -e "r $Liquid\nq" | GROMACSgmx make_ndx -f $_[0] -n index_temp.ndx -o index.ndx`;
    system "rm -f index_temp.ndx";
}

sub RunGmx{
    system "mkdir $_[0]";
    system "mv end.gro $_[0]/start.gro";
    system "mv end.top $_[0]/start.top";
    system "cp *.itp $_[0]/";
    system "cp $_[0].mdp $_[0]/start.mdp";
    system "mv index.ndx $_[0]/";
    chdir "$_[0]/";
    my $ntomp=32/$_[2];
    system "GROMACSgmx grompp -f start.mdp -c start.gro -p start.top -n index.ndx -maxwarn 1 -o end.tpr";
    #------------ATTENTION--------------#
    # -ntmpi will affect the speed and if wrong #
    system "GROMACSgmx mdrun -s end.tpr -v -deffnm end -ntmpi $_[2] -ntomp $ntomp";
    #system "GROMACSgmx mdrun -s end.tpr -v -deffnm end -ntmpi $_[2]";
    if($_[1] == 1){
        system "echo 0 | GROMACSgmx density -f end.trr -s end.tpr -sl $BinNum -o dens.xvg";
        system "mv dens.xvg ../";
    }
    system "echo 0 | GROMACSgmx trjconv -f end.gro -s end.tpr -pbc mol -o end.gro";
    system "cp end.gro ../;cp start.top ../end.top";
    chdir "../";
    system "rm -rf $_[0]";
}

sub StrPara{
  my $temp="";
  my $n=@_;
  for(my $i=0;$i<$n;$i+=1){
    $temp="$temp @_[$i]";
  }
  my $pre='"';
  my $out="$pre$temp$pre";
  return $out;
}

sub CalDelNum{   #delete area need to change, thus need to Change DensXvgs.py
   my @Top_Out;
   my ($StrMass,$StrTop,$StrRatio);
   @Top_Out = GetTopNum("end.top");
   $StrMass=StrPara(@Mass_Out);$StrTop=StrPara(@Top_Out);$StrRatio=StrPara(@Ratio);
   `PYTHON DensXvgs.py -i dens.xvg -n $StrTop -d $StrRatio -b $BulkDens -m $StrMass -B $BinNum -T $TotalLong --Kmax $Kmax --Kmin $Kmin >> PyOut`;
   @Delete=split/\s+/,`tail -1 PyOut`;
   $TotalDeleta=0;
   for($i=0;$i<$TopTypeNum;$i=$i+1){
       @DeleteNum[$i]=@Delete[$i];
       $TotalDeleta=$TotalDeleta+@DeleteNum[$i];
   } 
   return $TotalDeleta;
}

sub GeneraTop {
    my ($match,$replace);
    my (@NewMoleNum,@Delete_Num,@MoleNum);
    @MoleNum = GetTopNum($_[0]);
    @Delete_Num = GetDelete();
    for($i=0;$i<$TopTypeNum;$i=$i+1){
    	#@MoleNum[$i]                          #obtain now topol.top number
    	@NewMoleNum[$i]=@MoleNum[$i]-@Delete_Num[$i];    #obtain new topol.top number
    	$match="@Name_Out[$i]\\s\\+\\([0-9]\\+\\)";
    	$replace="@Name_Out[$i]\t@NewMoleNum[$i]";
        system "sed -i 's/$match/$replace/g' end.top";
    }
}

#Generate New gro file
sub GeneraGro{
    my ($AtomNumT,$MoleNumT,$DeleteNumT);
    my (@TopNum,@DeleteNum);
    @TopNum=GetTopNum("end.top");@DeleteNum=GetDelete();
    $AtomNumT=StrPara(@Num_Out);$MoleNumT=StrPara(@TopNum);$DeleteNumT=StrPara(@DeleteNum);
    `PYTHON DelMole3.py -i end.gro -a $AtomNumT -n $MoleNumT -d $DeleteNumT -o start.gro`;
    #print "$AtomNumT\n$MoleNumT\n$DeleteNumT\n";
    system "mv start.gro end.gro";
}

sub GetDelete{
  my @temp;
  my $temp2;
  $temp2 = `tail -1 PyOut`;
  @temp = split/\s+/,$temp2;
  return @temp;
}

1;
