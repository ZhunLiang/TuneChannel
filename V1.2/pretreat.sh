#!/bin/perl
#INPUT
sub GetInputPara{
  my @temp = split/_/,$_[0];
  return @temp; 
}

sub GetInputFile{
  system "cp $_[0] $_[1]";
}

our $GroFile=$ARGV[0];
our $TopFile=$ARGV[1];
our $DetaBin=$ARGV[2];
our $BulkDens=$ARGV[3];
our @Ratio=GetInputPara($ARGV[4]);


our $Kmax=1.00;
our $Kmin=0.99;
our $Initial_Max_Delete = 80;

our @GroXYZ=split/\s+/,`tail -1 $GroFile`;
our $BinNum=@GroXYZ[3]/$DetaBin;
our $TotalLong = @GroXYZ[3];

GetInputFile($ARGV[0],"end.gro");
GetInputFile($ARGV[1],"end.top");
system "PYTHON GetMSDpara.py";
our @MoleName = GetMSD("NAME");
our @MoleMass = GetMSD("MASS");
our @MoleAtomNum = GetMSD("NUM");
our $MoleTypeNum = @MoleName;
system "rm -f MSD_out.dat";

our (@Name_Out,@Num_Out,@Mass_Out);
for($i=0;$i<$MoleTypeNum;$i+=1){
  $temp = `grep -w @MoleName[$i] end.top`;
  if($temp){
    @Name_Out[$count] = @MoleName[$i];
    @Num_Out[$count] = @MoleAtomNum[$i];
    @Mass_Out[$count] = @MoleMass[$i];
    $count += 1;
  }
}

our $TopTypeNum = @Name_Out;
my $SolidName = "";
my $LiquidName = "";
for($i=0;$i<$TopTypeNum;$i+=1){
  $temp = uc @Name_Out[$i];
  if(@Ratio[$i]<0){
    if($SolidName){$SolidName="$SolidName\_$temp";}
    else{$SolidName=$temp;}
  }
  else{
    if($LiquidName){$LiquidName="$LiquidName\_$temp";}
    else{$LiquidName=$temp;}
  }
}

system "cp STANDARD_EM.mdp em.mdp";
system "sed -i 's/SOLID/$SolidName/g' em.mdp";

system "cp STANDARD_NVT.mdp initial.mdp";
system "sed -i 's/DDDTTT/0.001/g' initial.mdp";
system "sed -i 's/NSTEPS/5000/g' initial.mdp";
system "sed -i 's/SOLID/$SolidName/g' initial.mdp";
system "sed -i 's/LIQUID/$LiquidName/g' initial.mdp";

system "cp STANDARD_NVT.mdp tune.mdp";
system "sed -i 's/DDDTTT/0.002/g' tune.mdp";
system "sed -i 's/NSTEPS/2500000/g' tune.mdp";
system "sed -i 's/SOLID/$SolidName/g' tune.mdp";
system "sed -i 's/LIQUID/$LiquidName/g' tune.mdp";


1;
