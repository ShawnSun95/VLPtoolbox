% 根据位置预测RSS，手动输入a和M，2025.11.19

function RSS=preRSS(p, a, M)
    LED=[4.5604,0.7996,2.99
        4.2862,2.1105,2.99
        4.5802,3.4361,2.99
        6.5215,3.1602,2.99
        6.5806,2.1225,2.99
        6.6521,0.9161,2.99];
    nLED=6;
    
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