function files = read_newest_VLP(data_dir)
    % 获取data目录下所有文件的信息
    file_list = dir(fullfile(data_dir, '*'));
    
    % 过滤掉目录（包括 '.' 和 '..'），只保留普通文件
    is_valid_file = ~[file_list.isdir] & ~strcmp({file_list.name}, '.')...
        & ~strcmp({file_list.name}, '..');
    file_list = file_list(is_valid_file);
    
    % 检查目录中是否有文件
    if isempty(file_list)
        error('目录 "%s" 中没有文件', data_dir);
    end
    
    % 按修改日期排序，最新的文件在前
    [~, idx] = sort([file_list.datenum], 'descend');
    file_list = file_list(idx);
    
    % 获取最新文件的文件名（不含路径），将files赋值为最新的文件名
    files = file_list(1).name;
    
    % 可选：显示信息
    fprintf('已选择最新文件: %s\n', files);
end