from odbAccess import *
import time, sys

filename = sys.argv[1]
startNode = int(sys.argv[2])
numNodes = int(sys.argv[3])
endNode = startNode+numNodes
position = int(sys.argv[4])

odb = openOdb(path=filename)

# Want to append node numbers to historyRegionName
historyRegionNameTemplate = "Node PART-1-1"
historyOutputName = ["COOR1", "COOR2", "COOR3"]
step = odb.steps['Step-1']

# Get number of frames from historyOutput
numframes=len(odb.steps['Step-1'].frames)
#print numframes

flag=1
DataLength=0
data = [[0 for x in xrange(numframes)] for x in xrange(6*numNodes)]
counter1 = 0
counter2 = 0
headerline = ""

for node in range(startNode,startNode+numNodes):
    historyRegionName = historyRegionNameTemplate + '.' + str(node)
    #print historyRegionName
    #print "\n"
	
    for HO in historyOutputName:
        historyRegion = step.historyRegions[historyRegionName]
		
        historyOutput = historyRegion.historyOutputs[HO].data
        #print historyOutput
        #print "\n"
	
        headerline += str(node)+"."+HO+".X\t" +str(node)+"."+HO+".Y\t"
		
        for (i,j) in historyOutput:
			
	         #print "i:" + str(i) + ",j:" + str(j)
	         #print str(counter1) + "," + str(counter2)
	         data[counter1][counter2] = i
	         #print str(counter1+1) + "," + str(counter2)
	         data[counter1+1][counter2] = j
	         counter2+=1
			
        counter1 = counter1+2
        counter2 = 0		
			


fname = "data" + str(position) + ".txt"
f1=open(fname,'w')

#Write header
#f1.write(headerline+"\n")
#Write data
for i in range(0,len(data[0])):
	for j in range(0,len(data)):
		f1.write("%9.5f\t"%(data[j][i]))
	f1.write("\n")	
	
f1.close()
odb.close()	


