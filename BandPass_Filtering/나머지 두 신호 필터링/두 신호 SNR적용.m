#-------------------------------------코드설명-------------------------------------

% 1. 해당 코드는 1kHz => 2kHz로 상승하는 주파수 성분을 분리후 계산한 SNR 값을 확인할 수 있습니다.
% 2. 5kHz => 3kHz로 하강하는 주파수 성분을 분리후 계산한 SNR 값을 확인할 수 있습니다.

#---------------------------------------------------------------------------------

clc; clear;
pkg load signal;

% WAV 파일 읽기
[x, fs] = audioread('D:\test/Received_Signal.wav');

% Set the first second of the signal to zeros
x(1:fs) = 0;

% FFT를 통해 주파수 영역으로 변환
X = fft(x);
N = length(X);
frequencies = (0:N-1)*(fs/N); % 주파수 계산

lowcut_upward = 930;
highcut_upward = 2070;
filter_range_upward = (frequencies > lowcut_upward & frequencies < highcut_upward) | ...
                      (frequencies > (fs - highcut_upward) & frequencies < (fs - lowcut_upward));

lowcut_downward = 3350;
highcut_downward = 5000;
filter_range_downward = (frequencies > lowcut_downward & frequencies < highcut_downward) | ...
                        (frequencies > (fs - highcut_downward) & frequencies < (fs - lowcut_downward));

X_filtered_upward = X;
X_filtered_upward(~filter_range_upward) = 0;
filtered_signal_upward = ifft(X_filtered_upward);

X_filtered_downward = X;
X_filtered_downward(~filter_range_downward) = 0;
filtered_signal_downward = ifft(X_filtered_downward);

% Filtered Signal의 전체 전력 계산 (1초부터 3초까지)
start_time_filtered = 1;
end_time_filtered = 3;
start_index_filtered_upward = floor(start_time_filtered * fs) + 1;
end_index_filtered_upward = floor(end_time_filtered * fs);
filtered_signal_power_upward = sum(abs(filtered_signal_upward(start_index_filtered_upward:end_index_filtered_upward)).^2) / length(filtered_signal_upward(start_index_filtered_upward:end_index_filtered_upward));

start_index_filtered_downward = floor(start_time_filtered * fs) + 1;
end_index_filtered_downward = floor(end_time_filtered * fs);
filtered_signal_power_downward = sum(abs(filtered_signal_downward(start_index_filtered_downward:end_index_filtered_downward)).^2) / length(filtered_signal_downward(start_index_filtered_downward:end_index_filtered_downward));

% Filtered Signal의 잡음 전력 계산 (0초부터 1초까지)
start_time_filtered_part = 0;
end_time_filtered_part = 1;
start_index_filtered_part_upward = floor(start_time_filtered_part * fs) + 1;
end_index_filtered_part_upward = floor(end_time_filtered_part * fs);
filtered_noise_power_part_upward = sum(abs(filtered_signal_upward(start_index_filtered_part_upward:end_index_filtered_part_upward)).^2) / length(filtered_signal_upward(start_index_filtered_part_upward:end_index_filtered_part_upward));

start_index_filtered_part_downward = floor(start_time_filtered_part * fs) + 1;
end_index_filtered_part_downward = floor(end_time_filtered_part * fs);
filtered_noise_power_part_downward = sum(abs(filtered_signal_downward(start_index_filtered_part_downward:end_index_filtered_part_downward)).^2) / length(filtered_signal_downward(start_index_filtered_part_downward:end_index_filtered_part_downward));

power_difference_upward = filtered_signal_power_upward - filtered_noise_power_part_upward;
power_difference_downward = filtered_signal_power_downward - filtered_noise_power_part_downward;

% 3.5985e-05는 Original-signal의 잡음 전력 값
fprintf('Upward Filtered Signal SNR: %f dB\n', 10 * log10(power_difference_upward / 3.5985e-05));
fprintf('Downward Filtered Signal SNR: %f dB\n', 10 * log10(power_difference_downward / 3.5985e-05));
