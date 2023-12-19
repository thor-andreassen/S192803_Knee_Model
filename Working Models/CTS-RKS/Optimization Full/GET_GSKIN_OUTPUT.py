from odbAccess import *
import time, sys
import numpy as np
from matplotlib import pyplot as plt


filename = sys.argv[1]
want_plot = sys.argv[2]
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
frames=odb.steps['LAXITY'].frames
# Get coordinates of Tibia

tib_coordinates=np.zeros((len(frames),3))
ref_nodes=[1280001,1280002,1280003,1280004,1980001,1980002,1980003,1980004]
reference_nodeset=part.nodeSets["REF_FRAMES"]

node_coord_dict={}
temp_mat=tib_coordinates
for count_nodes in ref_nodes:
    node_coord_dict[str(count_nodes)]=tib_coordinates.copy()


counter_frame=0
times=np.zeros((len(frames),1))
for frame in frames:
    coord_field=frame.fieldOutputs['COORD']
    coord_field_ref=coord_field.getSubset(region=reference_nodeset)
    
    times[counter_frame,0]=frame.frameValue
    current_coord_value_ref=coord_field_ref.values
    
    for current_node in current_coord_value_ref:
        current_coord=current_node.data
        current_label=current_node.nodeLabel
        if node_coord_dict.has_key(str(current_label)):
            temp_mat=node_coord_dict[str(current_label)]
            temp_mat[counter_frame,:]=current_coord
            node_coord_dict[str(current_label)]=temp_mat
    counter_frame+=1



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

print(node_coord_dict.keys())

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


TCS_to_FCS_RotMat=FCS_to_GCS_TransMat

for count_frame in range(0,len(times)):
    TCS_to_FCS_RotMat[:,:,count_frame]=np.matmul(GCS_to_FCS_TransMat[:,:,count_frame],TCS_to_GCS_TransMat[:,:,count_frame])


def createGSKin(TransMat, Left):
    TransMat_new=np.eye(4)
    TransMat_new[1:4,1:4]=TransMat[0:3,0:3]
    TransMat_new[1:4,0]=TransMat[0:3,3]
    gskin=np.zeros((1,6))
    gskin[0,1]=np.rad2deg(np.arccos(TransMat_new[1,3])-(np.pi)/2)
    gskin[0,0]=np.rad2deg(np.arctan(TransMat_new[2,3]/TransMat_new[3,3]))
    gskin[0,2]=np.rad2deg(np.arctan(TransMat_new[1,2]/TransMat_new[1,1]))
    alpha=np.arctan(TransMat_new[2,3]/TransMat_new[3,3])
    if alpha<-0.5:
        alpha=alpha+np.pi
    
    gskin[0,3]=TransMat_new[1,0]
    gskin[0,4]=TransMat_new[2,0]*np.cos(alpha)-TransMat_new[0,3]*np.sin(alpha)
    gskin[0,5]=(TransMat_new[1,3]*TransMat_new[1,0]+TransMat_new[2,3]*TransMat_new[2,0]+TransMat_new[3,3]*TransMat_new[3,0])
    
    if Left==1:
        gskin[0,1:4]=-gskin[0,1:4]
    
    return gskin




gskin=np.zeros((len(times),6))


for count_frame in range(0,len(times)):
    gskin[count_frame,:]=createGSKin(TCS_to_FCS_RotMat[:,:,count_frame],1)

gskin[:,0]=np.unwrap(gskin[:,0],discont=np.pi/2)
print(gskin)



# PLOTTING
if want_plot=="1":
    fig, axs = plt.subplots(3, 2)


    axs[0,0].set_xlabel("F(+)/E (deg)")
    axs[0,0].set_ylabel("Vr/Vl(+) (deg)")
    axs[0,0].plot(gskin[:,0],gskin[:,1])

    axs[1,0].set_xlabel("F(+)/E (deg)")
    axs[1,0].set_ylabel("I/E(+) (deg)")
    axs[1,0].plot(gskin[:,0],gskin[:,2])

    axs[0,1].set_xlabel("F(+)/E (deg)")
    axs[0,1].set_ylabel("M/L(+) (mm)")
    axs[0,1].plot(gskin[:,0],gskin[:,3])

    axs[1,1].set_xlabel("F(+)/E (deg)")
    axs[1,1].set_ylabel("A(+)/P (mm)")
    axs[1,1].plot(gskin[:,0],gskin[:,4])

    axs[2,1].set_xlabel("F(+)/E (deg)")
    axs[2,1].set_ylabel("S(+)/I (mm)")
    axs[2,1].plot(gskin[:,0],gskin[:,5])


    plt.show()


# Export data
fname = filename+"GSKinematics.csv"
f1=open(fname,'w')
f1.write("Time(s),   F(+)/E (deg),   Vr/Vl(+) (deg),   I/E(+) (deg),   M/L(+) (mm),   A(+)/P (mm),   S(+)/I (mm)")
f1.write("\n")

# Write Data
for count_frame in range(0,len(frames)):
    f1.write("%f,   "%(times[count_frame,0]))
    for count_col in range(0,np.shape(gskin)[1]):
        f1.write("%f,   "%(gskin[count_frame,count_col]))
    f1.write("\n")
f1.close()
