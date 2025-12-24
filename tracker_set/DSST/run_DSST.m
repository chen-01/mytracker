function results = run_DSST(seq)
% run_tracker.m

close all;
% clear all;

%choose the path to the videos (you'll be able to choose one with the GUI)
% base_path = 'sequences/';

%parameters according to the paper
params.padding = 1.0;         			% extra area surrounding the target
params.output_sigma_factor = 1/16;		% standard deviation for the desired translation filter output
params.scale_sigma_factor = 1/4;        % standard deviation for the desired scale filter output
params.lambda = 1e-2;					% regularization weight (denoted "lambda" in the paper)
params.learning_rate = 0.025;			% tracking model learning rate (denoted "eta" in the paper)
params.number_of_scales = 33;           % number of scale levels (denoted "S" in the paper)
params.scale_step = 1.02;               % Scale increment factor (denoted "a" in the paper)
params.scale_model_max_area = 512;      % the maximum size of scale examples

params.visualization = 1;

%ask the user for the video
% video_path = choose_video(base_path);
% if isempty(video_path), return, end  %user cancelled
% [img_files, pos, target_sz, ground_truth, video_path] = ...
% 	load_video_info(video_path);
params.wsize = [seq.init_rect(1,4), seq.init_rect(1,3)];
params.init_pos = [seq.init_rect(1,2), seq.init_rect(1,1)] + floor(params.wsize/2);
params.img_files = seq.s_frames;
params.video_path = seq.video_path;

results = dsst(params);
end

