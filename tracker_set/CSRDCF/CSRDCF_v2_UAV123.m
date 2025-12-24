function CSRDCF_v2_UAV123(save_dir)  %  xxx是tracker的简写; 默认输入是'.\Test_yymmdd_hhmm\'
close all;
clc;
addpath('utils');
addpath('UAV123_utils');
addpath('features');
addpath('mex');

%% **Need to change**
% 根据所在电脑进行地址匹配'FLPC:1','403:2','YJPC:3'
pc = 3;
switch pc
    % where_is_your_groundtruth_folder 包含所有数据集groundtruth文件的路径
    % where_is_your_UAV123_database_folder 包含所有数据集图片序列的路径
    case 1
        where_is_your_groundtruth_folder = 'D:\Res\tracking_data\UAV123_10fps\anno\UAV123_10fps';
        where_is_your_UAV123_database_folder = 'D:\Res\tracking_data\UAV123_10fps\data_seq\UAV123_10fps';
    case 2
        where_is_your_groundtruth_folder = 'C:\Users\Dell\Desktop\Dataset_UAV123_10fps\UAV123_10fps\anno\UAV123_10fps';
        where_is_your_UAV123_database_folder = 'C:\Users\Dell\Desktop\Dataset_UAV123_10fps\UAV123_10fps\data_seq\UAV123_10fps';
    case 3
        where_is_your_groundtruth_folder = 'D:\TTTTTTracking\Dataset\Dataset_UAV123_10fps\UAV123_10fps\anno\UAV123_10fps';
        where_is_your_UAV123_database_folder = 'D:\TTTTTTracking\Dataset\Dataset_UAV123_10fps\UAV123_10fps\data_seq\UAV123_10fps';
    otherwise
        warning('Unexpected PC!!!');
end
type_of_assessment = 'UAV123_10fps';                                   % 要测试的类型，'UAV123_10fps', 'UAV123', 'UAV123_20L'
tracker_name = 'CSRDCF';

ground_truth_folder = where_is_your_groundtruth_folder;
dir_output = dir(fullfile(ground_truth_folder, '\*.txt'));             % 获取该文件夹下的所有的txt文件
contents = {dir_output.name}';
all_video_name = {};
for k = 1:numel(contents)
    name1 = contents{k}(1:end-4);                                       % 去掉后缀 .txt
    all_video_name{end+1,1} = name1;                                    % 保存所有数据集名称
end
dataset_num = length(all_video_name);                                  % 从groundtruth总文件数得到数据集总数
type = type_of_assessment;

% for count1 = 1 : length(set1)
%     name1 = num2str(set1(count1));
%     for count2 = 1 : length(set2)
%         name2 = num2str(set2(count2));
% for dataset_count = begin : dataset_num
begin = 38; % 99 truck1/47 car7/10 boat4
for dataset_count = begin:dataset_num
    video_name = all_video_name{dataset_count};                         % 读取数据集名称
    database_folder = where_is_your_UAV123_database_folder;            % 包含所有数据集图片序列的路径
    seq = load_video_info_UAV123(video_name, database_folder, ground_truth_folder, type); % 加载序列信息
    fprintf('%d %s\n', dataset_count, video_name);
    
    visualization = 1;
    % main function,执行算法主函数，返回为结构体，至少包含type,res,fps三个成员
    result = run_CSRDCF_v2(seq, visualization);
    
    % save results
    results = cell(1,1);                                               % results是包含一个结构体的元胞，结构体包括type,res,fps,len,annoBegin,startFrame六个成员
    results{1} = result;
    results{1}.len = seq.len;
    results{1}.startFrame = seq.st_frame;
    results{1}.annoBegin = seq.st_frame;
    fprintf('%d %s----fps: %f\n', dataset_count, video_name, results{1}.fps);
    
    % save results to specified folder
    if nargin < 1
        if dataset_count == begin
            time_dir = datestr(now,'yymmdd-HHMM');
            save_dir = ['.\Test-' time_dir '\'];                              % 保存跑完的结果到指定文件夹，命名格式: Test_yymmdd_hhmm
        else
            save_dir = ['.\Test-' time_dir '\'];
        end
    end
    save_res_dir = [save_dir, tracker_name, '_results\'];              % 保存数据结果的路径，以KCF为例，效果如：'.\all_trk_results\KCF_results\'
    save_pic_dir = [save_res_dir,  '_res_picture\'];
    if ~exist(save_pic_dir, 'dir')
        mkdir(save_res_dir);
        mkdir(save_pic_dir);
    end
    save([save_res_dir, seq.video_name, '_', tracker_name, '.mat'], 'results');
    show_visualization = 1;                                            % 显示图片（precision_plot）结果
    precision_plot_save(results{1}.res, seq.ground_truth, seq.video_name, save_pic_dir, show_visualization);
    close all;
    % end
    % end
end