show_visualization = 0;
show_plots = 1;
video_path_UAV123 = 'C:\Users\Van\Documents\MATLAB\Dataset_UAV123_10fps\UAV123_10fps\data_seq\UAV123_10fps';
ground_truth_path_UAV123 = 'C:\Users\Van\Documents\MATLAB\Dataset_UAV123_10fps\UAV123_10fps\anno\UAV123_10fps';
% video_name ={'try'};
% video_name ={'bike1','bike2','bike3','bird1_1','bird1_2','bird1_3','boat1','boat2','boat3','boat4','boat5','boat6','boat7','boat8','boat9','building1','building2','building3','building4',...
%     'building5','car1_1','car1_2','car1_3','car1_s','car2','car2_s','car3','car3_s','car4','car4_s','car5','car6_1','car6_2','car6_3','car6_4','car6_5','car7','car8_1','car8_2','car9','car10','car11','car12','car13','car14','car15',...
%     'car16_1','car16_2','car17','car18','group1_1','group1_2','group1_3','group1_4','group2_1','group2_2','group2_3','group3_1','group3_2','group3_3','group3_4','person1','person1_s','person2_1','person2_2','person2_s','person3','person3_s','person4_1','person4_2','person5_1','person5_2','person6','person7_1','person7_2',...
%     'person8_1','person8_2','person9','person10','person11','person12_1','person12_2','person13','person14_1','person14_2','person14_3','person15','person16','person17_1','person17_2','person18','person19_1','person19_2','person19_3','person20','person21','person22',...
%     'person23','truck1','truck2','truck3','truck4_1','truck4_2','uav1_1','uav1_2','uav1_3','uav2','uav3','uav4','uav5','uav6','uav7','uav8','wakeboard1','wakeboard2','wakeboard3','wakeboard4','wakeboard5',...
%     'wakeboard6','wakeboard7','wakeboard8','wakeboard9','wakeboard10'};
video_name ={'car4_s','car5','car6_1','car6_2','car6_3','car6_4','car6_5','car7','car8_1','car8_2','car9','car10','car11','car12','car13','car14','car15',...
    'car16_1','car16_2','car17','car18','group1_1','group1_2','group1_3','group1_4','group2_1','group2_2','group2_3','group3_1','group3_2','group3_3','group3_4','person1','person1_s','person2_1','person2_2','person2_s','person3','person3_s','person4_1','person4_2','person5_1','person5_2','person6','person7_1','person7_2',...
    'person8_1','person8_2','person9','person10','person11','person12_1','person12_2','person13','person14_1','person14_2','person14_3','person15','person16','person17_1','person17_2','person18','person19_1','person19_2','person19_3','person20','person21','person22',...
    'person23','truck1','truck2','truck3','truck4_1','truck4_2','uav1_1','uav1_2','uav1_3','uav2','uav3','uav4','uav5','uav6','uav7','uav8','wakeboard1','wakeboard2','wakeboard3','wakeboard4','wakeboard5',...
    'wakeboard6','wakeboard7','wakeboard8','wakeboard9','wakeboard10'};
% video_name ={'try'};
	
    kernel.type =  'linear';

    padding = 2;  %extra area surrounding the target
    lambda1 = 1e-4;     %regularization
    lambda2 = 0.4;
    interp_factor = 0.005;  %linear interpolation factor for adaptation
    output_sigma_factor = 0.1; %spatial bandwidth (proportional to target)

    features.gray = false;
    features.hog = false;
    features.hogcolor = true;
    features.hog_orientations = 9;

    cell_size = 4;
M = size(video_name);
m = M(1,2);
for i=1:m
seq = load_video_info_UAV123(video_name(1,i), video_path_UAV123, ground_truth_path_UAV123);
video_path = seq.video_path;
ground_truth = seq.ground_truth;
videos = dir(video_path);
img_files = seq.s_frames;
    target_sz = [ground_truth(1,4), ground_truth(1,3)];
    pos = [ground_truth(1,2), ground_truth(1,1)] + floor(target_sz/2);
		[positions,rect_results, time] = tracker(video_path, img_files, pos, target_sz, ...
			padding, kernel, lambda1, lambda2, output_sigma_factor, interp_factor, ...
			cell_size, features, show_visualization);
		results.res = rect_results;
        positions = results.res(:,1:2);
        num_frames = numel(img_files);
    results.fps = num_frames/time;
    title = cell2mat(video_name(1,i));
