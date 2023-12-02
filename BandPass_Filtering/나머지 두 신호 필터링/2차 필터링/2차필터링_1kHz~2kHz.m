clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('D:/test/lastFilter_Upward.wav');

% 타겟 시간 구간 설정 (0초에서 3초)
start_time = 0;
end_time = 3;

% 0.045초 간격으로 처리하기 위해 각 구간의 샘플 수 계산
window_size = 0.045 * fs;

% 타겟 시간 구간에 해당하는 샘플 추출
target_samples = x((start_time * fs) + 1 : end_time * fs);

% FFT 수행하여 각 구간의 주요 주파수 신호를 찾기
step = 0.045;  % 0.45초 간격
num_steps = floor((end_time - start_time) / step);

% 주파수 신호를 저장할 배열 초기화
freq_signals = zeros(1, num_steps);
time_values = zeros(1, num_steps);

% 주파수 추출 및 새로운 신호 생성을 위한 시간 범위 재설정
new_time = 0:1/fs:end_time-start_time-1/fs;
new_signal = zeros(1, length(new_time));

% FFT 및 주요 주파수 탐색
for i = 1:num_steps
    start_index = floor((i - 1) * window_size) + 1;
    end_index = start_index + window_size - 1;

    % 시간 및 주파수 벡터 생성
    t = (start_index:end_index) / fs;
    frequencies = (0:window_size-1)*(fs/window_size);

    % FFT 수행
    X = fft(target_samples(start_index:end_index));

    % 주요 주파수 신호 탐색
    [~, idx] = max(abs(X));
    freq_signals(i) = frequencies(idx);
    time_values(i) = t(1);  % 각 주파수 시간값 저장

    % 새로운 신호 생성
    new_signal(start_index:end_index) = cos(2 * pi * freq_signals(i) * t);
end

% 결과 음성 파일로 저장
output_file = 'D:/test/testing/Extracted_Frequency_Signal_1000to2000.wav';
audiowrite(output_file, new_signal, fs);
% 음성 파일 읽기
[x, fs] = audioread('D:/test/testing/Extracted_Frequency_Signal_1000to2000.wav');

% STFT를 사용하여 시간에 따른 주파수 성분 분석
window_size = 1024;
overlap = 512;
[S, f, t] = specgram(x, window_size, fs, hann(window_size), overlap);

% 0초부터 1초까지의 부분을 zeros로 설정
start_time = 0;
end_time = 1;
start_index = find(t >= start_time, 1);
end_index = find(t <= end_time, 1, 'last');
S(:, start_index:end_index) = 0;

% 스펙트로그램 시각화
figure;
imagesc(t, f, 10*log10(abs(S))); % dB 단위로 변환하여 이미지로 표시
axis xy;
title('LPF(1kHz to 2kHz) Spectrogram');
xlabel('Time [sec]');
ylabel('Frequency [Hz]');
colorbar;
