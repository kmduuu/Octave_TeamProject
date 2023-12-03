clc; clear;
pkg load signal;

% 시간 범위 설정
fs = 20000; % 샘플링 주파수
t = 0:1/fs:3; % 3초 동안의 시간 범위

% 주파수 성분 생성
value_Bpf = cos(6000 * pi * t);
value_Lpf = cos(2000 * pi * t + 500 * pi * t.^2);
value_Hpf = cos(10000 * pi * t - 395 * pi * t.^2);

% 0초에서 1초까지의 부분을 서서히 감소시켜 0으로 만듦
fade_out_start = find(t >= 0, 1);
fade_out_end = find(t <= 1, 1, 'last');
value_Bpf(fade_out_start:fade_out_end) = 0;
value_Lpf(fade_out_start:fade_out_end) = 0;
value_Hpf(fade_out_start:fade_out_end) = 0;

% 전체 신호 생성
combined_signal = value_Bpf + value_Lpf + value_Hpf;

% 스펙트로그램 생성
[S_combined, freqs_combined, times_combined] = specgram(combined_signal, 1024, fs, hann(1024), 512);

% 스펙트로그램 플로팅
figure;
imagesc(times_combined, freqs_combined, 10 * log10(abs(S_combined)));
axis xy;
title('Combined Signal Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;


