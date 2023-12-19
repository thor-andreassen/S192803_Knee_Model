function [MRI_to_Fem_TransMat,MRI_to_Tib_TransMat,MRI_to_Pat_TransMat]=OKS03GetTransMat(fem_pts,tib_pts,pat_pts)
    % femur coordinate system
    O_F=(fem_pts(1,:)+fem_pts(2,:))/2;
    Fem_Prox=(fem_pts(3,:)+fem_pts(4,:))/2;
    F_x=(fem_pts(2,:)-fem_pts(1,:))/norm(fem_pts(2,:)-fem_pts(1,:));
    F_z_temp=(Fem_Prox-O_F)/norm(Fem_Prox-O_F);
    F_y=cross(F_z_temp,F_x)/norm(cross(F_z_temp,F_x));
    F_z=cross(F_x,F_y)/norm(cross(F_x,F_y));
    
    Fem_to_MRI_TransMat=zeros(4,4);
    Fem_to_MRI_TransMat(4,4)=1;
    Fem_to_MRI_TransMat(1:3,1)=F_x';
    Fem_to_MRI_TransMat(1:3,2)=F_y';
    Fem_to_MRI_TransMat(1:3,3)=F_z';
    Fem_to_MRI_TransMat(1:3,4)=O_F';
    
    MRI_to_Fem_TransMat=inv(Fem_to_MRI_TransMat);
    
%     MRI_to_Fem_TransMat=eye(4);
%     MRI_to_Fem_TransMat(2:4,1)=temp(1:3,4);
%     MRI_to_Fem_TransMat(2:4,2:4)=temp(1:3,1:3);
    
    % tibia coordinate system
    
    O_T=(tib_pts(1,:)+tib_pts(2,:))/2;
    Tib_Dist=(tib_pts(3,:)+tib_pts(4,:))/2;
    T_x_temp=(tib_pts(2,:)-tib_pts(1,:))/norm(tib_pts(2,:)-tib_pts(1,:));
    T_z=(O_T-Tib_Dist)/norm(O_T-Tib_Dist);
    T_y=cross(T_z,T_x_temp)/norm(cross(T_z,T_x_temp));
    T_x=cross(T_y,T_z)/norm(cross(T_y,T_z));
    
    Tib_to_MRI_TransMat=zeros(4,4);
    Tib_to_MRI_TransMat(4,4)=1;
    Tib_to_MRI_TransMat(1:3,1)=T_x';
    Tib_to_MRI_TransMat(1:3,2)=T_y';
    Tib_to_MRI_TransMat(1:3,3)=T_z';
    Tib_to_MRI_TransMat(1:3,4)=O_T';
    
    MRI_to_Tib_TransMat=inv(Tib_to_MRI_TransMat);
    
%     MRI_to_Tib_TransMat=eye(4);
%     MRI_to_Tib_TransMat(2:4,1)=temp(1:3,4);
%     MRI_to_Tib_TransMat(2:4,2:4)=temp(1:3,1:3);
    
    % patella coordinate system
    O_P=pat_pts(1,:);
    P_z=(pat_pts(2,:)-pat_pts(3,:))/norm(pat_pts(2,:)-pat_pts(3,:));
    P_y=cross(P_z,(pat_pts(4,:)-pat_pts(5,:)))/norm(cross(P_z,(pat_pts(4,:)-pat_pts(5,:))));
    P_x=cross(P_y,P_z)/norm(cross(P_y,P_z));
    
    Pat_to_MRI_TransMat=zeros(4,4);
    Pat_to_MRI_TransMat(4,4)=1;
    Pat_to_MRI_TransMat(1:3,1)=P_x';
    Pat_to_MRI_TransMat(1:3,2)=P_y';
    Pat_to_MRI_TransMat(1:3,3)=P_z';
    Pat_to_MRI_TransMat(1:3,4)=O_P';
    
    MRI_to_Pat_TransMat=inv(Pat_to_MRI_TransMat);
    
%     MRI_to_Pat_TransMat=eye(4);
%     MRI_to_Pat_TransMat(2:4,1)=temp(1:3,4);
%     MRI_to_Pat_TransMat(2:4,2:4)=temp(1:3,1:3);
end