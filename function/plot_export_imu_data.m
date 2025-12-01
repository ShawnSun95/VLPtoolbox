% 绘制数据，并输出文件
function plot_export_imu_data(imu_data, output_filename)
% 绘制IMU数据图表
    figure;
    
    % 绘制加速度数据
    subplot(3,2,1);
    plot(imu_data.Second, [imu_data.Acc_X, imu_data.Acc_Y, imu_data.Acc_Z]);
    title('加速度数据');
    xlabel('时间 (s)');
    ylabel('加速度 (m/s²)');
    legend('Acc_X', 'Acc_Y', 'Acc_Z');
    grid on;
    
    % 绘制角速度数据
    subplot(3,2,2);
    plot(imu_data.Second, [imu_data.Gyr_X, imu_data.Gyr_Y, imu_data.Gyr_Z]);
    title('角速度数据');
    xlabel('时间 (s)');
    ylabel('角速度 (rad/s)');
    legend('Gyr_X', 'Gyr_Y', 'Gyr_Z');
    grid on;
    
    % 绘制欧拉角
    subplot(3,2,3);
    plot(imu_data.Second, [imu_data.Roll, imu_data.Pitch, imu_data.Yaw]);
    title('欧拉角');
    xlabel('时间 (s)');
    ylabel('角度 (°)');
    legend('Roll', 'Pitch', 'Yaw');
    grid on;
    
    % 绘制加速度模值
    subplot(3,2,4);
    acc_magnitude = sqrt(imu_data.Acc_X.^2 + imu_data.Acc_Y.^2 + imu_data.Acc_Z.^2);
    plot(imu_data.Second, acc_magnitude);
    title('加速度模值');
    xlabel('时间 (s)');
    ylabel('|Acc| (m/s²)');
    grid on;
    
    % 绘制角速度模值
    subplot(3,2,5);
    gyr_magnitude = sqrt(imu_data.Gyr_X.^2 + imu_data.Gyr_Y.^2 + imu_data.Gyr_Z.^2);
    plot(imu_data.Second, gyr_magnitude);
    title('角速度模值');
    xlabel('时间 (s)');
    ylabel('|Gyr| (rad/s)');
    grid on;
    
    % 绘制数据包计数器
    subplot(3,2,6);
    plot(imu_data.Second, imu_data.PacketCounter);
    title('数据包计数器');
    xlabel('时间 (s)');
    ylabel('PacketCounter');
    grid on;
    
    if nargin == 2
        % 准备输出数据：时间、加速度三轴、角速度三轴
        output_data = [imu_data.Second, imu_data.Acc_X, imu_data.Acc_Y, imu_data.Acc_Z, ...
                       imu_data.Gyr_X, imu_data.Gyr_Y, imu_data.Gyr_Z];
        
        % 打开文件用于写入
        fid = fopen(output_filename, 'w');
        if fid == -1
            error('无法创建输出文件: %s', output_filename);
        end
        
        % 写入数据，列之间用\t分隔
        for i = 1:size(output_data, 1)
            fprintf(fid, '%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\n', output_data(i, :));
        end
        
        % 关闭文件
        fclose(fid);
        
        fprintf('成功输出数据到: %s\n', output_filename);
        fprintf('数据格式: 时间(s)\tAcc_X\tAcc_Y\tAcc_Z\tGyr_X\tGyr_Y\tGyr_Z\n');
        fprintf('数据行数: %d\n', size(output_data, 1));
    end
end