clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('D:\test/Received_Signal.wav');

% Original Signal의 평균 전력 계산
signal_0_to_1 = x(1:1*fs); % 0초부터 1초까지
noise = mean(abs(signal_0_to_1).^2);
signal_1_to_3 = x(fs+1:3*fs); % 1초부터 3초까지
P_sig = mean(abs(signal_1_to_3).^2);

Original_SNR = P_sig/noise;

Original_SNR_dB_ = 10*log10(P_sig/noise)

% BandPass FIR 필터 적용

passband1 = [2800 3200]/(fs/2);
filter_order = 1000; % 필터 차수 설정
bandpass_filter1 = fir1(filter_order, passband1, 'bandpass');
% Original Signal에 BandPass FIR 필터 적용
filtered_signal1 = filter(bandpass_filter1, 1, x);

passband2 = [1000 2000]/(fs/2); %주파수 범위 정의
filter_order = 1000; % 필터 차수 설정
bandpass_filter2 = fir1(filter_order, passband2, 'bandpass');
% Original Signal에 BandPass FIR 필터 적용
filtered_signal2 = filter(bandpass_filter2, 1, x);

passband3 = [3400 5000]/(fs/2); %주파수 범위 정의
bandpass_filter3 = fir1(filter_order, passband3, 'bandpass');
% Original Signal에 BandPass FIR 필터 적용 수정
filtered_signal3 = filter(bandpass_filter3, 1, x);

% filtered_signal1의 평균 전력 계산
filtered1_0_to_1 = filtered_signal1(1:1*fs);
filtered_noise1 = mean(abs(filtered1_0_to_1).^2);
filtered1_1_to_3 = filtered_signal1(fs+1:3*fs);
filtered_P_sig1 = mean(abs(filtered1_1_to_3).^2) - filtered_noise1;

filtered2_0_to_2 = filtered_signal2(1:1*fs);
filtered_noise2 = mean(abs(filtered2_0_to_2).^2);
filtered2_1_to_3 = filtered_signal2(fs+1:3*fs);
filtered_P_sig2 = mean(abs(filtered2_1_to_3).^2) - filtered_noise2;

filtered2_0_to_2 = filtered_signal3(1:1*fs);
filtered_noise3 = mean(abs(filtered2_0_to_2).^2);
filtered2_1_to_3 = filtered_signal3(fs+1:3*fs);
filtered_P_sig3 = mean(abs(filtered2_1_to_3).^2) - filtered_noise3;

SNR_3kHz = filtered_P_sig1/noise
SNR_dB_3kHz = 10*log10(SNR_3kHz)
SNR_high = filtered_P_sig2/noise
SNR_dB_high = 10*log10(SNR_high)
SNR_low = filtered_P_sig3/noise
SNR_dB_low = 10*log10(SNR_low)

% 결과 출력
SNR_check = SNR_3kHz+SNR_high+SNR_low+1;
disp(Original_SNR);
disp(SNR_check);

% SNR 값 차이
disp(Original_SNR - SNR_check);

