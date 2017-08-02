from optparse import OptionParser

parser = OptionParser()
parser.add_option("-i", dest = "initial_gro", default = "IonMultiDel.gro", help = "input ion start gro file, default scale_start.gro")
parser.add_option("-a", dest = "mole_atom_num", default = " 10 19 15", help = "input ion gro, each first type ion atom num")
parser.add_option("-n", dest = "mole_num", default = " 288 468 468", help = "input ion gro pair number, default 216")
parser.add_option("-d", dest = "delete_num", default = " 0 10 10", help = "input ion gro pair number, default 216")
parser.add_option("-o", dest = "output_gro", default = "New.gro", help = "output gro file name, default New.gro")
(options, args) = parser.parse_args()

input_gro = options.initial_gro
atom_num = options.mole_atom_num
mole_num = options.mole_num
delete_num = options.delete_num
output_gro = options.output_gro

print input_gro+"\n"
print atom_num+"\n"
print mole_num+"\n"
print delete_num+"\n"
print output_gro+"\n"

MoleTypeNum = len(mole_num.split())
Atom_Num = [int(atom_num.split()[i]) for i in range(len(atom_num.split()))]
Mole_Num = [int(mole_num.split()[i]) for i in range(len(mole_num.split()))]
Delete_Num  = [int(delete_num.split()[i]) for i in range(len(delete_num.split()))]

begin = 0
Delete_Line = []
Total_Delete = 0
for i in range(MoleTypeNum):
    if i == 0:
        begin = 2
        end = begin + Atom_Num[i]*Delete_Num[i]
        Delete_Line = range(begin, end ,1)
    else:
        begin = begin + Atom_Num[i-1] * Mole_Num[i-1]
        end = begin + Atom_Num[i] * Delete_Num[i]
        temp = range(begin, end, 1)
        Delete_Line.extend(temp)
    Total_Delete = Total_Delete + Atom_Num[i] * Delete_Num[i]

input_file = open(input_gro,'r')
output_file = open(output_gro,'w')
line = input_file.readlines()
Total_Num = int(line[1])
New_Num = Total_Num - Total_Delete
for i in range(len(line)):
    if i in Delete_Line:
        continue
    elif i == 1:
        output_file.write(str(New_Num)+"\n")
    else:
        output_file.write(line[i])

output_file.close()
input_file.close()