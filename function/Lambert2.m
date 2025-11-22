%用于水平标定,2025.11.16修改
function f = Lambert2(X,LED,r,h,RSS,std)
    a=X(1);M=X(2);
    npd=[0,0,1];
    [n,~]=size(RSS);
    if(isscalar(h)) % 同水平面标定
        h=ones(n,1)*h;
    end
    f=zeros(n,1);
    for i=1:n
        s = sqrt(norm(LED(1:2)-r(i,:))^2+(LED(3)-h(i))^2);
        LOS=LED-[r(i,:),h(i)];
        cos_alpha = npd * LOS'/norm(LOS);
        cos_theta = (LED(3)-h(i))/s;
        f(i)= a*cos_theta^M*cos_alpha/s^2-RSS(i);
        f(i)=f(i)/std(i);%weight
    end
end