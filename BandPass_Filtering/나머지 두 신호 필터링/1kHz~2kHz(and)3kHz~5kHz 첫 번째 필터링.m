#-------------------------------------코드설명-------------------------------------

% 1. 해당 코드는 1kHz => 2kHz로 상승하는 주파수 성분을 분리하여 스펙트로그램으로 시각화 하였습니다.
% 2. 5kHz => 3kHz로 하강하는 주파수 성분을 분리하여 스펙트로그램으로 시각화 하였습니다.
% 3. 이 후 상승 주파수 성분, 하강 주파수 성분을 출력합니다.

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

lowcut_downward = 3420;
highcut_downward = 5000;
filter_range_downward = (frequencies > lowcut_downward & frequencies < highcut_downward) | ...
                        (frequencies > (fs - highcut_downward) & frequencies < (fs - lowcut_downward));

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
imagesc(times_upward, freqs_upward, 10*log10(abs(S_upward))); % Y축 범위 자동 조절
axis xy;
title('Filtered Signal Spectrogram (1kHz to 2kHz)');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

subplot(2,1,2);
imagesc(times_downward, freqs_downward, 10*log10(abs(S_downward))); % Y축 범위 자동 조절
axis xy;
title('Filtered Signal Spectrogram (5kHz to 3kHz)');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

% 필터링된 신호를 WAV 파일로 저장
audiowrite('D:/test/lastFilter_Upward.wav', real(filtered_signal_upward), fs);
audiowrite('D:/test/lastFilter_Downward.wav', real(filtered_signal_downward), fs);


