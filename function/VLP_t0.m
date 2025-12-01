% 通过VLP文件名读取初始时间，int_sec表示是否输出整形时间

function t0=VLP_t0(files,int_sec)

% 正则表达式匹配：YYYYMMDD_HHMMSS[frac].ext
pattern = '^(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})_(\d+)\..*$';

% 执行匹配
if contains(files, '/')
    filename = extractAfter(files, '/');
else
    filename = files;
end

tokens = regexp(filename, pattern, 'tokens');

if isempty(tokens)
    error('文件名格式不匹配预期模式！');
end

% 提取各部分（cell 转 double）
hour   = str2double(tokens{1}{4});
minute = str2double(tokens{1}{5});
second = str2double(tokens{1}{6});

% 小数部分
num_digits = length(tokens{1}{7});
if num_digits == 1
    sec_frac = str2double(tokens{1}{7})/10;
elseif num_digits == 2
    sec_frac = str2double(tokens{1}{7})/100;
end
second = second + sec_frac;

t0=(hour-8)*3600+minute*60+second;
if(int_sec)
    if(str2double(tokens{1}{7})>5)
        offset=1.5-sec_frac;
    else
        offset=0.5-sec_frac;
    end
    t0=t0+offset+0.5;
end