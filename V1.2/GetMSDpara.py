import numpy as np
import re
import sys

try:
    MSD_file = open(r"MSD_charge_para.dat",'r')
except:
    print "\nNOTE: Parameter file cannot be loaded, mission terminated.\n"
    sys.exit()
MSD_data = MSD_file.read()
match_type = r"^(\w+)\S*\s+(\d+)"
#match_atomN = r"(\d+)\s+\S*\.?\d+\s+\S+\.?\d+$"
#match_atomC = r"\d+\s+(\S*\.?\d+)\s+\S+\.?\d+$"
match_atomM = r"\d+\s+\S*\.?\d+\s+(\S+\.?\d+)$"
re_match_type = re.compile(match_type, re.M)
#re_match_atomN = re.compile(match_atomN, re.M)
#re_match_atomC = re.compile(match_atomC, re.M)
re_match_atomM = re.compile(match_atomM, re.M)
nType = int(re_match_type.findall(MSD_data)[0][1])
numAt = np.zeros([nType])
MoleName = []
MoleMass = np.zeros([nType,100])
TMoleMass = np.zeros(nType)
atom_index = 0
for i in range(nType):
    numAt[i] = int(re_match_type.findall(MSD_data)[i+1][1])
    MoleName.append(re_match_type.findall(MSD_data)[i+1][0])
    #print numAt[i]
    for j in range(int(numAt[i])):
        MoleMass[i][j] = float(re_match_atomM.findall(MSD_data)[atom_index])
        atom_index += 1
    TMoleMass[i] = np.sum(MoleMass[i][:])
MSD_file.close()
NAME = "\t".join(MoleName)
MASS = "\t".join([str(TMoleMass[i]) for i in range(nType)])
NUM = "\t".join([str(numAt[i]) for i in range(nType)])

outfile = open("MSD_out.dat","w")
outfile.write("NAME:\t"+NAME+"\n")
outfile.write("MASS:\t"+MASS+"\n")
outfile.write("NUM:\t"+NUM+"\n")
outfile.close()
