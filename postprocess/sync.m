% 时间同步脚本，通过绘图观察修改yaml文件的时间同步参数，并迭代验证
% 通过调整t0_TS和t0_IMU两个参数，使图中不同传感器的时间轴对齐
% 用于后续定位VLP_3D.m等脚本

addpath("../function");
clear;
[VLPfile,TSfile,IMUfile,idx1,idx2,t0_TS,t0_IMU,~]=...
    config_from_yaml('../config/20251127_1.yaml');
[LED,nLED,a,M,fhz,fs,dt,rate]=...
    VLP_parameter('../config/VLP_parameter.yaml', 3);% VLP参数

%预处理全站仪和IMU数据
TS_h = 1.5963;
leverarm=[0.11;0.10;-0.02];

fid3=load("../data/"+VLPfile);
fid3=fid3(2:end-1); 
t0_VLP=VLP_t0(VLPfile,0);
fprintf('VLP的初始时间为%.2f秒\n',t0_VLP);
fprintf('====\n');

% 读IMU和全站仪数据，并预处理
coordinates = read_TS_data("../data/"+TSfile,idx1,idx2);
fprintf('全站仪的初始时间为%.2f秒\n',coordinates(1,1));
fprintf('全站仪与VLP的时间同步误差为%.2f秒\n',coordinates(1,1)-t0_VLP-t0_TS);
fprintf('====\n');
coordinates(:,1)=coordinates(:,1)-coordinates(1,1)+t0_TS; %时间同步
coordinates(:,4)=coordinates(:,4)+TS_h; %加仪器高

imu_data=read_imu_data("../data/"+IMUfile);
fprintf('IMU的初始时间为%.2f秒\n',imu_data.Second(1));
fprintf('IMU与VLP的时间同步误差为%.2f秒\n',imu_data.Second(1)-t0_VLP-t0_IMU);
imu_data.Time=imu_data.Time+t0_IMU; %时间同步
imu_data.Yaw = imu_data.Yaw + 180;
% plot_export_imu_data(imu_data);

coordinates=leverarm_corr_TS(coordinates,leverarm,imu_data); % 杆臂校正
[nTS,~]=size(coordinates);

% 绘图
figure;subplot(3,1,1);
plot(imu_data.Time,[imu_data.Gyr_X, imu_data.Gyr_Y, imu_data.Gyr_Z]);
legend('Gyr_X','Gyr_Y','Gyr_Z')
ylabel('Gyroscope (rad/s)')
sgtitle('通过IMU数据与全站仪位置、VLP原始观测对比，确定时间差')
subplot(3,1,2);plot(coordinates(:,1),coordinates(:,2:4));
ylabel('X/Y/Z (m)')
legend('X','Y','Z')
subplot(3,1,3);
t_VLP=(1:length(fid3))/fs;
plot(t_VLP,fid3)
ylabel('VLP illumination')
linkaxes(findall(gcf,'type','axes'),'x');
pos = get(gcf, 'Position');
xlabel('Time (s)')

% FFT计算RSS
[~,n]=size(fid3);
if(n==1)
    fid3=fid3';
end

[t,fft_result]=VLP_preprocess_highfreq_ham(fid3,nLED,fhz,fs,dt,rate);
num_point=length(t);

% 内插时间
valid = (t > coordinates(1, 1)) & (t < coordinates(end, 1));
RSS_obs=fft_result(valid,:);
xyz_interp = interp1(coordinates(:,1), coordinates(:,2:4), t(valid), 'linear');

% 根据全站仪预测RSS并画图，用于全站仪和VLP同步
RSS=preRSS(xyz_interp, a, M, LED);
figure('Position', [pos(1), pos(2)-200, pos(3), pos(4)+200]);
sgtitle('通过全站仪真值预测的RSS与实际RSS对比，确定时间差')
for i=1:nLED
    subplot(nLED,1,i);
    plot(t,fft_result(:,i));hold on;
    plot(t(valid),RSS(:,i));
    legend('RSS观测值','RSS预测值');
    ylabel(['LED',num2str(i)]);
end
xlabel('Time (s)')