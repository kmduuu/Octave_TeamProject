clc; clear;
pkg load signal;

% 음성 파일 읽기
[x, fs] = audioread('C:\test/Received_Signal.wav');

indices_noise = 1:fs;

N = mean(abs(x(indices_noise)).^2)

indices_sig = (fs+1):3*fs;

P_total = mean(abs(x(indices_sig)).^2)

X = fftshift(fft(x));
freq = -fs/2 : 1/(length(x)/fs) : fs/2 - 1/(length(x)/fs);

figure;plot(freq , 20*log10(abs(X)))

tapsize =10000


bpf = fir1(tapsize, [2800 3200]/(fs/2), 'bandpass');

tone_tmp = conv(bpf, x);
tone = tone_tmp(floor(length(bpf)/2)+(1:length(x)));

N_bpf = mean(abs(tone(indices_noise)).^2);
S_bpf = mean(abs(tone(indices_sig)).^2) - N_bpf;

SNR_3k = S_bpf/N

SNR_3k_dB = 10*log10(SNR_3k)

hpf = fir1(tapsize, 3200/(fs/2), 'high');

figure;plot(hpf)

highfreq_tmp = conv(hpf, x);
highfreq = highfreq_tmp(floor(length(hpf)/2)+(1:length(x)));

HH = fftshift(fft(highfreq));
figure;plot(freq , 20*log10(abs(HH)))

N_hpf = mean(abs(highfreq(indices_noise)).^2);
S_hpf = mean(abs(highfreq(indices_sig)).^2) - N_hpf;

SNR_above_3k = S_hpf/N

SNR_above_3k_dB = 10*log10(SNR_above_3k)

lpf = fir1(tapsize, 2500/(fs/2), 'low');

lowfreq_tmp = conv(lpf, x);
lowfreq = lowfreq_tmp(floor(length(lpf)/2)+(1:length(x)));

LL = fftshift(fft(lowfreq));
figure;plot(freq , 20*log10(abs(LL)))

N_lpf = mean(abs(lowfreq(indices_noise)).^2);
S_lpf = mean(abs(lowfreq(indices_sig)).^2) - N_lpf;

SNR_below_3k = S_lpf/N

SNR_below_3k_dB = 10*log10(SNR_below_3k)

P_total/N

SNR_below_3k + SNR_above_3k+ SNR_3k +1

totalDB = 10*log10(P_total/N);
