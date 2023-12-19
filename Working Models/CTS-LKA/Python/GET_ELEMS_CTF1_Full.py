from odbAccess import *
import time, sys
import numpy as np
import csv
from scipy.io import savemat
from matplotlib import pyplot as plt

filename = sys.argv[1]
step_name = sys.argv[2]
want_plot = sys.argv[3]
odb = openOdb(path=filename)


# get elements
#session.openOdb(name='cube.odb').rootAssembly.instances['PART-1-1'].elementSets['CUBE-1_CUBE'].elements[el_numerator].connectivity[nod_numerator]
part=odb.rootAssembly.instances["PART-1-1"]

# get element subsets
names_cart_list=[]
elements_cart_list=[]
nodes_cart_list=[]
node_list=[]

## Get Maximum contact pressure Field Data
frames=odb.steps[step_name].frames
# Get coordinates of Tibia

tib_coordinates=np.zeros((len(frames),3))
ref_nodes=[1280001,1280002,1280003,1280004,1980001,1980002,1980003,1980004]
reference_nodeset=part.nodeSets["REF_FRAMES"]

node_coord_dict={}
temp_mat=tib_coordinates
for count_nodes in ref_nodes:
    node_coord_dict[str(count_nodes)]=tib_coordinates.copy()


counter_frame=0
current_frame=0
times=np.zeros((len(frames),1))
valid_frames=np.zeros((len(frames),1))
for frame in frames:
    try:
        coord_field=frame.fieldOutputs['COORD']
        coord_field_ref=coord_field.getSubset(region=reference_nodeset)
        
        times[counter_frame,0]=frame.frameValue
        current_coord_value_ref=coord_field_ref.values
        
        for current_node in current_coord_value_ref:
            current_coord=current_node.data
            current_label=current_node.nodeLabel
            if node_coord_dict.has_key(str(current_label)):
                temp_mat=node_coord_dict[str(current_label)]
                temp_mat[current_frame,:]=current_coord
                node_coord_dict[str(current_label)]=temp_mat
        valid_frames[counter_frame,0]=1
        current_frame+=1
        counter_frame+=1
    except:
        valid_frames[counter_frame,0]=0


times=times[valid_frames==1]

# create Transforms for Tibia

def createTForm(origin, x, y):
    vecx=(x-origin)/np.linalg.norm(x-origin) 
    tempy=(y-origin)/np.linalg.norm(y-origin)
    vecz=np.cross(vecx,tempy)/(np.linalg.norm(np.cross(vecx,tempy)))
    vecy=np.cross(vecz,vecx)/(np.linalg.norm(np.cross(vecz,vecx)))
    trans_vec=origin
    rotmat=np.empty((3,3))
    rotmat[:, 0]=vecx
    rotmat[:, 1]=vecy
    rotmat[:, 2]=vecz
    TransMat=np.identity(4)
    TransMat[0:3, 0:3]=rotmat
    TransMat[0:3, -1]=np.transpose(trans_vec)
    localToGlobalTransMat=TransMat
    globalToLocalTransMat=np.linalg.inv(TransMat)
    return localToGlobalTransMat, globalToLocalTransMat


origin_pt=node_coord_dict["1280001"]
x_pt=node_coord_dict["1280002"]
y_pt=node_coord_dict["1280003"]

TCS_to_GCS_TransMat=np.zeros((4,4,len(times)))
GCS_to_TCS_TransMat=np.zeros((4,4,len(times)))

for count_frame in range(0,len(times)):
    x_pt_temp=x_pt[count_frame,:]
    y_pt_temp=y_pt[count_frame,:]
    origin_pt_temp=origin_pt[count_frame,:]
    (temp_TCS_to_GCS,temp_GCS_to_TCS)=createTForm(origin_pt_temp,x_pt_temp,y_pt_temp)
    
    TCS_to_GCS_TransMat[:,:,count_frame]=temp_TCS_to_GCS
    GCS_to_TCS_TransMat[:,:,count_frame]=temp_GCS_to_TCS


GCS_to_TCS_RotMat=GCS_to_TCS_TransMat[0:3,0:3,:]


origin_pt=node_coord_dict["1980001"]
x_pt=node_coord_dict["1980002"]
y_pt=node_coord_dict["1980003"]


