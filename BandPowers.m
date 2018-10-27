% MATH 4080 Project 1: Music Classifciation of EEG signals_TE Ratio Calculation
% Francisco Javier Carrera Arias
% 08/25/2017 V3.3

clear;
clc;

tableData = importdata('P4_Positive.csv'); %import data from Emotiv Pro .csv file
eegdata = tableData.data;
eegdata(:,8:19) = []; 
eegdata(:,1:2) = []; % Extract the EEG channel data
eegdata = eegdata';

eeglab %Prepare data in EEGLAB
EEG = pop_importdata('data',eegdata,'srate',128); %import data from MATLAB array
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','eegdata','gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_chanevent(EEG, 6,'edge','leading','edgelen',0);

EEG.chanlocs = readlocs('insightCED.ced', 'filetype','autodetect'); % Read channel locations from .ced file
EEG = pop_reref(EEG); % Reference data to average

pop_eegplot(EEG) % Visual Inspection of continuous EEG data to remove noisy data and strange events.
pause()

% Artifact rejection with ICA
EEG = pop_runica(EEG); 
EEG = pop_selectcomps(EEG); 
pause() 
EEG = pop_subcomp(EEG); 

pop_spectopo(EEG) % Plot Spectral Map 
pause() % pause program to allow spectral map visualization

% Band Power Arrays
betaPow = [];
alphaPow = [];
thetaPow = [];
for i = 1:5 % Compute band powers for each EEG channel in EMOTIV Insight
  [spectra,freqs] = spectopo(EEG.data(i,:,:), 0, EEG.srate, 'plot', 'off');

  % theta=4-8, alpha=8-12, beta=12-30
  thetaFreq = find(freqs>=4 & freqs<=8);
  alphaFreq = find(freqs>=8 & freqs<=12);
  betaFreq  = find(freqs>=12 & freqs<=30);

  % compute absolute spectral power
  thetaPow = [thetaPow, mean(10.^(spectra(thetaFreq))/10)];
  alphaPow = [alphaPow, mean(10.^(spectra(alphaFreq))/10)];
  betaPow = [betaPow, mean(10.^(spectra(betaFreq))/10)];
end
