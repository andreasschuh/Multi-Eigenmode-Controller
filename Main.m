%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main File, used for calculating the compensator coefficients
% Here, example for modifying 2 eigenmodes simultanously
%
% Created by Andreas Schuh 2013
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extract given resonace frequencies and Q factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Recorddata=0.02/100000; %Sampling rate in HZ of recording system for parameter estimation of current system
[resonance_frequency_mode1,resonance_frequency_mode2,phase_mode1,phase_mode2,q_factor_mode1,q_factor_mode2,gain_mode1,gain_mode2] = EstimateParam(OsziTs); %function call, see separate file

%%%%%%%%%%%%%%%%%%%
%Desired Parameters
%%%%%%%%%%%%%%%%%%%

%N0 change in resonance frequency
resonance_frequency_mode1_desired=resonance_frequency_mode1;
resonance_frequency_mode2_desired=resonance_frequency_mode2;

%Desired Q Factors
q_factor_desired_mode1=50;
q_factor_desired_mode2=100;

Ts=1/2777778; %Sampling Rate = Compensator Loop rate of FPGA

%Steady-State noise covariances 
Q=1;
R=10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Determine the correct transfer function of each eigenmodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%gain_mode1=peak_mode1/ex_mode1;
%gain_mode2=peak_mode2/ex_mode2;

damping_ratio_mode1=1/(2*q_factor_mode1);
damping_ratio_mode2=1/(2*q_factor_mode2);

damped_frequency_mode1=resonance_frequency_mode1*sqrt(1-damping_ratio_mode1^2)/sqrt(1-2*damping_ratio_mode1^2);
damped_frequency_mode2=resonance_frequency_mode2*sqrt(1-damping_ratio_mode2^2)/sqrt(1-2*damping_ratio_mode2^2);

damped_omega_mode1=damped_frequency_mode1*2*pi;
damped_omega_mode2=damped_frequency_mode2*2*pi;

natural_omega_mode1=damped_omega_mode1/sqrt(1-damping_ratio_mode1^2);
natural_omega_mode2=damped_omega_mode2/sqrt(1-damping_ratio_mode2^2);

Amplitude_mode1=gain_mode1/q_factor_mode1;   %Amplitude = M = G(jw)1/(2*dampingfactor*sqrt(1-dampingfactor^2))
Amplitude_mode2=gain_mode2/q_factor_mode2;

tf_mode1=tf([Amplitude_mode1*natural_omega_mode1^2],[1, 2*damping_ratio_mode1*natural_omega_mode1, natural_omega_mode1^2]);
tf_mode2=tf([Amplitude_mode2*natural_omega_mode2^2],[1, 2*damping_ratio_mode2*natural_omega_mode2, natural_omega_mode2^2]);
tf_mode=tf_mode1+tf_mode2; %Or possibly tf_mode=tf_mode1*tf_mode2;

%Build State Space System - or just add tfmode1 and tfmode2 and transfer to ss, discretize and into modal form
Hz=c2d(ss(tf_mode),Ts,'foh');

%phase and magnitude of system, but still uncorrect phase representation
datapoints=10000;
w=linspace(0,1000000,datapoints);
P = bodeoptions; % Set phase visiblity to off and frequency units to Hz in options
P.FreqUnits = 'Hz'; % Create plot with the options specified by P
[h_mag_actual,h_phs_actual] = bode(Hz,w*2*pi,P);
amplitude=h_mag_actual(:,:);
phase=h_phs_actual(:,:);

%Correct the phase of each eignemode of the system under control
phasechange=(resonance_frequency_mode1+resonance_frequency_mode2)/2; %a freqency between the two resonances
index = find(w>phasechange,1)
phase(1:index)=phase(1:index)+phase_mode1+90; %+90 since measurement is in resonance  
phase(index+1:datapoints)=phase(index+1:datapoints)+phase_mode2+90; %+90 since measurement is in resonance  