FCS_to_GCS_TransMat=np.zeros((4,4,len(times)))
GCS_to_FCS_TransMat=np.zeros((4,4,len(times)))

for count_frame in range(0,len(times)):
    x_pt_temp=x_pt[count_frame,:]
    y_pt_temp=y_pt[count_frame,:]
    origin_pt_temp=origin_pt[count_frame,:]
    (temp_FCS_to_GCS,temp_GCS_to_FCS)=createTForm(origin_pt_temp,x_pt_temp,y_pt_temp)
    
    FCS_to_GCS_TransMat[:,:,count_frame]=temp_FCS_to_GCS
    GCS_to_FCS_TransMat[:,:,count_frame]=temp_GCS_to_FCS


TCS_to_FCS_TransMat=FCS_to_GCS_TransMat

for count_frame in range(0,len(times)):
    TCS_to_FCS_TransMat[:,:,count_frame]=np.matmul(GCS_to_FCS_TransMat[:,:,count_frame],TCS_to_GCS_TransMat[:,:,count_frame])



def createGSKin(TransMat, Left):
    TransMat_new=np.eye(4)
    TransMat_new[1:,1:]=TransMat[0:3,0:3]
    TransMat_new[1:,0]=TransMat[0:3,3]
    gskin=np.zeros((1,6))
    alpha=np.arctan(TransMat_new[2,3]/TransMat_new[3,3])
    if alpha<-0.5:
        alpha=alpha+np.pi
    gskin[0,0]=np.rad2deg(alpha)
    gskin[0,1]=np.rad2deg(np.arccos(TransMat_new[1,3])-(np.pi)/2)
    gskin[0,2]=np.rad2deg(np.arctan(TransMat_new[1,2]/TransMat_new[1,1]))
    gskin[0,3]=TransMat_new[1,0]
    gskin[0,4]=TransMat_new[2,0]*np.cos(alpha)-TransMat_new[3,0]*np.sin(alpha)
    gskin[0,5]=(TransMat_new[1,3]*TransMat_new[1,0]+TransMat_new[2,3]*TransMat_new[2,0]+TransMat_new[3,3]*TransMat_new[3,0])
    
    if Left==1:
        gskin[0,1:4]=-gskin[0,1:4]
    
    return gskin




gskin=np.zeros((len(times),6))


for count_frame in range(0,len(times)):
    gskin[count_frame,:]=createGSKin(TCS_to_FCS_TransMat[:,:,count_frame],1)

gskin[:,0]=np.unwrap(gskin[:,0],discont=90)
#print(gskin)













f = open('Ligament_Element_List.csv', 'rb')
reader = csv.reader(f)
headers = next(reader, None)
ligament_label = {}
for h in headers:
    s = h.replace("\xef\xbb\xbf","")
    print(s)
    ligament_label[s] = []


for row in reader:
    for h, v in zip(headers, row):
        s = h.replace("\xef\xbb\xbf","")
        s2 = v.replace("\xef\xbb\xbf","")
        ligament_label[s].append(str(s2))

temp_val=ligament_label['Bundle_Group_Number']
temp_val = [int(i) for i in temp_val]
lig_group=np.array(temp_val)
unique_ligs=np.unique(lig_group)
num_ligs=np.shape(unique_ligs)[0]

bundle_name=ligament_label['Bundle']
bundle_name=np.array(bundle_name)
bundle_name=np.unique(bundle_name)

Lig_name=ligament_label['Ligament_Name']
Lig_name=np.array(Lig_name)






# Element list
elems = [20000, 20001, 20002, 20003, 30000, 30001, 30002, 40000, 40001, 40002,  50000, 50001, 50002, 50006, 50008, 50010, 50012, 50014, 60000, 60001, 60002, 60003, 60004, 60005, 70000, 70001, 70002, 70003, 80003, 80004, 80005]

# Want to append node numbers to historyRegionName
step = odb.steps[step_name]				
historyRegionNameTemplate = "Element PART-1-1"
historyOutputName = ["CTF1"]


total_times = 0
total_vals = 0
count_elem=0;


for HO in historyOutputName:
    for elem in elems:
        historyRegionName = historyRegionNameTemplate + '.' + str(elem)
        historyRegion = step.historyRegions[historyRegionName]
        historyOutput = np.asarray(historyRegion.historyOutputs[HO].data)
        force_times=np.shape(historyOutput)[0]
        break


