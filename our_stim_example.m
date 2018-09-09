sigmas = 0.05:0.05:3;

stim_frame_lab = rgb2lab(imread('trial_002/frame01.png'));
% Extract luminocity only
stim = stim_frame_lab(:, :, 3);
for i = 2:9
   stim_frame_lab = rgb2lab(imread(['trial_002/frame0' num2str(i) '.png']));
   stim = cat(3, stim, stim_frame_lab(:,:,3));
end
for i = 10:60
   stim_frame_lab = rgb2lab(imread(['trial_002/frame' num2str(i) '.png']));
   stim = cat(3, stim, stim_frame_lab(:,:,3));
end

% Need to extract the central square of the image
[stim_height, stim_width, n_frames] = size(stim);
letterbox_border_width = (stim_width - stim_height) / 2;
stim = double(stim(:, letterbox_border_width+1:letterbox_border_width+stim_height, :));
[stim_height, stim_width, n_frames] = size(stim);

% simulate some dots
display.frameRate  = 60; % Hz
display.width      = 49; % cm
% display.height     = 37; % cm
display.dist       = 129; % cm
display.res.width  = stim_width; % pixels
% display.res.height  = stim_height; % pixels
display.ppd        = deg2pix(display, 1);

setup.nframes      = 60; %1 * display.frameRate; % shorter for testing quickly

%% CREATE SPATIAL AND TEMPORAL FILTERS

motion_energy = nan(size(sigmas, 2), 60);
velocity      = nan(size(sigmas, 2), 60);

for i = 1:numel(sigmas)
    sigma = sigmas(i);
    
    % temporal range of the filter
    cfg = struct();
    cfg.frameRate  = display.frameRate;
    cfg.ppd        = display.ppd;
    cfg.k          = 60; % k = 60, from Kiani et al. 2008
    cfg.sigma_c    = sigma;
    cfg.sigma_g    = sigma;
    
    [f1, f2] = makeSpatialFilters_flipped(cfg);
    [g1, g2] = makeTemporalFilters(cfg);
    
    disp(['Applying filters with sigma ' num2str(sigma)]);
    energy, v = applyFilters(stim, f1, f2, g1, g2);
    motion_energy(i, :) = squeeze(sum(sum(energy)));
    velocity(i, :) = squeeze(sum(sum(energy)));
end

