clear;
% Check codes
% Transmittance
G = [];
load("mask_mosaico.mat")
sum(C(:))/numel(C)
C1 = C;

load("mask_spherepacking.mat")
sum(C(:))/numel(C)
C2 = C;

load("mask_random.mat")
sum(C(:))/numel(C)
C3 = C;

load("mask_sp_Nelson.mat")
sum(C(:))/numel(C)
C4 = C;

nameCodes = ["mosaic","sp-moises","random","SP-Nelson","3D-SP"];

m = 24;
[M,N,K,L] = size(C);
[a,b,ma,G5]=DDDRSNNPLattice(N,K*L);

c = 0;
[C5] = GenerateCode(G5);

sum(C5(:))/numel(C5)

figure(1)
colormap("gray")
subplot(2,5,1),imagesc(C1(1:m,1:m,1,1)),title(nameCodes(1)),pbaspect([1 1 1]),axis off;
subplot(2,5,2),imagesc(C2(1:m,1:m,1,1)),title(nameCodes(2)),pbaspect([1 1 1]),axis off;
subplot(2,5,3),imagesc(C3(1:m,1:m,1,1)),title(nameCodes(3)),pbaspect([1 1 1]),axis off;
subplot(2,5,4),imagesc(C4(1:m,1:m,1,1)),title(nameCodes(4)),pbaspect([1 1 1]),axis off;
subplot(2,5,5),imagesc(C5(1:m,1:m,1,1)),title(nameCodes(5)),pbaspect([1 1 1]),axis off;
hold on;

[G1] = GenerateMosaic(C1);
[G2] = GenerateMosaic(C2);
[G3] = GenerateMosaic(C3);
[G4] = GenerateMosaic(C4);

hold off;
subplot(2,5,6),imagesc(G1(1:m,1:m)),title(nameCodes(1)),pbaspect([1 1 1]),axis off;
subplot(2,5,7),imagesc(G2(1:m,1:m)),title(nameCodes(2)),pbaspect([1 1 1]),axis off;
subplot(2,5,8),imagesc(G3(1:m,1:m)),title(nameCodes(3)),pbaspect([1 1 1]),axis off;
subplot(2,5,9),imagesc(G4(1:m,1:m)),title(nameCodes(4)),pbaspect([1 1 1]),axis off;
subplot(2,5,10),imagesc(G5(1:m,1:m)),title(nameCodes(5)),pbaspect([1 1 1]),axis off;

G(:,:,1) = G1;
G(:,:,2) = G2;
G(:,:,3) = G3;
G(:,:,4) = G4;
G(:,:,5) = G5;

colormap("jet")

NF = K*L;

[density,diameter]= ComputeDensityGeneral(NF,G1(1:NF,1:NF)); % Mosaico
%diam()
%radius = diameter/2;
%fontsize = 14;
%figure(2)
%showSphereGeneral(G1(1:m,1:m),radius,fontsize);
[density,diameter]= ComputeDensityGeneral(NF,G2(1:NF,1:NF)); % SP Moises
[density,diameter]= ComputeDensityGeneral(NF,G3(1:NF,1:NF)); % Random
[density,diameter]= ComputeDensityGeneral(NF,G4(1:NF,1:NF)); % SP Nelson
[density,diameter]= ComputeDensityGeneral(NF,G5(1:NF,1:NF)); % 3D SP

figure4(G);

function [G] = GenerateMosaic(C)
[M,N,L,K] = size(C);
G = zeros(M, N); % Initialize G to accumulate results
c = 0;
for k=1:K
    for l=1:L
        c = c + 1;
        G = G + C(:,:,l,k).*c;
    end
end
end

function [C] = GenerateCode(G)
C =[];
K = 4;
L = 12;
c = 0;
for k=1:K
    for l=1:L
        c = c + 1;
        C(:,:,l,k) = G==c;
    end
end
end