function [common_t, interp_roll, interp_pitch, interp_yaw, interpolated_coords] = alignIMUandCoordinates(t, imu_data, coordinates)
%ALIGNIMUANDCOORDINATES 对齐 IMU 加速度和坐标数据到共同时间段，并以内插方式对齐到 coordinates 时间基准
%
% 输入:
%   t                 : 任意参考时间向量（用于确定共同时间段）
%   imu_data          : 结构体，必须包含字段 .Time 和 .Acce_X（列向量或行向量）
%   coordinates       : N×4 矩阵，第1列为时间戳，第2~4列为XYZ坐标
%
% 输出:
%   common_t          : 共同时间段的时间向量（即 coordinates 时间中落在共同区间内的部分）
%   interpolated_Acce_X: 在 common_t 上内插得到的 Acce_X 值
%   interpolated_coords: 在 common_t 上的坐标值（其实就是 coordinates(:,2:4) 中对应 common_t 的部分）

    % 提取时间向量
    t_imu = imu_data.Time(:);        % 确保为列向量
    t_coord = coordinates(:,1);
    coords_xyz = coordinates(:,2:4);
    
    % 找出三个时间序列的共同时间范围（交集）
    t_min = max([min(t), min(t_imu), min(t_coord)]);
    t_max = min([max(t), max(t_imu), max(t_coord)]);
    
    if t_min >= t_max
        error('没有共同的时间段。');
    end
    
    % 在 IMU 的时间中筛选出落在 [t_min, t_max] 内的时间点
    valid_idx = (t_imu >= t_min) & (t_imu <= t_max);
    common_t = t_imu(valid_idx);
    
    if isempty(common_t)
        error('在共同时间段内没有有效的 coordinate 时间点。');
    end
    
    % 内插全站仪数据到 common_t
    interp_roll = imu_data.Roll(valid_idx)/180*pi;
    interp_pitch = imu_data.Pitch(valid_idx)/180*pi;
    interp_yaw = imu_data.Yaw(valid_idx)/180*pi;
    
    % 将 coordinates(:,2:4) 内插到 common_t（基于 coordinates 的时间列 t_coord）
    % 使用线性插值，对每一列分别插值
    interpolated_coords = interp1(t_coord, coords_xyz, common_t, 'linear');
    
end