%Do a system identification for the newly composed system, so that phase is properly considerd
data = amplitude.*exp(1i*phase*pi/180);
system = idfrd(data,w*2*pi,Ts);
sys=pem(system,4,'DisturbanceModel','None','Focus','Sim'); %PEM Identification
[num,den]=tfdata(sys);
systemtf=tf(num,den,Ts);
Hz=d2d(ss(systemtf),Ts); 
Hz=balreal(Hz); %Balanced coefficients
Hz=canon(Hz,'modal'); %into modal form
[Ad,Bd,Cd,Dd] = ssdata(Hz); %Extract matrices
[h_mag_new,h_phs_new] = bode(Hz,w*2*pi,P);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check Observability
O_d = gram(Hz,'o');RO_d = rank(O_d);UOstates_d=length(Ad)-RO_d;
%Check Controllability
C_d = gram(Hz,'c');RC_d = rank(C_d);UCstates_d=length(Ad)-RC_d;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Determine the correct transfer function of DESIRED eigenmodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Define desired damping ratio and frequency
damping_ratio_desired_mode1=1/(2*q_factor_desired_mode1); 
damping_ratio_desired_mode2=1/(2*q_factor_desired_mode2);
natural_omega_mode1_desired=resonance_frequency_mode1_desired/sqrt(1-2*damping_ratio_desired_mode1^2)*2*pi;
natural_omega_mode2_desired=resonance_frequency_mode2_desired/sqrt(1-2*damping_ratio_desired_mode2^2)*2*pi;

%Calculate desired Controller Poles for Mode 1
[num_desired_mode1,den_desired_mode1]=ord2(natural_omega_mode1_desired,damping_ratio_desired_mode1);
mode1_tf_desired=tf(num_desired_mode1,den_desired_mode1);
ss_mode1_desired=ss(mode1_tf_desired);
ss_model_desired_d=c2d(ss_mode1_desired,Ts,'foh');
roots_desired_mode1_d=pole(ss_model_desired_d);
poles_desired_mode1_d=[roots_desired_mode1_d(1) roots_desired_mode1_d(2)];

