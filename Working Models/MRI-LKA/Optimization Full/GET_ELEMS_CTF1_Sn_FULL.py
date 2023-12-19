from odbAccess import *
import time, sys

filename = sys.argv[1]
sNum = sys.argv[2]
numframes = int(sys.argv[3])
odb = openOdb(path=filename)

# Element list
elems = [20000, 20001, 20002, 20003, 30000, 30001, 30002, 40000, 40001, 40002,  50000, 50001, 50002, 50006, 50008, 50010, 50012, 50014, 60000, 60001, 60002, 60003, 60004, 60005, 70000, 70001, 70002, 70003, 80003, 80004, 80005];

# Prealloc
data = [[0 for x in range(numframes)] for y in range(len(elems)*2)]
counter1 = 0
counter2 = 0

# Want to append node numbers to historyRegionName
stepString = 'Step-' + sNum
step = odb.steps[stepString]				
historyRegionNameTemplate = "Element PART-1-1"
historyOutputName = ["CTF1"]

for elem in elems:
	historyRegionName = historyRegionNameTemplate + '.' + str(elem)

	for HO in historyOutputName:
		historyRegion = step.historyRegions[historyRegionName]
		historyOutput = historyRegion.historyOutputs[HO].data

		for (i,j) in historyOutput:
			
			#print "i:" + str(i) + ",j:" + str(j)
			#print str(counter1) + "," + str(counter2)
			data[counter1][counter2] = i
			#print str(counter1+1) + "," + str(counter2)
			data[counter1+1][counter2] = j
			counter2+=1
			
		counter1 = counter1+2
		counter2 = 0

odb.close()

fname = "LigamentForces.txt" 
f1=open(fname,'w')

#Write header
#f1.write(headerline+"\n")
#Write data
for i in range(0,len(data[0])):
	for j in range(0,len(data)):
		f1.write("%9.5f\t"%(data[j][i]))
	f1.write("\n")	
	
f1.close()


