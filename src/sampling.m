function [Y] = sampling(T,realData)
%T = T(1:256,1:256,31,4);
[M,N,NS,NF] = size(T);


% r1 = 109;
% r2 = 1040;
% c1 = 135;
% c2 = 1060;

angles = ["0","45","90","135"];

for t=1:NF
    if(realData == 1)
        NameDataset = "frame_"+num2str(angles(t))+".mat";
        load(NameDataset);
        spectral_frame_c = cube(:,:,:);
        B = size(spectral_frame_c,3);
        spectral_frame_c = mat2gray(spectral_frame_c);
        id = round(linspace(1,B,NS));
        for s = 1:NS
            X(:,:,s) = imresize(spectral_frame_c(:,:,id(s)),[M,N],'nearest');
        end
    else


        load('C:\Users\NELSO\Downloads\SpherePackingLattice-main\SpherePackingLattice-main\data\egyptian_statue_ms.mat');
        pic = double(pic);
        pic(pic<0)=0;
        X = mat2gray(pic)*255;
    end
    for s=1:NS
        Ys(:,:,s) = X(:,:,s).*T(:,:,s,t);
    end
    Yt(:,:,t) = sum(Ys,3);
end


Y = sum(Yt,3);
end
