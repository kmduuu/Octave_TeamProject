clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('D:\test/Received_Signal.wav');

% Original Signal의 평균 전력 계산
signal_0_to_1 = x(1:1*fs); % 0초부터 1초까지
noise = mean(abs(signal_0_to_1).^2);
signal_1_to_3 = x(fs+1:3*fs); % 1초부터 3초까지
P_sig = mean(abs(signal_1_to_3).^2);

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

passband1 = [2000]/(fs/2); %주파수 범위 정의
filter_order = 1000; % 필터 차수 설정
bandpass_filter1 = fir1(filter_order, passband1, 'low');
% Original Signal에 BandPass FIR 필터 적용
filtered_signal1 = filter(bandpass_filter1, 1, x);

passband2 = [3400]/(fs/2); %주파수 범위 정의
bandpass_filter2 = fir1(filter_order, passband2, 'high');
% Original Signal에 BandPass FIR 필터 적용 수정
filtered_signal2 = filter(bandpass_filter2, 1, x);

% filtered_signal Spectrogram 생성
[S_filtered1, freq_filtered1, t_f1] = specgram(filtered_signal1, 1024, fs, hann(1024), 512);
[S_filtered2, freq_filtered2, t_f2] = specgram(filtered_signal2, 1024, fs, hann(1024), 512);

% filtered_signal Spectrogram
figure;
subplot(2,1,1);
imagesc(t_f1, freq_filtered1, 20*log10(abs(S_filtered1)));
axis xy;
title('low Filtered Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

subplot(2,1,2);
imagesc(t_f2, freq_filtered2, 20*log10(abs(S_filtered2)));
axis xy;
title('high Filtered Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

% filtered_signal1의 평균 전력 계산
filtered1_0_to_1 = filtered_signal1(1:1*fs);
filtered_noise1 = mean(abs(filtered1_0_to_1).^2);

filtered1_1_to_3 = filtered_signal1(fs+1:3*fs);
filtered_P_sig1 = mean(abs(filtered1_1_to_3).^2) - filtered_noise1;


filtered2_0_to_2 = filtered_signal2(1:1*fs);
filtered_noise2 = mean(abs(filtered2_0_to_2).^2);

filtered2_1_to_3 = filtered_signal2(fs+1:3*fs);
filtered_P_sig2 = mean(abs(filtered2_1_to_3).^2) - filtered_noise2;

SNR_high = filtered_P_sig2/noise
SNR_dB_high = 10*log10(SNR_high)
SNR_low = filtered_P_sig1/noise
SNR_dB_low = 10*log10(SNR_low)
