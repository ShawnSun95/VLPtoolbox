% 使用IMU数据中的方位角修正全站仪的杆臂
% TS_data：第一列为时间，后三列xyz
% IMU和全站仪时间需要同步
% 2025.11.20

function output=leverarm_corr_TS(TS_data, leverarm, imu_data)
t=TS_data(:,1);
coordinates=TS_data(:,2:4);
output=zeros(size(coordinates));
output(:,1)=t;

for i=1:length(t)
    [~, idx] = min(abs(imu_data.Time - t(i)));
    theta=imu_data.Yaw(idx)/180*pi;
    Rz = [cos(theta), -sin(theta), 0;
          sin(theta),  cos(theta), 0;
          0,           0,          1];
    
    rotated_leverarm = Rz * leverarm;
    % disp(rotated_leverarm');
    output(i,2:4)=coordinates(i,:)+rotated_leverarm';
end
