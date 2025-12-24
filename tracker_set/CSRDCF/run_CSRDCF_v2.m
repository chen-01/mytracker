function results = run_CSRDCF_v2(seq, visualization)

video_path = seq.video_path; % 图像文件夹路径
startFrm = seq.st_frame;
endFrm = seq.en_frame;
nFrames = seq.len;

% Initialize the tracker
time = 0;
tic;
img1 = imread(sprintf('%s%06d.jpg', video_path, startFrm));
gt1 = seq.ground_truth(1,:);
rect_positions(1,:) = seq.ground_truth(1,:);

% [state, ~] = tracker_dpcf_initialize_modified(img1, gt1, cfg, visualization);
% tracker = create_csr_tracker_modified(img1, gt1, init_params); %
tracker = create_csr_tracker_modified_v2(img1, gt1, visualization);
% 原有为三个输入，两个输入则为缺省

% begin looping
for current_frame=2:nFrames
    img = imread(sprintf('%s%06d.jpg', video_path, startFrm+current_frame-1));
    % Perform a tracking step, obtain new region
    %     [state, region] = tracker_dpcf_modified(state, img, cfg, visualization);
    tracker.frame = current_frame;
    [tracker, region] = track_csr_tracker_modified_v2(tracker, img, visualization);
    rect_positions(current_frame,:) = region;
    
end
time = time + toc();
results.type = 'rect';
results.res = rect_positions;
% results.fps = num_frames/(elapsed_time - t_imread);
results.fps = nFrames/time;
end