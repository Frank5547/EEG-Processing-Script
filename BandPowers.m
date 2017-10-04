clear;
clc;

tbdata = importdata('Participant 2.csv'); %import data from testbench .csv file
eegdata = tbdata.data;
eegdata(:,8:19) = [];
eegdata(:,1:2) = [];
eegdata = eegdata';

eeglab %Prepare data in EEGLAB
EEG = pop_importdata('data',eegdata,'srate',128); %import data from MATLAB array
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','eegdata','gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_chanevent(EEG, 6,'edge','leading','edgelen',0);
EEG.chanlocs = readlocs('insightCED.ced', 'filetype','autodetect');

EEG = pop_reref(EEG);

EEG = pop_eegfilt(EEG, 1, 0, [], [0]); % highpass filtering at 1Hz
EEG = pop_eegfilt(EEG, 0, 20, [], [0]); % lowpass filtering at 20Hz

[EEG, V_Rejected_Sample_Range] = pop_rejcont(EEG, 'elecrange',[1:EEG.nbchan] ,'freqlimit',[4 40] ,'threshold',10,'epochlength',0.25,'contiguous',4,'addlength',0.25,'taper','hamming');

EEG = pop_rmbase(EEG); % Remove Baseline

%for your epoched data, channel 1
[spectra,freqs] = spectopo(EEG.data(1,:,:), 0, EEG.srate);
%delta=1-4, theta=4-8, alpha=8-13, beta=13-30, gamma=30-80
deltaIdx = find(freqs>1 & freqs<4);
thetaIdx = find(freqs>=4 & freqs<8);
alphaIdx = find(freqs>=8 & freqs<12);
betaIdx  = find(freqs>=12 & freqs<30);
gammaIdx = find(freqs>=30 & freqs<80);

 % compute absolute power
deltaPower = 10^(mean(spectra(deltaIdx))/10);
thetaPower = 10^(mean(spectra(thetaIdx))/10);
alphaPower = 10^(mean(spectra(alphaIdx))/10);
betaPower  = 10^(mean(spectra(betaIdx))/10);
gammaPower = 10^(mean(spectra(gammaIdx))/10);
TotPower = deltaPower + thetaPower + alphaPower + betaPower + gammaPower;

reTheta = thetaPower / TotPower;
reBeta = betaPower / TotPower;
reAlpha = alphaPower / TotPower;

TERatio = reBeta/(reAlpha + reTheta);
fprintf('The task engagement ratio is %.4f\n', TERatio)

