from optparse import OptionParser
import numpy as np
import re
import sys

parser = OptionParser()
parser.add_option("-i", dest = "dens_file", default = "dens.xvg", help = "input density xvg file by gmx density output")
parser.add_option("-n", dest = "mole_num", default = "288 486 486", help = "each type molecular number")
parser.add_option("-m", dest = "mole_mass", default = "28 36 36", help = "each type molecular mass")
parser.add_option("-d", dest = "delete_ratio", default = "0 1 1", help = "shan chu de ge shu bi, x:y:z:..., shan x ge diyizhong, shan y ge dierzhong")
parser.add_option("-b", dest = "bulk_dens", default = 1540.0,type=float, help = "ion pairs bulk density")
parser.add_option("-B", dest = "bin_number", default = 1500,type=int, help = "bin number of gmx density -sl number")
parser.add_option("-T", dest = "total_long", default = 30,type=float, help = "total long")
parser.add_option("--Kmax", dest = "Kmax", default = 0.99,type=float, help = "total long")
parser.add_option("--Kmin", dest = "Kmin", default = 0.99,type=float, help = "total long")


(options, args) = parser.parse_args()
dens = options.dens_file
mole_num = options.mole_num
mole_mass = options.mole_mass
delete_num = options.delete_ratio
bulk_dens = options.bulk_dens
bin_number = options.bin_number
total_long = options.total_long
Kmax = options.Kmax
Kmin = options.Kmin
'''
dens = "dens.xvg"
mole_num = "288 468 468"
delete_num = "0 1 1"
bulk_dens = 1548
bin_number = 1500
channel_long = 8
total_long = 30
Kmax = 0.995
Kmin = 0.97
'''
#max delete number one time
MAX_DELETE = 200


dens_file = open(dens,'r')
dens_line = dens_file.readlines()
dens_end = len(dens_line)
dens_begin = dens_end-bin_number
deta_bin = bin_number/total_long
bulk_begin1 = int(dens_begin)
#-----bulk range, total 3 nm 
bulk_end1 = int(dens_begin + deta_bin*1.5)
bulk_end2 = int(dens_end)
bulk_begin2 = int(dens_end - deta_bin*1.5)
#-----bulk range, total 3 nm
channel_bulk1 = np.array([float(dens_line[i].split()[-1]) for i in range(bulk_begin1,bulk_end1)])
channel_bulk2 = np.array([float(dens_line[i].split()[-1]) for i in range(bulk_begin2,bulk_end2)])
Mean_channel_bulk1 = np.mean(channel_bulk1)
Mean_channel_bulk2 = np.mean(channel_bulk2)
Mean_channel_bulk = (Mean_channel_bulk1+Mean_channel_bulk2)/2;
dens_file.close()
#####the next is get the delete number of each type molecular
Mole_Num = np.array([int(mole_num.split()[i]) for i in range(len(mole_num.split()))])
Delete_Ratio = np.array([float(delete_num.split()[i]) for i in range(len(delete_num.split()))])
TMoleMass = np.array([float(mole_mass.split()[i]) for i in range(len(mole_mass.split()))])
Delete_Type = Delete_Ratio>0
Delete_Ratio = Delete_Type*Delete_Ratio
Kmean = (Kmax+2*Kmin)/3
v1 = Mean_channel_bulk/bulk_dens
Mole_Type_Num = len(Mole_Num)
Delete_Num = np.zeros(Mole_Type_Num)
#only if too dense then calculated the needed delete number
if(v1>Kmax):
    v2=np.sum(Mole_Num*TMoleMass[0:Mole_Type_Num]*Delete_Type)
    v3=np.sum(Delete_Ratio*TMoleMass[0:Mole_Type_Num]*Delete_Type)
    Delete_Num = np.floor((1-Kmean/v1)*v2/v3*Delete_Ratio)
    Delete_Num = np.floor(Delete_Num>MAX_DELETE)*MAX_DELETE + np.floor(Delete_Num<=MAX_DELETE)*Delete_Num
#in too small density, then return -1
if(v1<=Kmin):
    Delete_Num -= 1

Delete_str = [str(int(Delete_Num[i])) for i in range(Mole_Type_Num)]
OutPut = "\t".join(Delete_str)
print OutPut
