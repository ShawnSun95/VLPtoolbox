% VLP 3D定位，默认水平放置，只需VLP数据
% is_gt变量设置用全站仪数据做真值，并用IMU数据做杆臂校正
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath("../function");
is_gt=1; % 是否使用真值系统
[VLPfile,TSfile,IMUfile,idx1,idx2,t0_TS,t0_IMU,std,yaw0]=...
    config_from_yaml('../config/20251127_1.yaml');
[LED,nLED,a,M,fhz,fs,dt,rate]=...
    VLP_parameter('../config/VLP_parameter.yaml', 3);
TS_h = 1.5963;
leverarm=[0.11;0.10;-0.02];
x0=4.5;y0=1.5;h=0;
% 检查files的值是否为'newest'
if strcmp(VLPfile, 'newest')
    VLPfile=read_newest_VLP('data');
end

fid3=load("../data/"+VLPfile);
fid3=fid3(2:end-1); 

if(is_gt==1)
    imu_data=read_imu_data("../data/"+IMUfile);
    imu_data.Time=imu_data.Time+t0_IMU; % IMU时间同步
    imu_data.Yaw = imu_data.Yaw + 180;

    coordinates = read_TS_data("../data/"+TSfile,idx1,idx2);
    coordinates(:,1)=coordinates(:,1)-coordinates(1,1)+t0_TS; %时间同步
    coordinates(:,4)=coordinates(:,4)+TS_h; %加仪器高
    coordinates=leverarm_corr_TS(coordinates,leverarm,imu_data); % 杆臂校正
end
figure;subplot(2,1,1);
plot(fid3);

[m,n]=size(fid3);
if(n==1)
    fid3=fid3';
end

% FFT
[t,fft_result]=VLP_preprocess_highfreq_ham(fid3,nLED,fhz,fs,dt,rate);
num_point=length(t);

X=zeros(num_point,nLED+3);

% 3D定位，通过优化方法实现
for k=1:num_point
    %初值
    lb=[0,0,0]; ub=[10,8,3];
    options = optimoptions('lsqnonlin', 'Display', 'off');
    X0 = [x0, y0, h];
    % 匿名函数传递额外参数
    objFun = @(x) Lambert3(x, LED, a, M, fft_result(k,:), std);
    % 调用 lsqnonlin：x0, lb, ub, options
    [sol, resnorm, residual] = lsqnonlin(objFun, X0, lb, ub, options);
    
    X(k,1:3)=sol;
    X(k,3+1:3+nLED)=residual';
end

subplot(2,1,2);
for i=1:nLED
    plot(t,fft_result(:,i));hold on;
end
xlabel('Time (s)')
ylabel('RSS')
legend('LED1','LED2','LED3','LED4','LED5','LED6');

plot3Dtraj(X,LED,is_gt,coordinates);

figure;subplot(2,1,1);
plot(X(:,1));
ylabel('X (m)')
subplot(2,1,2);
plot(X(:,2));
xlabel('Time (s)')
ylabel('Y (m)')

% 评估精度并绘图
if(is_gt)
    [~,err]=accuracy_eval(t',X(:,1:3),coordinates(:,1),coordinates(:,2:4));
end