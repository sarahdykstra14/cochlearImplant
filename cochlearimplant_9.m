% Matlab code for best filter design
[maleVoice] = cochlear_implant('Male-voice.wav');
[femaleVoice] = cochlear_implant('Female-voice.wav');
[male_voice_noisy] = cochlear_implant('Male-voice-very-noisy-background.wav');
[female_voice_noisy] = cochlear_implant('Female-voice-very-noise-background.wav');
[male_voice_reverb] = cochlear_implant('Male-voice-reverb.wav');
[female_voice_reverb] = cochlear_implant('Female-voice-reverb.wav');
[coversation] = cochlear_implant('Conversation.wav');
[conversation_noisy] = cochlear_implant('Conversation-noisy-background.wav');
[notes] = cochlear_implant('Chords-and-notes.wav');
[music] = cochlear_implant('Background-music.wav');

function final_sound = cochlear_implant(filename)
    n = 20; %number of channels
    [processed] = process(filename);
    [y, envelopes] = filters(processed, 16000, n);
    final_sound = coswave(filename, envelopes, y, 16000, n);
end

%Task 3
function processed = process(filename)
    [y, Fs] = audioread(filename);
    dimensions = size(y);
    newAudio = y(1:dimensions(1,1),1);
    if dimensions(1,2) > 1
        for i=1:dimensions(1,1)
            newAudio(i,1) = newAudio(i,1) + y(i,2);
        end
    end
    newAudio = newAudio/max(abs(newAudio)); %normalize audio signal
    audiowrite("C:\Users\Sarah Dykstra\Documents\2B\252\Project\processed-"+filename, newAudio, Fs); %replace directory with appropriate file location
    processed = resample(newAudio,16000,44100);
    %plot(processed);
end

%Task 4
function band = bp(sample, Fs, f_low, f_high)
    bp = designfilt('bandpassiir', 'FilterOrder', 60, 'StopbandFrequency1', ...
                f_low-20, 'StopbandFrequency2', f_high+20, ...
                'StopbandAttenuation', 40, 'SampleRate', Fs*1, ...
                'DesignMethod', 'cheby2'); %chebyshev bandpass with overlap, filter order 60
    band = filter(bp, sample);
end

%Task 7 and 8
function env = envelope(sample, Fs)
    rect = abs(sample);
    [b,a] = cheby2(11, 40, 600/Fs); %chebyshev lowpass with cutoff of 300 Hz
    env = filter(b, a, rect);
end

%Phase 2
function [y,envelopes] = filters(sample, Fs, n_channels)
    envelopes = zeros(n_channels, length(sample));
    y=linspace(100,7979,n_channels+1); %linear spacing
    for n = 1:n_channels
        bandpass = bp(sample, Fs, y(n), y(n+1));
        envelopes(n,:) = envelope(bandpass, Fs);
    end
end

function final_sound = coswave(filename, envelopes, y, Fs, n)
    signal_bands = zeros(n, length(envelopes(1,:)));
    for x = 1:n
        fc = sqrt(y(x)*y(x+1));
        t = (0:1/16000:length(envelopes(1,:))/16000);
        cosWave = cos(fc*pi*t);
        for r = 1:length(envelopes(x,:))
            signal_bands(x,r) = cosWave(r)*envelopes(x,r);
        end
    end
    cos_sound = sum(signal_bands,1);
    final_sound = cos_sound/max(abs(cos_sound));
    audiowrite("C:\Users\Sarah Dykstra\Documents\2B\252\Project\SoundFiles\9\final-"+filename, final_sound, Fs);
end