%
% Convert Euler angles to Dirction Cosine Matrix - ENU system
% by Xiao Sun, 2025
%
function dc = Euler2Dcm_ENU(roll, pitch, heading)

cr = cos(roll); cp = cos(pitch); cy = cos(heading);
sr = sin(roll); sp = sin(pitch); sy = sin(heading);

dc = [cp*cy, cp*sy, -sp;
       sr*sp*cy - cr*sy, sr*sp*sy + cr*cy, sr*cp;
       cr*sp*cy + sr*sy, cr*sp*sy - sr*cy, cr*cp];