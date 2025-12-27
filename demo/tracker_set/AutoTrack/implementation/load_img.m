function img = load_img(video_path, s_frames, frame)

    try
        im = imread([video_path '/img/' s_frames{frame}]);
    catch

        try
            im = imread([s_frames{frame}]);
        catch
            im = imread([video_path '/' s_frames{frame}]);
        end

    end

end
