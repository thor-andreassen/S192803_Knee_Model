function TransMat=getTransMatFromNodes(origin_pts,plusx_pts,plusy_pts,plusz_pts)
    x_vec=(plusx_pts-origin_pts)/norm(plusx_pts-origin_pts);
    y_vec=(plusy_pts-origin_pts)/norm(plusy_pts-origin_pts);
    z_vec=(plusz_pts-origin_pts)/norm(plusz_pts-origin_pts);
    Rotmat=[x_vec',y_vec',z_vec'];
    Transvec=origin_pts;
    TransMat=eye(4);
    TransMat(2:4,2:4)=Rotmat;
    TransMat(2:4,1)=Transvec;
    TransMat=inv(TransMat);
end