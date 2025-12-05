% 输出结果和真值到文件，自动替换上一次的输出
function output(VLPfile, TSfile, t, X, fft_result, coordinates)
    % 构造完整文件路径
    VLPFilePath = fullfile('..', 'output', VLPfile);
    TSFilePath = fullfile('..', 'output', TSfile);
    
    % 获取该文件所在的目录路径
    [folderPath, ~, ~] = fileparts(VLPFilePath);
    
    % 如果目录不存在，则递归创建
    if ~exist(folderPath, 'dir')
        mkdir(folderPath);
    end
    
    % 写VLP定位结果
    [n_vlp,~]=size(X);
    [~,nLED]=size(fft_result);
    fid1=fopen(VLPFilePath, 'w');
    for i=1:n_vlp
        fprintf(fid1,"%.2f\t%.3f\t%.3f\t%.3f",t(i),X(i,1),X(i,2),X(i,3));
        for iled=1:nLED
            fprintf(fid1,"\t%.3f",fft_result(i,iled));
        end
        fprintf(fid1,"\n");
    end
    
    % 写全站仪真值
    [n_ts,~]=size(coordinates);
    fid2=fopen(TSFilePath, 'w');
    for i=1:n_ts
        fprintf(fid2,"%.2f\t%.3f\t%.3f\t%.3f\n",...
            coordinates(i,1),coordinates(i,2),coordinates(i,3),coordinates(i,4));
    end
    
    % 关闭文件
    fclose(fid1);
    fclose(fid2);

    fprintf('导出定位结果：%s\n', VLPFilePath);
    fprintf('导出位置真值：%s\n', TSFilePath);