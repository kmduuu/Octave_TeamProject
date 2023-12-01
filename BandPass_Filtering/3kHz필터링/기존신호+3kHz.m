clc; clear;
pkg load signal;

# -----------------------------------------------------------------------------
% 음성 파일 읽기
[x, fs] = audioread('C:\test/Received_Signal.wav');

% 주파수 대역 설정
frequencies = (0:length(x)-1)*(fs/length(x)); % 주파수 계산
% FFT를 통해 주파수 영역으로 변환
X = fft(x);

# 1. 주파수 3kHz 제외 모두 제거하기
% 주파수가 3 kHz 주변에 해당하는 부분을 선택
target_frequency = 3000;
tolerance = 50; % 주파수의 허용 오차 범위
target_range = frequencies > target_frequency - tolerance & frequencies < target_frequency + tolerance;
% 3 kHz 주파수 대역만 남기고 나머지는 0으로 설정
X(~target_range) = 0;
% 역 FFT를 통해 시간 영역으로 변환하여 3 kHz 주파수 성분만 남긴 신호 재구성
filtered_signal = ifft(X);
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
% 시간 벡터 생성(필터링 전 시간 도메인 표현하기 위함함)
t = (0:length(x)-1) / fs;
% 음성 신호 그래프 그리기
subplot(2,1,1);
plot(t, x);
xlabel('시간 (초)');
ylabel('신호');
title('시간 도메인에서의 음성 신호');
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
frequencies = (0:length(x)-1)*(fs/length(x)); % 주파수 계산 % 주파수 대역 설정
X = fft(x); % FFT를 통해 주파수 영역으로 변환
% 주파수 영역에서의 신호 확인을 위해 주파수 스펙트럼 플롯
subplot(2,1,2);
plot(frequencies, abs(X));
xlabel('주파수 (Hz)');
ylabel('신호 강도');
title('주파수 스펙트럼');
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
% 시간 벡터 생성
t_filtered = (0:length(filtered_signal)-1) / fs;
% 필터링 된 시간 도메인 그래프 출력
figure;
subplot(2, 1, 1);
plot(t_filtered, filtered_signal);
xlabel('시간 (초)');
ylabel('신호');
title('3 kHz 주파수 성분만 남긴 신호의 시간 도메인');
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
% 주파수 대역 설정
frequencies_filtered = (0:length(filtered_signal)-1)*(fs/length(filtered_signal));
% FFT를 통해 주파수 영역으로 변환
X_filtered = fft(filtered_signal);

% (3kHz) 필터링 된 주파수 스펙트럼 그래프 출력
subplot(2, 1, 2);
plot(frequencies_filtered, abs(X_filtered));
xlabel('주파수 (Hz)');
ylabel('신호 강도');
title('3 kHz 주파수 성분만 남긴 신호의 주파수 스펙트럼');
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
% STFT 사용하여 비교하기
% 전체 신호의 스펙트로그램
figure;
subplot(3,1,1);
[S, f, t] = specgram(x, 1024, fs, hann(1024), 512);
imagesc(t, f, 10*log10(abs(S))); % dB 단위로 변환하여 이미지로 표시
axis xy; % Y 축을 뒤집어 올바른 방향으로 표시
title('Original Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar; % 컬러바 추가

% 기존 신호의 (0초~1초 필터링 된) 스펙트로그램
subplot(3,1,2);
x(1:fs) = 0; % 0초부터 1초까지의 값은 zeros로 설정
[S_filtered, f, t] = specgram(x, 1024, fs, hann(1024), 512);
imagesc(t, f, 10*log10(abs(S_filtered))); % dB 단위로 변환하여 이미지로 표시
axis xy; % Y 축을 뒤집어 올바른 방향으로 표시
title('Filtered Signal Spectrogram (Zeroed 0-1 sec)');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar; % 컬러바 추가

% (3kHz)필터링 된 신호의 스펙트로그램
subplot(3,1,3);
filtered_signal(1:fs) = 0; % 0초부터 1초까지의 값은 zeros로 설정
[S_filtered, f_filtered, t_filtered] = specgram(filtered_signal, 1024, fs, hann(1024), 512);
imagesc(t_filtered, f_filtered, 10*log10(abs(S_filtered))); % dB 단위로 변환하여 이미지로 표시
axis xy; % Y 축을 뒤집어 올바른 방향으로 표시
title('3 kHz 주파수 성분만 남긴 신호의 스펙트로그램');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar; % 컬러바 추가
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
% 필터링 전 기존 사운드 재생
disp("Before Filtering sound");
sound(x,fs);
pause(length(x)/fs);
% 1. (3kHz)필터링 후 사운드 재생
disp("After Filtering Sound (3kHz)");
audiowrite('c:/test/testing/Filtered_Signal_3kHz.wav', filtered_signal, fs);
sound(filtered_signal, fs);
pause(length(filtered_signal)/fs);

