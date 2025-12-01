% 根据位置预测RSS，手动输入a和M，2025.12.1

function RSS=preRSS(p, a, M, LED)
    [nLED,~]=size(LED);
    
    [nump,~]=size(p);
    RSS=zeros(nump,nLED);
    for i=1:nump
        for iled=1:nLED
            LOS=LED(iled,:)-p(i,:);
            s=norm(LOS);
            cos_alpha = [0,0,1] * LOS'/norm(LOS);
            RSS(i,iled)= a(iled)*cos_alpha^(M(iled)+1)/s^2;
        end
    end
end