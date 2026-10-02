%% date personalizate
k=0.036;
k1=0.624;
k2=-0.015;
k3=-0.0006;
C=7.4;
k11=k2^2+4*(k-k3)*k1;
k12=8*(k-k3);
k13=2*(k-k3);
keta=8e-5; 
S=332.5;

%% functia procesului analitic 
h0=16.53;
kp=2*sqrt(h0)/C
Tp=2*S*sqrt(h0)/C
kf=2.2*92/22*kp*10/30
Hf=tf(kf, [Tp, 1])

%% identificare proces experimental - de la ua la ut - tr=808s (Tp=202)
kp=(6.68-5.5)/(6.1-5.6)
y63=(6.68-5.5)*0.63+5.5
Tp=202;
H=tf(kp, [Tp 1])

%% 112 tr dorit - de 7 ori mai mic
tr=600;
T0=600/4;
H0=tf(1, [T0 1])
kr=Tp/(kp*T0)
Ti=Tp
Hr=kr*tf([Ti 1], [Ti 0])

%% feedforward - debit de iesire
Kpy=(20-16.53)/(35.7-30.22); % de la pert la iesire
Tpy=202;
Kp=(20-16.53)/(6.1-5.6)
Kcomp=Kpy/Kp
%% cascada
% determinare Hf1
kf1=(35.7-30.22)/0.5
y63=(35.7-30.22)*0.63+30.22 %%33.67
Tf1=0.76;
Hf1=tf(kf1, [Tf1 1])
%% bucla interna - Pi - tr=1s 
T01=0.25;
Kr=Tf1/kf1/T01
Ti=Tf1
%% determinare Hf2
kf2=(23.25-16.53)/(35.7-30.22)*1/3
y63=(23.25-16.53)*0.63+16.53
Tf2=404;
Hf2=tf(kf2, [Tf2 1])
%% regulator extern - tr impus = 100 s(de 8 ori mai mic decat timpul initial: 808s)
tr=600; %impus
Tf2=404;
kf2=(23.25-16.53)/(35.7-30.22)*1/3
T02=tr/4;
kr=Tf2/kf2/T02
Ti=Tf2

