%%
clear;
clc;
close all;
%% Addpaths
addpath(genpath('./src'));
addpath(genpath('./lattices'));
%addpath(genpath('./Dataset/multispectral7_Small'));
addpath(genpath('./Video_4_Bands_16_Frame_32_G_8_TI_EQ'));
%addpath(genpath('./Video_7_Bands_16_Frame_32_G_8_TI_EQ'));
addpath(genpath('./recover'));
addpath(genpath('./reconstruction'));
addpath(genpath('./RGB'));
addpath(genpath('./utils'));
addpath(genpath('./Metrics'));
addpath(genpath('./codes'));
addpath(genpath('./polarization=4-bands=12/Simeng_lock'));
%addpath(genpath('./polarization=4-bands=12/Simeng_ball'))
%addpath(genpath('./polarization=4-bands=12/Simeng_fruit'))


%% Data Inicialization
%M = 1200;
%N = 1920;

%% Initialization
NS = 12; % Number of bands
NF = 4; % Number of polarization angles
realData = 1;
%M = 4*256; % x dimension
%N = 4*256; % y dimension
[M,N,~]= sizeSpectralCube();
J = zeros(M,N,NS);
T = zeros(M,N,NS,NF); % coded aperture
C5 = zeros(M,N,NS,NF); % coded aperture
T2 = zeros(M,N,NS);

RGB_frame = zeros(M,N,3,NF); % RGB reconstruction
Xrec = zeros(M,N,NS,NF); % Video-spectral recuperado
idx = 0;
idy = 0;
p = zeros(NF,1); % PSNR of each frame
ss = zeros(NF,1); % SSIM of each frame
sam = zeros(NF,1); % SAM of each metric
angles = ["0","45","90","135"];

% Compute 3D sphere packing
N1 = max([M,N]);
[a,b,ma,G]=DDDRSNNPLattice(N1,NF);
[a1,b1,ma1,G1]=DDDRSNNPLattice(N1,NS);
G = G(1:M,1:N);
d = ma;
G2(:,:,1) = G;
G5(:,:,1) = G1;
for t=1:NF-1
    G2(:,:,t+1) = mod(G2(:,:,t)+round(d),NF)+1;
end

for t=1:NS-1
    G5(:,:,t+1) = mod(G5(:,:,t)+round(d),NS)+1;
end
%G3 = G2;

ptrn = [1 2;2 3];
%ptrn = [1 3 2;2 1 3;3 2 1];
[m1,n1] = size(ptrn);

%mosaicRGB = kron(ones(ceil(M/m1),ceil(N/n1)),ptrn);
mosaicRGB = G5(:,:,4);
id = 1:NS;

for t=1:NF
    tp = G==t;
    for m=1:M
        idy = m;
        for n=1:N
            if(tp(m,n)==1)
                idx = idx +1;
                T2(m,n,t) = mosaicRGB(idy,idx);
            end
        end
        idx = 0;
    end
end

for t = 1:NF
    temp1 = T2(:,:,t);
    for s=1:NS
        temp = id(s).*ones(M,N);
        T(:,:,s,t) = (temp1==temp);
    end
end
%load("mask_mosaico.mat")
%load("mask_spherepacking.mat")
 %load("mask_random.mat")
%T = C;

[a,b,ma,G5]=DDDRSNNPLattice(N,NF*NS);
c = 0;
for k=1:NF
    for l=1:NS
        c = c + 1;
        C5(:,:,l,k) = G5==c;
    end
end
T = C5;
T2 = [];
G3 = zeros(M,N,NF);

for t=1:NF
    tempora = zeros(M,N);
    for s = 1:NS
        tempora = tempora + T(:,:,s,t)*s;
    end
    G3(:,:,t) = tempora;
end
G4 = sum(G3,3);

%% Generate 4D-sphere packing coded aperture
%[T,G3] = generate4DSP(N,NF,NS);

%% Sampling Spectral-video
[Y] = sampling(T,realData);
imagesc(Y),colormap('gray'),pbaspect([1 1 1]);
imwrite(Y,"measurement.png");

method = 5;
%[Xrec1] = reconstruction(J,G,method);
%implay(Xrec1/max(Xrec1(:)));

for t=1:NF
    disp("Frame "+num2str(t))
    for s=1:NS
        %J(:,:,s)= Xrec1(:,:,t).*(T(:,:,s,1));
        J(:,:,s)= Y.*(T(:,:,s,t));
    end
    
    NameDataset = "frame_"+num2str(angles(t))+".mat";
    load(NameDataset);

    X = imresize(cube,[M,N]);
    D = size(X,3);
    idx  = round(linspace(1,D,NS));
    X = X(:,:,idx);

    method = 5;
    J = mat2gray(J).*255;
    %% Recovery spectral for each frame
    [Xrec(:,:,:,t)] = reconstruction(J,G4,method); % Xrec: spectral-video reconstruction
    Xrec(:,:,:,t) = mat2gray(abs(Xrec(:,:,:,t)))*255;
    RGB_frame(:,:,:,t)= RGB_test(Xrec(:,:,:,t));
    [RGB_X(:,:,:,t)] = RGB_test((X));

    kdataset = 1;
    X = mat2gray(X);
    Xrec1 = mat2gray(Xrec(:,:,:,t));
    [p(t),ss(t),r,sam(t)] = metrics(X(:,:,:),Xrec1(:,:,:),kdataset);
    Gt = RGB_X(:,:,:,t);
    Recon = RGB_frame(:,:,:,t);
    imwrite(Gt,"Gt_RGB_frame"+num2str(t)+".png");
    imwrite(Recon,"Recon_RGB_frame"+num2str(t)+".png");

end
%subplot(1,3,1),imagesc(Y),colormap('gray'),title("Measurement "),pbaspect([1 1 1]),axis off;
%subplot(1,3,2),imagesc(RGB_frame(:,:,:,t)),title("Reconstruction "+"frame= "+num2str(t)),pbaspect([1 1 1]),axis off;
%subplot(1,3,3),imagesc(RGB_X(:,:,:,t)),title("Groundtruth "+"frame= "+num2str(t)),pbaspect([1 1 1]),axis off;
%pause(0.1)


disp("Totals")
disp("PSNR "+ num2str(mean(p))+ " SSIM "+num2str(mean(ss))+" SAM "+num2str(mean(sam)));
disp("---------------------------------------------------------------------------------------------------------")
implay(RGB_frame(:,:,:,:)./max(RGB_frame(:)))