force_values=np.zeros((force_times,len(elems)))
counter=0
for HO in historyOutputName:
    for elem in elems:
        historyRegionName = historyRegionNameTemplate + '.' + str(elem)
        historyRegion = step.historyRegions[historyRegionName]
        historyOutput = np.asarray(historyRegion.historyOutputs[HO].data)
        force_times=historyOutput[:,0]
        force_values[:,counter]=historyOutput[:,1]
        counter+=1


ligament_forces=np.zeros((np.shape(force_times)[0],num_ligs))

counter=0
for elem in lig_group:
    ligament_forces[:,elem-1]+=force_values[:,counter]
    counter+=1


# Export Combined Ligament data
fname = filename+"_LigForceCombined.csv"
f1=open(fname,'w')
f1.write("Time(s),   F(+)/E (deg),   Vr/Vl(+) (deg),   I/E(+) (deg),   M/L(+) (mm),   A(+)/P (mm),   S(+)/I (mm)")
for bundle in bundle_name:
    cur_name=bundle
    f1.write(",   "+cur_name)
f1.write("\n")

# Write Data


for count_frame in range(0,len(times)):
    f1.write("%f,   "%(times[count_frame]))
    for count_col in range(0,np.shape(gskin)[1]):
        f1.write("%f,   "%(gskin[count_frame,count_col]))
    for count_col in range(0,np.shape(ligament_forces)[1]):
        f1.write("%f,   "%(ligament_forces[count_frame,count_col]))
    f1.write("\n")
f1.close()


# Export Individual Ligament data
fname = filename+"_LigForceIndividual.csv"
f1=open(fname,'w')
f1.write("Time(s),   F(+)/E (deg),   Vr/Vl(+) (deg),   I/E(+) (deg),   M/L(+) (mm),   A(+)/P (mm),   S(+)/I (mm)")
for bundle in Lig_name:
    cur_name=bundle
    f1.write(",   "+cur_name)
f1.write("\n")

# Write Data


for count_frame in range(0,len(times)):
    f1.write("%f,   "%(times[count_frame]))
    for count_col in range(0,np.shape(gskin)[1]):
        f1.write("%f,   "%(gskin[count_frame,count_col]))
    for count_col in range(0,np.shape(force_values)[1]):
        f1.write("%f,   "%(force_values[count_frame,count_col]))
    f1.write("\n")
f1.close()






output_data={'TCS_to_FCS_TransMat':TCS_to_FCS_TransMat,'gskin':gskin,'Times':times,'GCS_to_FCS_TransMat':GCS_to_FCS_TransMat,\
'GCS_to_TCS_TransMat':GCS_to_TCS_TransMat,'Times_Force':force_times,'Ligament_Loads_Individual':force_values\
,'Ligament_Loads_Combined':ligament_forces,'Ligament_Labels':ligament_label}
fname = filename+"_LigForce.mat"
savemat(fname,output_data)




# PLOTTING
if want_plot=="1":


    plt.plot(gskin[:,0],ligament_forces[:,:])
    plt.legend(bundle_name)
    # plt.plot(gskin[:,0],ligament_forces[:,1])
    
    # plt.plot(gskin[:,4],gskin[:,2])
    
    # fig, axs = plt.subplots(3, 2)


    # axs[0,0].set_xlabel("F(+)/E (deg)")
    # axs[0,0].set_ylabel("Vr/Vl(+) (deg)")
    # axs[0,0].plot(gskin[:,0],gskin[:,1])

    # axs[1,0].set_xlabel("F(+)/E (deg)")
    # axs[1,0].set_ylabel("I/E(+) (deg)")
    # axs[1,0].plot(gskin[:,0],gskin[:,2])

    # axs[0,1].set_xlabel("F(+)/E (deg)")
    # axs[0,1].set_ylabel("M/L(+) (mm)")
    # axs[0,1].plot(gskin[:,0],gskin[:,3])

    # axs[1,1].set_xlabel("F(+)/E (deg)")
    # axs[1,1].set_ylabel("A(+)/P (mm)")
    # axs[1,1].plot(gskin[:,0],gskin[:,4])

    # axs[2,1].set_xlabel("F(+)/E (deg)")
    # axs[2,1].set_ylabel("S(+)/I (mm)")
    # axs[2,1].plot(gskin[:,0],gskin[:,5])


    plt.show()
