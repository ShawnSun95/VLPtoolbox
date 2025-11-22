% 读取全站仪真值数据，2025.11.18
% 使用MS60GS.FRT格式导出，带时间戳

function T_filtered = read_TS_MS60GS(filename, idx1, idx2)
    % 读取整个文件内容为一个字符串
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件 %s', filename);
    end
    rawText = fread(fid, '*char')'; % 读取为字符行向量并转置为行字符串
    fclose(fid);
    
    % 使用正则表达式匹配每条记录
    % 模式说明：
    % TPS_Auto_\d{4}        : 匹配 "TPS_Auto_" 后跟4位数字
    % ,\s*                  : 匹配逗号及任意空白（包括空格）
    % ([+-]?\d*\.?\d+)      : 匹配浮点数（支持科学计数法可选，这里简化）
    % ,\s*([+-]?\d*\.?\d+)
    % ,\s*([+-]?\d*\.?\d+)
    % ,\s*(\d{1,2}:\d{1,2}:\d{1,2}\.\d{3}) : 匹配时间戳，例如 10:32:29.710

    % 读取坐标数据
    pattern = 'TPS_Auto_(\d{4}),\s*([+-]?\d*\.?\d+),\s*([+-]?\d*\.?\d+),\s*([+-]?\d*\.?\d+),\s*(\d{1,2}:\d{1,2}:\d{1,2}\.\d{3})';
    
    % 执行匹配（'tokens' 返回捕获组）
    tokens = regexp(rawText, pattern, 'tokens');
    
    % tokens 是一个 cell 数组，每个元素是一个匹配项的字段 cell
    if isempty(tokens)
        error('未找到任何匹配的记录，请检查文件格式或正则表达式。');
    end
    
    % 提取各列
    n = length(tokens);
    pointNames = strings(n, 1);
    x = zeros(n, 1);
    y = zeros(n, 1);
    z = zeros(n, 1);
    t = zeros(n, 1);
    timestamps = strings(n, 1);
    
    for i = 1:n
        pointNames(i) = "TPS_Auto_" + tokens{i}{1};  % 重新加上前缀
        x(i) = str2double(tokens{i}{2});
        y(i) = str2double(tokens{i}{3});
        z(i) = str2double(tokens{i}{4});
        timestamps(i) = tokens{i}{5};

        % 对每个时间字符串用正则提取 h, m, s
        tokens_time = regexp(timestamps(i), '(\d{1,2}):(\d{1,2}):(\d{1,2}\.\d{3})', 'tokens');
        h = cellfun(@(x) str2double(x{1}), tokens_time);
        m = cellfun(@(x) str2double(x{2}), tokens_time);
        s = cellfun(@(x) str2double(x{3}), tokens_time);
        t(i) = h*3600 + m*60 + s;
    end
    
    % 显示结果（可选）
    T = table(pointNames, x, y, z, t, ...
        'VariableNames', {'PointName', 'X', 'Y', 'Z', 'Time'});

    % 步骤1：从 PointName 中提取 TPS_Auto_ 后的数字（作为数值）
    % 使用正则表达式提取数字部分
    pointNumStr = regexp(T.PointName, 'TPS_Auto_(\d+)', 'tokens');
    % 转换为数值向量
    pointNum = cellfun(@(x) str2double(x{1}), pointNumStr);
    
    % 步骤2：构建逻辑索引
    validIdx = (pointNum >= idx1) & (pointNum <= idx2) & (T.X ~= 99999);
    
    % 步骤3：提取符合条件的子表
    T_filtered = T(validIdx, :);
end