clc; clear;
pkg load signal;

% WAV 파일 읽기
[x, fs] = audioread('C:\test/Received_Signal.wav');

% Set the first second of the signal to zeros
x(1:fs) = 0;

% FFT를 통해 주파수 영역으로 변환
X = fft(x);
N = length(X);
frequencies = (0:N-1)*(fs/N); % 주파수 계산

% Define the desired filter ranges
lowcut_upward = 950;
highcut_upward = 2050;
filter_range_upward = (frequencies > lowcut_upward & frequencies < highcut_upward) | ...
                      (frequencies > (fs - highcut_upward) & frequencies < (fs - lowcut_upward));

lowcut_downward = 3450;
highcut_downward = 5000;
filter_range_downward = (frequencies > lowcut_downward & frequencies < highcut_downward) | ...
                        (frequencies > (fs - highcut_downward) & frequencies < (fs - lowcut_downward));

% Apply the filters
X_filtered_upward = X;
X_filtered_upward(~filter_range_upward) = 0;
filtered_signal_upward = ifft(X_filtered_upward);

X_filtered_downward = X;
X_filtered_downward(~filter_range_downward) = 0;
filtered_signal_downward = ifft(X_filtered_downward);

% 필터링된 신호의 스펙트로그램 생성
[S_upward, freqs_upward, times_upward] = specgram(filtered_signal_upward, 1024, fs, hann(1024), 512);
[S_downward, freqs_downward, times_downward] = specgram(filtered_signal_downward, 1024, fs, hann(1024), 512);

% 0초에서 1초까지의 부분을 zeros로 설정
start_time_zero = 0;
end_time_zero = 1;
start_index_zero_upward = find(times_upward >= start_time_zero, 1);
end_index_zero_upward = find(times_upward <= end_time_zero, 1, 'last');
S_upward(:, start_index_zero_upward:end_index_zero_upward) = 0;

start_index_zero_downward = find(times_downward >= start_time_zero, 1);
end_index_zero_downward = find(times_downward <= end_time_zero, 1, 'last');
S_downward(:, start_index_zero_downward:end_index_zero_downward) = 0;

% 스펙트로그램 시각화
figure;
subplot(2,1,1);
imagesc(times_upward, freqs_upward, 20*log10(abs(S_upward))); % Y축 범위 자동 조절
axis xy;
title('Filtered Signal Spectrogram (1kHz to 3kHz)');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

subplot(2,1,2);
imagesc(times_downward, freqs_downward, 20*log10(abs(S_downward))); % Y축 범위 자동 조절
axis xy;
title('Filtered Signal Spectrogram (3kHz to 5kHz)');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

% 필터링된 신호를 WAV 파일로 저장
audiowrite('C:/test/lastFilter_Upward.wav', real(filtered_signal_upward), fs);
audiowrite('C:/test/lastFilter_Downward.wav', real(filtered_signal_downward), fs);

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

fprintf('Upward Filtered Signal - Signal Power: %f, Noise Power: %f, SNR: %.2f dB\n', filtered_signal_power_upward, filtered_noise_power_part_upward, 10 * log10(power_difference_upward / 3.5985e-05));
fprintf('Downward Filtered Signal - Signal Power: %f, Noise Power: %f, SNR: %.2f dB\n', filtered_signal_power_downward, filtered_noise_power_part_downward, 10 * log10(power_difference_downward / 3.5985e-05));