precisions = precision_plot(positions, ground_truth, title,'C:\Users\Van\Documents\MATLAB\Context-Aware-CF-Tracking\SAMF_CA\UAV_SAMF_CA\', 1);
save(title,'results');
end
		
	

%
%  Context-Aware Correlation Filters
%
%  Written by Joao F. Henriques, 2014
%  Revised by Yang Li, August, 2014
%  Adapted by Matthias Mueller, 2016
%
%  This function takes care of setting up parameters, loading video
%  information and computing precisions. For the actual tracking code,
%  check out the TRACKER function.
%
%  RUN_TRACKER
%    Without any parameters, will ask you to choose a video, 
%    and show the results in an interactive figure. 
%    Press 'Esc' to stop the tracker early. You can navigate the
%    video using the scrollbar at the bottom.
%
%  RUN_TRACKER VIDEO
%    Allows you to select a VIDEO by its name. 'all' will run all videos
%    and show average statistics. 'choose' will select one interactively.
%
%  RUN_TRACKER(VIDEO, SHOW_VISUALIZATION, SHOW_PLOTS)
%    Decide whether to show the scrollable figure, and the precision plot.

% function [precision, fps] = run_tracker(video, show_visualization, show_plots)
% 
% 	%path to the videos (you'll be able to choose one with the GUI).
% 	base_path = 'sequences/';
% 
% 	%default settings
% 	if nargin < 1, video = 'Car1'; end
% 	if nargin < 2, show_visualization = ~strcmp(video, 'all'); end
% 	if nargin < 3, show_plots = ~strcmp(video, 'all'); end
% 
% 
%     %default settings
%     kernel.type =  'linear';
% 
%     padding = 2;  %extra area surrounding the target
%     lambda1 = 1e-4;     %regularization
%     lambda2 = 0.4;
%     interp_factor = 0.005;  %linear interpolation factor for adaptation
%     output_sigma_factor = 0.1; %spatial bandwidth (proportional to target)
% 
%     features.gray = false;
%     features.hog = false;
%     features.hogcolor = true;
%     features.hog_orientations = 9;
% 
%     cell_size = 4;
% 
% 
% 	switch video
% 	case 'choose',
% 		%ask the user for the video, then call self with that video name.
% 		video = choose_video(base_path);
% 		if ~isempty(video),
% 			[precision, fps] = run_tracker(video, show_visualization, show_plots);
% 			
% 			if nargout == 0,  %don't output precision as an argument
% 				clear precision
% 			end
% 		end
% 		
% 		
% 	case 'all',
% 		%all videos, call self with each video name.
% 		
% 		%only keep valid directory names
% 		dirs = dir(base_path);
% 		videos = {dirs.name};
% 		videos(strcmp('.', videos) | strcmp('..', videos) | ...
% 			strcmp('anno', videos) | ~[dirs.isdir]) = [];
% 		
% 		%the 'Jogging' sequence has 2 targets, create one entry for each.
% 		%we could make this more general if multiple targets per video
% 		%becomes a common occurence.
% 		videos(strcmpi('Jogging', videos)) = [];
% 		videos(end+1:end+2) = {'Jogging.1', 'Jogging.2'};
% 		
% 		all_precisions = zeros(numel(videos),1);  %to compute averages
% 		all_fps = zeros(numel(videos),1);
% 		
% 		if ~exist('matlabpool', 'file'),
% 			%no parallel toolbox, use a simple 'for' to iterate
% 			for k = 1:numel(videos),
% 				[all_precisions(k), all_fps(k)] = run_tracker(videos{k}, show_visualization, show_plots);
% 			end
% 		else
% 			%evaluate trackers for all videos in parallel
% 			if matlabpool('size') == 0,
% 				matlabpool open;
% 			end
% 			parfor k = 1:numel(videos),
% 				[all_precisions(k), all_fps(k)] = run_tracker(videos{k}, show_visualization, show_plots);
% 			end
% 		end
% 		
% 		%compute average precision at 20px, and FPS
% 		mean_precision = mean(all_precisions);
% 		fps = mean(all_fps);
% 		fprintf('\nAverage precision (20px):% 1.3f, Average FPS:% 4.2f\n\n', mean_precision, fps)
% 		if nargout > 0,
% 			precision = mean_precision;
% 		end
% 		
% 		
% 	case 'benchmark',
% 		%running in benchmark mode - this is meant to interface easily
% 		%with the benchmark's code.
% 		
% 		%get information (image file names, initial position, etc) from
% 		%the benchmark's workspace variables
% 		seq = evalin('base', 'subS');
% 		target_sz = seq.init_rect(1,[4,3]);
% 		pos = seq.init_rect(1,[2,1]) + floor(target_sz/2);
% 		img_files = seq.s_frames;
% 		video_path = [];
% 		
% 		%call tracker function with all the relevant parameters
% 		[positions,rect_results,t]= tracker(video_path, img_files, pos, target_sz, ...
% 			padding, kernel, lambda1, lambda2, output_sigma_factor, interp_factor, ...
% 			cell_size, features, 0);
% 		
% 		%return results to benchmark, in a workspace variable
% 		rects =rect_results;
% %         [positions(:,2) - target_sz(2)/2, positions(:,1) - target_sz(1)/2];
% % 		rects(:,3) = target_sz(2);
% % 		rects(:,4) = target_sz(1);
% 		res.type = 'rect';
% 		res.res = rects;
% 		assignin('base', 'res', res);
% 		
% 		
% 	otherwise
% 		%we were given the name of a single video to process.
% 	
% 		%get image file names, initial state, and ground truth for evaluation
% 		[img_files, pos, target_sz, ground_truth, video_path] = load_video_info(base_path, video);
% 		
% 		
% 		%call tracker function with all the relevant parameters
% 		[positions,~, time] = tracker(video_path, img_files, pos, target_sz, ...
% 			padding, kernel, lambda1, lambda2, output_sigma_factor, interp_factor, ...
% 			cell_size, features, show_visualization);
% 		
% 		
% 		%calculate and show precision plot, as well as frames-per-second
% 		precisions = precision_plot(positions, ground_truth, video, show_plots);
% 		fps = numel(img_files) / time;
% 
% 		fprintf('%12s - Precision (20px):% 1.3f, FPS:% 4.2f\n', video, precisions(20), fps)
% 
% 		if nargout > 0,
% 			%return precisions at a 20 pixels threshold
% 			precision = precisions(20);
% 		end
% 
% 	end
% end
