function [M,N,L] = sizeSpectralCube()
% r1 = 109;
% r2 = 1040;
% c1 = 135;
% c2 = 1060;
t = 1;
% angles = ["0","45","90","135"];
angles = ["Horizontal","Vertical","Diagonal_Pos","Diagonal_Neg","Circular_Der","Circular_Izq"];
NameDataset = "frame_"+num2str(angles(t))+".mat";
load(NameDataset);
[M,N,L]= size(cube(:,:,:));
end
