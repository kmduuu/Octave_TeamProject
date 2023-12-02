clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('C:/test/Received_Signal.wav');
passHigh = [3400 5000]/(fs/2); %주파수 범위 정의
filter_order = 1000; % 필터 차수 설정
Highpass_filter = fir1(filter_order, passHigh, 'bandpass');
% Original Signal에 Highpass FIR 필터 적용
Highpass_signal = filter(Highpass_filter, 1, x);

passLow = [1000 2000]/(fs/2); %주파수 범위 정의
Lowpass_filter = fir1(filter_order, passLow, 'bandpass');
% Original Signal에 Lowpass FIR 필터 적용
Lowpass_signal = filter(Lowpass_filter, 1, x);

passband = [2950 3050]/(fs/2); %주파수 범위 정의
bandpass_filter = fir1(filter_order, passband, 'bandpass');
% Original Signal에 BandPass FIR 필터 적용
band_signal = filter(bandpass_filter, 1, x);

% filtered_signal Spectogram 생성
[bandpass_filtered, band_freq, band_t] = specgram(band_signal, 1024, fs, hann(1024), 512);
[Low_filtered, Low_freq, Low_t] = specgram(Lowpass_signal, 1024, fs, hann(1024), 512);
[High_filtered, High_freq, High_t] = specgram(Highpass_signal, 1024, fs, hann(1024), 512);

% filtered_signal Spectogram
subplot(3,1,1);
imagesc(band_t, band_freq, 20*log10(abs(bandpass_filtered)));
axis xy;
title('bandass Filtered Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;
subplot(3,1,2);
imagesc(Low_t, Low_freq, 20*log10(abs(Low_filtered)));
axis xy;
title('Lowpass Filtered Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;
subplot(3,1,3);
imagesc(High_t, High_freq, 20*log10(abs(High_filtered)));
axis xy;
title('Highpass Filtered Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;

