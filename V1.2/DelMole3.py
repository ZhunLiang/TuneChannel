from optparse import OptionParser
import numpy as np
import os
import re

parser = OptionParser()
parser.add_option("-i", dest = "initial_gro", default = "IonMultiDel.gro", help = "input ion start gro file, default scale_start.gro")
parser.add_option("-a", dest = "mole_atom_num", default = " 10 19 15", help = "molecular's atom num")
parser.add_option("-n", dest = "mole_num", default = " 288 468 468", help = "input ion gro pair number, default 216")
parser.add_option("-d", dest = "delete_num", default = " 0 10 10", help = "input ion gro pair number, default 216")
parser.add_option("-o", dest = "output_gro", default = "New.gro", help = "output gro file name, default New.gro")
(options, args) = parser.parse_args()

input_gro = options.initial_gro
atom_num = options.mole_atom_num
mole_num = options.mole_num
delete_num = options.delete_num
output_gro = options.output_gro

MoleTypeNum = len(mole_num.split())
Atom_Num = np.array([int(float(atom_num.split()[i])) for i in range(len(atom_num.split()))])
Mole_Num = np.array([int(float(mole_num.split()[i])) for i in range(len(mole_num.split()))])
Delete_Num  = np.array([int(float(delete_num.split()[i])) for i in range(len(delete_num.split()))])
Delete_Num = Delete_Num//2*2

input_file = open(input_gro,'r')
coor_match = r"-?\d+\.\d+"
re_match = re.compile(coor_match)
gro_line = input_file.readlines()
ele_num = int(gro_line[1])
coor = np.zeros([ele_num,3])
for i in range(ele_num):
    temp = re_match.findall(gro_line[i + 2])[0:3]
    coor[i,:] = np.array(list(map(float,temp)))
Box_size = list(map(float,gro_line[-1].split()))

begin = 0
Delete_Line = []
for i in range(MoleTypeNum):
    if i != 0:
        begin = np.sum(Mole_Num[0:i]*Atom_Num[0:i])
    if Delete_Num[i]>0:
        left_delete = 0
        right_delete = 0
        for j in range(Mole_Num[i]):
            end_line = begin + Atom_Num[i];
            Num_Cen = (np.ones([1,Atom_Num[i]])/Atom_Num[i]).dot(coor[begin:end_line,:])
            if 0 <= Num_Cen[0,2] <= 1.0 and left_delete < Delete_Num[i]/2:
                Delete_Line = Delete_Line + list(range(begin,end_line,1))
                left_delete += 1
            if Box_size[2]-1 <= Num_Cen[0,2] <= Box_size[2] and right_delete < Delete_Num[i]/2:
                Delete_Line = Delete_Line + list(range(begin,end_line,1))
                right_delete += 1
            if right_delete == Delete_Num[i]/2 and left_delete == Delete_Num[i]/2:
                break
            begin = end_line

Total_Delete = np.sum(Delete_Num*Atom_Num)
output_file = open(output_gro,'w')
New_Num = ele_num - Total_Delete

for i in range(len(gro_line)):
    if (i-2) in Delete_Line:
        temp_delete += 1
        continue
    elif i == 1:
        output_file.write(str(New_Num)+"\n")
    else:
        output_file.write(gro_line[i])
output_file.close()
input_file.close()
