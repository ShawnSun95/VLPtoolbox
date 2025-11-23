% NED到ENU转换，或者反之
function vec2 = NED2ENU(vec)
    vec2=zeros(size(vec));
    if isequal(size(vec), [3, 1])
        vec2(3)=-vec(3);
        vec2(2)=vec(1);
        vec2(1)=vec(2);
    else
        vec2(:,3)=-vec(:,3);
        vec2(:,2)=vec(:,1);
        vec2(:,1)=vec(:,2);
    end
end