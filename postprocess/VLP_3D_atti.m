% VLP 3D定位，可放置任意姿态，需带欧拉角的IMU数据
% 使用全站仪进行真值评估，需杆臂校正
% 使用yaml文件中的时间差进行时间同步
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
addpath("../function");
[VLPfile,TSfile,IMUfile,idx1,idx2,t0_TS,t0_IMU,std,yaw0]=...
    config_from_yaml('../config/20251127_1.yaml');
[LED,nLED,a,M,fhz,fs,dt,rate]=...
    VLP_parameter('../config/VLP_parameter.yaml', 3);
TS_h = 1.5963;
leverarm=[0.11;0.10;-0.02];
x0=4.5;y0=1.5;h=0;

fid3=load("../data/"+VLPfile);
fid3=fid3(2:end-1); 

% 读IMU数据
imu_data=read_imu_data("../data/"+IMUfile);
imu_data.Time=imu_data.Time+t0_IMU; % IMU时间同步
imu_data.Yaw = imu_data.Yaw + 180; % 室内坐标系的y轴朝南
imu_data.Yaw = imu_data.Yaw - imu_data.Yaw(1) + yaw0; %设定初始航向
plot_export_imu_data(imu_data);

% 读全站仪数据
coordinates = read_TS_data("../data/"+TSfile,idx1,idx2);
coordinates(:,1)=coordinates(:,1)-coordinates(1,1)+t0_TS; % 时间同步
coordinates(:,4)=coordinates(:,4)+TS_h; %加仪器高
coordinates=leverarm_corr_TS(coordinates,leverarm,imu_data); % 杆臂校正

% 将xsens IMU的输出转换到NED系下
imu_data.Pitch = -imu_data.Pitch;
imu_data.Yaw = 90 - imu_data.Yaw;

[m,n]=size(fid3);
if(n==1)
    fid3=fid3';
end

[t,fft_result]=VLP_preprocess_highfreq(fid3,nLED,fhz,fs,dt,rate);
num_point=length(t);
X=zeros(num_point,nLED+3);

% 用于RSS分析
[common_t, interp_roll, interp_pitch, interp_yaw, interpolated_coords] =...
    alignIMUandCoordinates(t, imu_data, coordinates);
p=[NED2ENU(interpolated_coords),interp_roll,interp_pitch,interp_yaw];

% 3D定位，通过优化方法实现
for k=1:num_point
    [~, idx] = min(abs(imu_data.Time - t(k)));
    roll = imu_data.Roll(idx)/180*pi;
    pitch = imu_data.Pitch(idx)/180*pi;
    yaw = imu_data.Yaw(idx)/180*pi;
    
    %初值
    lb=[0,0,0]; ub=[10,8,3];
    options = optimoptions('lsqnonlin', 'Display', 'off');
    X0 = [x0, y0, h];
    % 匿名函数传递额外参数
    objFun = @(x) Lambert4(x, LED, a, M, roll, pitch, yaw, fft_result(k,:), std);
    % 调用 lsqnonlin：x0, lb, ub, options
    [sol, resnorm, residual] = lsqnonlin(objFun, X0, lb, ub, options);
    
    X(k,1:3)=sol;
    X(k,3+1:3+nLED)=residual';
end
fprintf('解算完成！\n');

figure;subplot(2,1,1);
plot(fid3);
subplot(2,1,2);
for i=1:nLED
    plot(t,fft_result(:,i));hold on;
end
xlabel('Time (s)')
ylabel('RSS')
legend('LED1','LED2','LED3','LED4','LED5','LED6');

plot3Dtraj(X,LED,1,coordinates);

figure;
subplot(3,1,1);
plot(t,X(:,1));
hold on;plot(coordinates(:,1),coordinates(:,2))
ylabel('X (m)')
xlabel('Time (s)')
legend('Est', 'GT');
grid on;

subplot(3,1,2);
plot(t,X(:,2));
hold on;plot(coordinates(:,1),coordinates(:,3))
ylabel('Y (m)')
legend('Est', 'GT');
grid on;

subplot(3,1,3);
plot(imu_data.Time, [imu_data.Acc_X, imu_data.Acc_Y, imu_data.Acc_Z]);
xlabel('时间 (s)');
ylabel('加速度 (m/s²)');
legend('Acc_X', 'Acc_Y', 'Acc_Z');
grid on;

linkaxes(findall(gcf,'type','axes'),'x');

% 评估精度并绘图
[~,err]=accuracy_eval(t',X(:,1:3),coordinates(:,1),coordinates(:,2:4));

% 根据全站仪数据预测RSS，看看哪个误差最大
RSS=preRSSrpy(p, a, M, NED2ENU(LED));
% RSS=preRSS(NED2ENU(p(:,1:3)), a, M, LED);
pos = get(gcf, 'Position');
figure('Position', [pos(1), pos(2)-200, pos(3), pos(4)+200]);
sgtitle('实测RSS与真值预测的RSS对比')
for i=1:nLED
    subplot(nLED,1,i);
    plot(common_t,RSS(:,i));
    hold on;
    plot(t,fft_result(:,i));
    legend('RSS预测值','RSS观测值');
    ylabel(['LED',num2str(i)]);
end
xlabel('Time (s)')

% 输出结果和真值到文件
output(VLPfile, TSfile, t, X, fft_result, coordinates);