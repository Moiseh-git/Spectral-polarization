%%
clear;
clc;
close all;
%% Addpaths
addpath(genpath('./src'));
addpath(genpath('./reconstruction'));
addpath(genpath('./RGB'));
addpath(genpath('./Metrics'));
addpath(genpath('./codes'));

%% Configuración de dataset
datasetName = 'Hoja_seca_plana';
inputDir = fullfile('./datos_entrada', datasetName);
outputDir = fullfile('./resultados', datasetName);

addpath(genpath(inputDir));
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% Initialization
NS = 12;
NF = 6;
realData = 1;
[M,N,~]= sizeSpectralCube();
J = zeros(M,N,NS);
C5 = zeros(M,N,NS,NF);
RGB_frame = zeros(M,N,3,NF);
Xrec = zeros(M,N,NS,NF);
idx = 0;
idy = 0;
p = zeros(NF,1);
ss = zeros(NF,1);
sam = zeros(NF,1);
angles = ["Horizontal","Vertical","Diagonal_Pos","Diagonal_Neg","Circular_Der","Circular_Izq"];
method = 5;
N1 = max([M,N]);
id = 1:NS;

[a,b,ma,G]=DDDRSNNPLattice(N,NF*NS);
c = 0;
for k=1:NF
    for l=1:NS
        c = c + 1;
        T(:,:,l,k) = G==c;
    end
end
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

%% Sampling Spectral-video
[Y] = sampling(T,realData);
imagesc(Y),colormap('gray'),pbaspect([1 1 1]);
imwrite(Y, fullfile(outputDir, "measurement.png"));

for t=1:NF
    disp("Frame "+num2str(t))
    for s=1:NS
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
    [Xrec(:,:,:,t)] = reconstruction(J,G4,method);
    Xrec(:,:,:,t) = mat2gray(abs(Xrec(:,:,:,t)))*255;
    RGB_frame(:,:,:,t)= RGB_test(Xrec(:,:,:,t));
    [RGB_X(:,:,:,t)] = RGB_test((X));
    kdataset = 1;
    X = mat2gray(X);
    Xrec1 = mat2gray(Xrec(:,:,:,t));
    [p(t),ss(t),r,sam(t)] = metrics(X(:,:,:),Xrec1(:,:,:),kdataset);
    Gt = RGB_X(:,:,:,t);
    Recon = RGB_frame(:,:,:,t);
    imwrite(Gt, fullfile(outputDir, "Gt_RGB_frame"+num2str(t)+".png"));
    imwrite(Recon, fullfile(outputDir, "Recon_RGB_frame"+num2str(t)+".png"));
end

disp("Totals")
disp("PSNR "+ num2str(mean(p))+ " SSIM "+num2str(mean(ss))+" SAM "+num2str(mean(sam)));
disp("---------------------------------------------------------------------------------------------------------")
implay(RGB_frame(:,:,:,:)./max(RGB_frame(:)))