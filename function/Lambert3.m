% 朗伯模型计算函数，用于水平3D定位

function f = Lambert3(X, LED, a, M, RSS, std)
    nled = length(a);
    f = zeros(nled, 1);
    for iled = 1:nled
        LOS = LED(iled, :) - X;      % 从 X 指向 LED 的向量
        s = norm(LOS);
        if s == 0
            % 避免除零（X 与 LED 重合，物理上不合理）
            cos_alpha = 0;
        else
            cos_alpha = LOS(3) / s;  % 等价于 [0,0,1] * LOS' / norm(LOS)
        end
        % Lambertian 模型：仅当 cos_alpha > 0 时有贡献
        if cos_alpha > 0
            P_rec = a(iled) * (cos_alpha^(M(iled) + 1)) / (s^2);
        else
            P_rec = 0;  % 背对或侧面，无接收功率
        end
        
        f(iled) = (P_rec - RSS(iled)) / std(iled);  % 加权残差
    end
end