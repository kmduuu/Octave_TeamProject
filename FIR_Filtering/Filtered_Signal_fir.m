clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('C:/test/Received_Signal.wav');

% Set the first second of the signal to zeros
x(1:fs) = 0;

% 1000~2000Hz 주파수 범위 정의
passband1 = [1000/(fs/2) 2000/(fs/2)]; % 주파수 정규화
% 3700~5000Hz 주파수 범위 정의
passband2 = [3700/(fs/2) 5000/(fs/2)]; % 주파수 정규화

% FIR 필터 설계 - 1000~2000Hz 대역
filter_order = 100; % 필터 차수 설정
fir_filter1 = fir1(filter_order, passband1, 'bandpass');
% FIR 필터 설계 - 3700~5000Hz 대역
fir_filter2 = fir1(filter_order, passband2, 'bandpass');

% 1000~2000Hz 필터링
filtered_signal_1000to2000 = filter(fir_filter1, 1, x);
% 3700~5000Hz 필터링
filtered_signal_3700to5000 = filter(fir_filter2, 1, x);

% 각 필터링 결과를 각각의 파일로 저장
output_file_1000to2000 = 'C:/test/Filtered_Signal_1000to2000_fir.wav';
output_file_3700to5000 = 'C:/test/Filtered_Signal_3700to5000_fir.wav';

audiowrite(output_file_1000to2000, filtered_signal_1000to2000, fs);
audiowrite(output_file_3700to5000, filtered_signal_3700to5000, fs);

% 스펙트로그램 생성
[S_1000to2000, freqs_1000to2000, times_1000to2000] = specgram(filtered_signal_1000to2000, 1024, fs, hann(1024), 512);
[S_3700to5000, freqs_3700to5000, times_3700to5000] = specgram(filtered_signal_3700to5000, 1024, fs, hann(1024), 512);

% 0초에서 1초까지의 부분을 zeros로 설정
start_time_zero = 0;
end_time_zero = 1;
start_index_zero_upward = find(times_1000to2000 >= start_time_zero, 1);
end_index_zero_upward = find(times_1000to2000 <= end_time_zero, 1, 'last');
S_upward(:, start_index_zero_upward:end_index_zero_upward) = 0;

start_index_zero_downward = find(times_3700to5000 >= start_time_zero, 1);
end_index_zero_downward = find(times_3700to5000 <= end_time_zero, 1, 'last');
S_downward(:, start_index_zero_downward:end_index_zero_downward) = 0;

% 1000~2000Hz 필터링 결과의 스펙트로그램 시각화
figure;
subplot(2,1,1);
imagesc(times_1000to2000, freqs_1000to2000, 20*log10(abs(S_1000to2000))); % Y축 범위 자동 조절
axis xy;
title('Filtered Signal (1000Hz to 2000Hz) Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

% 3700~5000Hz 필터링 결과의 스펙트로그램 시각화
subplot(2,1,2);
imagesc(times_3700to5000, freqs_3700to5000, 20*log10(abs(S_3700to5000))); % Y축 범위 자동 조절
axis xy;
title('Filtered Signal (3700Hz to 5000Hz) Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;


% Filtered Signal의 전체 전력 계산 (1초부터 3초까지)
start_time_filtered = 1;
end_time_filtered = 3;
start_index_filtered_upward = floor(start_time_filtered * fs) + 1;
end_index_filtered_upward = floor(end_time_filtered * fs);
filtered_signal_power_upward = sum(abs(filtered_signal_1000to2000(start_index_filtered_upward:end_index_filtered_upward)).^2) / length(filtered_signal_1000to2000(start_index_filtered_upward:end_index_filtered_upward));

start_index_filtered_downward = floor(start_time_filtered * fs) + 1;
end_index_filtered_downward = floor(end_time_filtered * fs);
filtered_signal_power_downward = sum(abs(filtered_signal_3700to5000(start_index_filtered_downward:end_index_filtered_downward)).^2) / length(filtered_signal_3700to5000(start_index_filtered_downward:end_index_filtered_downward));

% Filtered Signal의 잡음 전력 계산 (0초부터 1초까지)
start_time_filtered_part = 0;
end_time_filtered_part = 1;
start_index_filtered_part_upward = floor(start_time_filtered_part * fs) + 1;
end_index_filtered_part_upward = floor(end_time_filtered_part * fs);
filtered_noise_power_part_upward = sum(abs(filtered_signal_1000to2000(start_index_filtered_part_upward:end_index_filtered_part_upward)).^2) / length(filtered_signal_1000to2000(start_index_filtered_part_upward:end_index_filtered_part_upward));

start_index_filtered_part_downward = floor(start_time_filtered_part * fs) + 1;
end_index_filtered_part_downward = floor(end_time_filtered_part * fs);
filtered_noise_power_part_downward = sum(abs(filtered_signal_3700to5000(start_index_filtered_part_downward:end_index_filtered_part_downward)).^2) / length(filtered_signal_3700to5000(start_index_filtered_part_downward:end_index_filtered_part_downward));

power_difference_upward = filtered_signal_power_upward - filtered_noise_power_part_upward;
power_difference_downward = filtered_signal_power_downward - filtered_noise_power_part_downward;

fprintf('Upward Filtered Signal - Signal Power: %f, Noise Power: %f, SNR: %.2f dB\n', filtered_signal_power_upward, filtered_noise_power_part_upward, 10 * log10(power_difference_upward / 3.5985e-05));
fprintf('Downward Filtered Signal - Signal Power: %f, Noise Power: %f, SNR: %.2f dB\n', filtered_signal_power_downward, filtered_noise_power_part_downward, 10 * log10(power_difference_downward / 3.5985e-05));


