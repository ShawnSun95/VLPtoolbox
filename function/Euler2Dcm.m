%
% Convert Euler angles to Dirction Cosine Matrix - NED system
% by Eun-Hwan Shin, 2001
% function dc = Euler2Dcm(roll, pitch, heading)
% 2025补充：roll右倾为正，pitch上仰为正，yaw北方向为0度，顺时针为正
function dc = Euler2Dcm(roll, pitch, heading)

dc = zeros(3);
cr = cos(roll); cp = cos(pitch); ch = cos(heading);
sr = sin(roll); sp = sin(pitch); sh = sin(heading);

dc(1,1) = cp * ch ;
dc(1,2) = -cr*sh + sr*sp*ch;
dc(1,3) = sr*sh + cr*sp*ch ;

dc(2,1) = cp * sh;
dc(2,2) = cr*ch + sr*sp*sh;
dc(2,3) = -sr * ch + cr * sp * sh;

dc(3,1) = - sp;
dc(3,2) = sr * cp;
dc(3,3) = cr * cp;