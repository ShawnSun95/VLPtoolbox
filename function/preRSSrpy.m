% 根据位置、姿态预测RSS，手动输入a和M，LED位置

function RSS=preRSSrpy(p, a, M, LED)
    nLED=length(a);
    [nump,~]=size(p);

    RSS=zeros(nump,nLED);
    for i=1:nump
        dcm = Euler2Dcm(p(i,4), p(i,5), p(i,6));
        npd = dcm*[0;0;-1];
        nled=[0,0,-1];
        for iled=1:nLED
            LOS=LED(iled,:)-p(i,1:3);
            s=norm(LOS);
            % 计算夹角余弦，并裁剪到 [0, 1]
            cos_alpha = npd' * LOS'/norm(LOS);
            cos_theta = nled * LOS'/norm(LOS);
            cos_alpha = max(cos_alpha, 0);
            cos_theta = max(cos_theta, 0);
    
            RSS(i,iled)= a(iled)*cos_theta^(M(iled))*cos_alpha/s^2;
        end
    end
end