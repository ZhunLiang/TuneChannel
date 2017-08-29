#!/bin/perl
#INPUT

@XYZ = split/\s+/,`tail -1 end.gro`;
$Z = @XYZ[3];
$Trans_trans=$Z;
$Trans_scale=$Z*2;
#generate scale.gro
system "GROMACSgmx editconf -f end.gro -scale 1 1 -1 -translate 0 0 $Trans_scale -o scale.gro";
#generate trans.gro
system "GROMACSgmx editconf -f end.gro -translate 0 0 $Trans_trans -o trans.gro";
#get top number
@TopNum = GetTopNum("end.top");

#get python input parameter
$TopNum = StrPara(@TopNum);
$AtomNum = StrPara(@Num_Out);
$DeleteRatio = StrPara(@Ratio);

#Run python
system "PYTHON CombineGroEle.py -i end.gro -s scale.gro -t trans.gro -n $TopNum -a $AtomNum -d $DeleteRatio -o end_combine.gro";

#Clean files
system "rm -f scale.gro trans.gro";

#Generate New Top
system "cp end.top end_combine.top";
for($i=0;$i<$TopTypeNum;$i=$i+1){
    @NewMoleNum[$i]=@TopNum[$i]*2;    #obtain new topol.top number
    $match="@Name_Out[$i]\\s\\+\\([0-9]\\+\\)";
    $replace="@Name_Out[$i]\t@NewMoleNum[$i]";
    system "sed -i 's/$match/$replace/g' end_combine.top";
}

#Run Initial
system "mv end.gro end_one.gro";
system "mv end.top end_one.top";
system "mv end_combine.gro end.gro";
system "mv end_combine.top end.top";
GeneraNdx("end.gro");
RunGmx("initial",0);

1;
