from optparse import OptionParser
import numpy as np

parser = OptionParser()
parser.add_option("-i", dest = "initial_gro", default = "initial.gro", help = "input initial gro file, default initial.gro")
parser.add_option("-s", dest = "scale_gro", default = "scale.gro", help = "input scale gro file, default scale.gro, scale 1 1 -1")
parser.add_option("-t", dest = "trans_gro", default = "trans.gro", help = "input translate gro, -translate 0 0 box_z")
parser.add_option("-n", dest = "mole_num", default = "243 476 476", help = "mole number of one single input gro file")
parser.add_option("-a", dest = "mole_atom_num", default = "10 19 19", help = "each mole type atoms number")
parser.add_option("-d", dest = "delete_ratio", default = "-1 1 1", help = "<0 means electrode, >=0 means electrolyte")
parser.add_option("-o", dest = "output_gro", default = "total.gro", help = "output gro file name, default total.gro")
(options, args) = parser.parse_args()
initial_gro = options.initial_gro
scale_gro = options.scale_gro
trans_gro = options.trans_gro
mole_num = options.mole_num
mole_atom_num = options.mole_atom_num
delete_ratio = options.delete_ratio
output_gro = options.output_gro

initial_file = open(initial_gro,'r')
scale_file = open(scale_gro,'r')
trans_file = open(trans_gro,'r')
output_file = open(output_gro,"w")

initial_line = initial_file.readlines()
scale_line = scale_file.readlines()
trans_line = trans_file.readlines()

Mole_Atom_Num = np.array([int(float(mole_atom_num.split()[i])) for i in range(len(mole_atom_num.split()))])
Mole_Num = np.array([int(float(mole_num.split()[i])) for i in range(len(mole_num.split()))])
Delete_Ratio = np.array([float(delete_ratio.split()[i]) for i in range(len(delete_ratio.split()))])

box_origin = np.array([float(initial_line[-1].split()[i]) for i in range(3)])
box_new = box_origin
box_new[2] = box_new[2]*2
Box_New = ("\t" + str(box_new[0]) + "\t" + str(box_new[1]) + "\t" + str(box_new[2]))
origin_line_num = int(initial_line[1])
new_line_num = origin_line_num*2

output_file.write(initial_line[0])
output_file.write(str(new_line_num) + "\n")

mole_type_num = len(Mole_Num)
begin = 0
end = 2
for i in range(mole_type_num):
    begin = end
    end = begin + Mole_Atom_Num[i]*Mole_Num[i]
    if Delete_Ratio[i] < 0:    #electode
        for j in range(begin,end):
            output_file.write(initial_line[j])
        for k in range(begin,end):
            output_file.write(scale_line[k])
    else:
        for j in range(begin,end):
            output_file.write(initial_line[j])
        for k in range(begin,end):
            output_file.write(trans_line[k])

output_file.write(str(Box_New) + "\n")
output_file.write("\n")
output_file.close()
initial_file.close()
scale_file.close()
trans_file.close()
