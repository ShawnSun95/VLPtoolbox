function plot3Dtraj(X,LED,is_gt,coordinates)
%plot3Dtraj 绘制3D轨迹、LED位置和真值轨迹

    figure;plot3(X(:,1),X(:,2),X(:,3),'.-');
    xlabel('X (m)')
    ylabel('Y (m)')
    zlabel('Z (m)')
    % 添加起始点和终点标记
    hold on;
    plot3(X(1,1), X(1,2), X(1,3), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot3(X(end,1), X(end,2), X(end,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    hold on;
    axis equal
    zlim([0 3]);
    
    % 绘制三维坐标图
    if(is_gt == 1)
        plot3(coordinates(:,2), coordinates(:,3), coordinates(:,4), 'r-', 'MarkerSize', 10, 'LineWidth', 1);
        grid on;
        xlabel('X坐标');
        ylabel('Y坐标');
        zlabel('Z坐标');
        title('三维坐标分布图');
    end
    [nLED,~]=size(LED);
    for i=1:nLED
        scatter3(LED(i,1),LED(i,2),LED(i,3),'r*');
    end
    legend('坐标轨迹', '起点', '终点','参考真值','LED');
end