%Calculate desired Controller Poles for Mode 2
[num_desired_mode2,den_desired_mode2]=ord2(natural_omega_mode2_desired,damping_ratio_desired_mode2);
mode2_tf_desired=tf(num_desired_mode2,den_desired_mode2);
ss_mode2_desired=ss(mode2_tf_desired);
ss_mode2_desired_d=c2d(ss_mode2_desired,Ts,'foh');
roots_desired_mode2_d=pole(ss_mode2_desired_d);
poles_desired_mode2_d=[roots_desired_mode2_d(1) roots_desired_mode2_d(2)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute Kalman compensator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Controller
poles_desired_d=[poles_desired_mode1_d poles_desired_mode2_d]; %Do button for choosing
K_acker=acker(Ad,Bd,poles_desired_d);
N_acker=1/dcgain(Hz);

%Estimator
[kalmf,L,P,M,Z]=kalman(Hz,Q,R);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Transform compensator coefficients into proper format (single precision
%floating point) for FPGA computations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a11_1 = typecast(single(Ad(1,1)), 'uint32' );
a11=dec2bin(a11_1,32);

a12_1 = typecast(single(Ad(1,2)), 'uint32' );
a12=dec2bin(a12_1,32);

a21_1 = typecast(single(Ad(2,1)), 'uint32' );
a21=dec2bin(a21_1,32);

a22_1 = typecast(single(Ad(2,2)), 'uint32' );
a22=dec2bin(a22_1,32);

a33_1 = typecast(single(Ad(3,3)), 'uint32' );
a33=dec2bin(a33_1,32);

a34_1 = typecast(single(Ad(3,4)), 'uint32' );
a34=dec2bin(a34_1,32);

a43_1 = typecast(single(Ad(4,3)), 'uint32' );
a43=dec2bin(a43_1,32);

a44_1 = typecast(single(Ad(4,4)), 'uint32' );
a44=dec2bin(a44_1,32);

b1_1 = typecast(single(Bd(1)), 'uint32' );
b1=dec2bin(b1_1,32);

b2_1 = typecast(single(Bd(2)), 'uint32' );
b2=dec2bin(b2_1,32);

b3_1 = typecast(single(Bd(3)), 'uint32' );
b3=dec2bin(b3_1,32);

b4_1 = typecast(single(Bd(4)), 'uint32' );
b4=dec2bin(b4_1,32);

c1_1 = typecast(single(Cd(1)), 'uint32' );
c1=dec2bin(c1_1,32);

c2_1 = typecast(single(Cd(2)), 'uint32' );
c2=dec2bin(c2_1,32);

c3_1 = typecast(single(Cd(3)), 'uint32' );
c3=dec2bin(c3_1,32);

c4_1 = typecast(single(Cd(4)), 'uint32' );
c4=dec2bin(c4_1,32);

k1_1 = typecast(single(K_acker(1)), 'uint32' );
k1=dec2bin(k1_1,32);

k2_1 = typecast(single(K_acker(2)), 'uint32' );
k2=dec2bin(k2_1,32);

k3_1 = typecast(single(K_acker(3)), 'uint32' );
k3=dec2bin(k3_1,32);

k4_1 = typecast(single(K_acker(4)), 'uint32' );
k4=dec2bin(k4_1,32);

l1_1 = typecast(single(M(1)), 'uint32' );
l1=dec2bin(l1_1,32);

l2_1 = typecast(single(M(2)), 'uint32' );
l2=dec2bin(l2_1,32);

l3_1 = typecast(single(M(3)), 'uint32' );
l3=dec2bin(l3_1,32);

l4_1 = typecast(single(M(4)), 'uint32' );
l4=dec2bin(l4_1,32);

%Put all in a textfile
a11t=strcat('constant a11 : std_logic_vector := "',a11,'";');
a12t=strcat('constant a12 : std_logic_vector := "',a12,'";');
a21t=strcat('constant a21 : std_logic_vector := "',a21,'";');
a22t=strcat('constant a22 : std_logic_vector := "',a22,'";');

a33t=strcat('constant a33 : std_logic_vector := "',a33,'";');
a34t=strcat('constant a34 : std_logic_vector := "',a34,'";');
a43t=strcat('constant a43 : std_logic_vector := "',a43,'";');
a44t=strcat('constant a44 : std_logic_vector := "',a44,'";');

b1t=strcat('constant b1 : std_logic_vector := "',b1,'";');
b2t=strcat('constant b2 : std_logic_vector := "',b2,'";');
b3t=strcat('constant b3 : std_logic_vector := "',b3,'";');
b4t=strcat('constant b4 : std_logic_vector := "',b4,'";');

c1t=strcat('constant c1 : std_logic_vector := "',c1,'";');
c2t=strcat('constant c2 : std_logic_vector := "',c2,'";');
c3t=strcat('constant c3 : std_logic_vector := "',c3,'";');
c4t=strcat('constant c4 : std_logic_vector := "',c4,'";');

k1t=strcat('constant k1 : std_logic_vector := "',k1,'";');
k2t=strcat('constant k2 : std_logic_vector := "',k2,'";');
k3t=strcat('constant k3 : std_logic_vector := "',k3,'";');
k4t=strcat('constant k4 : std_logic_vector := "',k4,'";');

l1t=strcat('constant l1 : std_logic_vector := "',l1,'";');
l2t=strcat('constant l2 : std_logic_vector := "',l2,'";');
l3t=strcat('constant l3 : std_logic_vector := "',l3,'";');
l4t=strcat('constant l4 : std_logic_vector := "',l4,'";');

fName = 'coefficients.txt';       
fid = fopen(fName,'w');           
if fid ~= -1
  fprintf(fid,'%s\r\n',a11t);
  fprintf(fid,'%s\r\n',a12t);
  fprintf(fid,'%s\r\n',a21t);
  fprintf(fid,'%s\r\n',a22t);
  fprintf(fid,'%s\r\n',a33t);
  fprintf(fid,'%s\r\n',a34t);
  fprintf(fid,'%s\r\n',a43t);
  fprintf(fid,'%s\r\n',a44t);
  fprintf(fid,'%s\r\n',b1t);
  fprintf(fid,'%s\r\n',b2t);
  fprintf(fid,'%s\r\n',b3t);
  fprintf(fid,'%s\r\n',b4t);
  fprintf(fid,'%s\r\n',c1t);
  fprintf(fid,'%s\r\n',c2t);
  fprintf(fid,'%s\r\n',c3t);
  fprintf(fid,'%s\r\n',c4t);
  fprintf(fid,'%s\r\n',k1t);
  fprintf(fid,'%s\r\n',k2t);
  fprintf(fid,'%s\r\n',k3t);
  fprintf(fid,'%s\r\n',k4t);
  fprintf(fid,'%s\r\n',l1t);
  fprintf(fid,'%s\r\n',l2t);
  fprintf(fid,'%s\r\n',l3t);
  fprintf(fid,'%s\r\n',l4t); 
  fclose(fid);                    
end