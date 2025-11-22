%用于可任意姿态角的3D定位，依赖Euler2Dcm函数
function f = Lambert4(X,LED,a,M,roll,pitch,dir,RSS,std)
    nLED=length(a);
    f=zeros(nLED,1);
    dcm = Euler2Dcm_ENU(roll, pitch, dir);
    npd=dcm*[0;0;1];
    nled=[0,0,1];
    for iled=1:nLED
        LOS=LED(iled,:)-X;
        s=norm(LOS);
        cos_alpha = npd' * LOS'/norm(LOS);
        cos_theta = nled * LOS'/norm(LOS);
        f(iled)= a(iled)*cos_theta^(M(iled))*cos_alpha/s^2-RSS(iled);
        f(iled)=f(iled)/std(iled);%weight
    end
end