% Fuling Lin, 20190101
 
function SRDCFdecon_Demo_one_seq(~)    % 记得和该文件名一致, xxx是tracker的简写
    close all;
    clear;
    clc;
    
    %% **Need to change**
    tpye_of_assessment = 'UAV123_10fps';                                   % 要测试的类型，'OTB100','UAV123_10fps', 'UAV123', 'UAV123_20L'              
    tracker_name = 'SRDCFdecon';                                                  % 要测试的tracker名称              
    
    setup_paths();
    %% Load video information, 记得修改load_video_information函数里面的路径
    seq = load_video_information(tpye_of_assessment);                      % 加载序列信息
    
    result  =  run_SRDCFdecon(seq);
    
    % save results
    results = cell(1,1);                                                   % results是包含一个结构体的元胞，结构体包括type,res,fps,len,annoBegin,startFrame六个成员
    results{1} = result;
    results{1}.len = seq.len;
    results{1}.startFrame = seq.st_frame;
    results{1}.annoBegin = seq.st_frame;
    
    % save results to specified folder
    save_dir = '.\Test_one_seq\';
    save_res_dir = [save_dir, tracker_name, '_results\'];                  % 保存数据结果的路径，以KCF为例，效果如：'.\all_trk_results\KCF_results\'
    save_pic_dir = [save_res_dir, 'res_picture\'];                         % 保存图片的路径，以KCF为例，效果如：'.\all_trk_results\KCF_results\res_picture\'
    if ~exist(save_res_dir, 'dir')
        mkdir(save_res_dir);
        mkdir(save_pic_dir);
    end 
    save([save_res_dir, seq.video_name, '_', tracker_name], 'results');        % 以特定名称保存数据结果，以KCF跑bike1的结果为例，效果如：'.\all_trk_results\KCF_results\bike1_KCF.mat'
    
    % plot precision figure
    show_visualization = 1;
    precision_plot_save(results{1}.res, seq.ground_truth, seq.video_name, save_pic_dir, show_visualization); 