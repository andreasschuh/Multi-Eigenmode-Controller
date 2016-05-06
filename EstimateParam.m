% Estimate resonance frequency, phase, Q factor and gain of each resonance,
% based on data recorded of the system. Such data can be obtained by
% incorporating the recording device (e.g. FPGA) in a similar fashion as
% the closed loop system is set up afterwards. For example, amplifiers,
% vibrating system with sensors and actuators, sensor pre-amplifiers, etc.
% are within the recording loop. This guarantees the proper estimation of
% the parameters.
%
% Inputs:
%       - Recorddata: Sampling rate of the recording system
%
% Outputs:
%       - resonance1: First eigenmode's resonance
%       - resonance2: Second eigenmode's resonance
%       - phase1: First eigenmode's phase relative to exciting phase of f1
%       - phase2: Second eigenmode's phase relative to exciting phase of f2
%       - Q1: First eigenmode's Q factor
%       - Q2: Second eigenmode's Q factor
%       - gain1: First eigenmode's Amplitude (gain)
%       - gain2: Second eigenmode's Amplitude (gain)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [resonance1,resonance2,phase1,phase2,Q1,Q2,gain1,gain2] = EstimateParam(Recorddata)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find first resonance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Frequency and Q factor from freqency domain data
M1 = csvread('eigenmode1.csv', 2, 0);
F1=M1(:,1); %Frequency
A1=M1(:,2); %Amplitude
P1=M1(:,3); %Phase

[peak1,index1]=max(A1) % look for amplitude peak = resonance
resonance1=F1(index1) % Frequency at max(Amplitude)

%Search for half power value to determine Q factor
searchval1 = 0.70710678 * peak1; %value to find

lowerval1_vector = abs(A1(1:index1)-searchval1); 
[lowerval1 index_lowerval1] = min(lowerval1_vector); %index of closest value below resonance
lowerval1_closestF = F1(index_lowerval1); %closest value

upperval1_vector = abs(A1(index1+1:length(F1))-searchval1);
[upperval1 index_upperval1] = min(upperval1_vector); %index of closest value above resonance
upperval1_closestF = F1(index_upperval1+index1); %closest value

Q1 = resonance1 / (upperval1_closestF-lowerval1_closestF)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find second resonance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Frequency and Q factor from freqency domain data
M2 = csvread('eigenmode2.csv', 2, 0);
F2=M2(:,1); %Frequency
A2=M2(:,2); %Amplitude
P2=M2(:,3); %Phase

[peak2,index2]=max(A2) % look for amplitude peak = resonance
resonance2=F2(index2) % Frequency at max(Amplitude)

%Search for half power value to determine Q factor
searchval2 = 0.70710678 * peak2; %value to find
lowerval2_vector = abs(A2(1:index2)-searchval2);
[lowerval2 index_lowerval2] = min(lowerval2_vector); %index of closest value below resonance
lowerval2_closestF = F2(index_lowerval2); %closest value

upperval2_vector = abs(A2(index2+1:length(F2))-searchval2);
[upperval2 index_upperval2] = min(upperval2_vector); %index of closest value above resonance
upperval2_closestF = F2(index_upperval2+index2); %closest value

Q2 = resonance2 / (upperval2_closestF-lowerval2_closestF)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find the phase through a correlation between stimulation and response signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stimulation and response signal file of eigenmode 1 (time domain)
stimMode1 = csvread('scope_1_1.csv', 2, 1);
respMode1 = csvread('scope_1_2.csv', 2, 1);

% Stimulation and response signal file of eigenmode 2 (time domain)
stimMode2 = csvread('scope_2_1.csv', 2, 1);
respMode2 = csvread('scope_2_2.csv', 2, 1);

datalength = length(stimMode1);
t=[0:datalength]*Recorddata;

%Phase Eigenmode 1
t1=[-datalength:datalength]*Recorddata*2*pi*resonance1;
mode1=xcorr(stimMode1,respMode1);
[val1,index11]=max(mode1);
lag1=t1(index11);
phase1=lag1*180/pi;

%Phase Eigenmode 2
t2=[-datalength:datalength]*Recorddata*2*pi*resonance2;
mode2=xcorr(stimMode2,respMode2);
[val2,index22]=max(mode2);
lag2=t2(index22);
phase2=lag2*180/pi;

phase1=rem(phase1,360); 
phase2=rem(phase2,360);

% If phase is positive
if phase1>0
     phase1=phase1-360;
end
if phase2>0
     phase2=phase2-360;
end

stimucorr=xcorr(stimMode1,stimMode1);
Amplitude_high=max(stimucorr)*2/datalength; % because both amplitudes are now same , amplitude is square of one of them -> to other side of equation -> sqrt
Amplitude_min=min(stimucorr)*2/datalength;
Amplitude=((sqrt(abs(Amplitude_high))+sqrt(abs(Amplitude_min)))/2);
%Gain Eigenmode 1
val11=min(mode1);
ampl1=val1*2/datalength*1/Amplitude;
ampl11=val11*2/datalength*1/Amplitude;
gain1=((ampl1-ampl11)/2)/Amplitude;

stimucorr2=xcorr(stimMode2,stimMode2);
Amplitude_high2=max(stimucorr2)*2/datalength; % because both amplitudes are now same , amplitude is sqaure of one of them -> to other side of equation -> sqrt
Amplitude_min2=min(stimucorr2)*2/datalength;
Amplitude2=((sqrt(abs(Amplitude_high2))+sqrt(abs(Amplitude_min2)))/2);
%Gain Eigenmode 2
val22=min(mode2);
ampl2=val2*2/datalength*1/Amplitude2;
ampl22=val22*2/datalength*1/Amplitude2;
gain2=((ampl2-ampl22)/2)/Amplitude2;