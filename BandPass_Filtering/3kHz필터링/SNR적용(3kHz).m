#-------------------------------------코드설명-------------------------------------

% 1. 해당 코드는 Original-signal의 SNR 값을 확인할 수 있습니다.
% 2. 3kHz에 대해 BandPassFiltering한 signal의 SNR 값을 확인할 수 있습니다.

#---------------------------------------------------------------------------------

clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('C:\test/Received_Signal.wav');

% -----------------------------------------------------------------------------
% Original Signal의 평균 전력 계산

signal_0_to_1 = x(1:1*fs); % 0초부터 1초까지
noise = mean(abs(signal_0_to_1).^2)
signal_1_to_3 = x(fs+1:3*fs); % 1초부터 3초까지
P_sig = mean(abs(signal_1_to_3).^2)

Original_SNR_dB_ = 10*log10(P_sig/noise)

X = fft(x); % FFT 연산
X_shifted = fftshift(X); % 주파수 영역 재배치
% 주파수 스펙트럼 그리기
frequencies = (-fs/2:fs/length(X_shifted):(fs/2-fs/length(X_shifted))); % 주파수 벡터 생성

figure;
plot(frequencies, abs(X_shifted));
title('주파수 스펙트럼');
xlabel('주파수 (Hz)');
ylabel('세기');

% BandPass FIR 필터 적용

passband1 = [2800 3200]/(fs/2); % 2950~3050Hz 주파수 범위 정의
filter_order = 1000; % 필터 차수 설정
bandpass_filter = fir1(filter_order, passband1, 'bandpass');
% Original Signal에 BandPass FIR 필터 적용
filtered_signal = filter(bandpass_filter, 1, x);

% Original Signal의 Spectogram 생성
[S, freq, t] = specgram(x, 1024, fs, hann(1024), 512);

% filtered_signal Spectogram 생성
[S_filtered, freq_filtered, t_f] = specgram(filtered_signal, 1024, fs, hann(1024), 512);

% Original Signal Spectogram
figure;
subplot(2,1,1);
imagesc(t, freq, 20*log10(abs(S)));
axis xy;
title('Original Signal Spectrogram');
xlabel('Time[sec]');
ylabel('Frequency[Hz]');
colorbar;

% filtered_signal Spectogram
subplot(2,1,2);
imagesc(t_f, freq_filtered, 20*log10(abs(S_filtered)));
axis xy;
title('Filtered Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

% filtered_signal의 평균 전력 계산

filtered_0_to_1 = filtered_signal(1:1*fs);
filtered_noise = mean(abs(filtered_0_to_1).^2);

filtered_1_to_3 = filtered_signal(fs+1:3*fs);
filtered_P_sig = mean(abs(filtered_1_to_3).^2) - filtered_noise;

SNR_3k = filtered_P_sig/noise
SNR_dB_3k = 10*log10(SNR_3k)

P_sig/noise
