function [p,s,r,sam] = metrics(data,Xrec,kdataset) %1 for cave dataset
[M,N,L] = size(Xrec);
p = zeros(L,1);
s = zeros(L,1);
rm = zeros(L,1);
for i=1:L
    if(kdataset==1 || kdataset==2)
        % ref = uint8(data((1+6):(N-6),(1+6):(N-6),i)*m);
        % A = uint8(Xrec((1+6):(N-6),(1+6):(N-6),i)*m);
        % elseif(kdataset==2)
        ref = data(:,:,i);
        A = Xrec(:,:,i);
    end
    p(i) = psnr(A,ref);
    s(i) = ssim(A,ref);
    v1 = double(A(:));
    v2 = double(ref(:));
    rm(i) = sqrt(immse(v1(:),v2(:)));
end

sa = zeros(M,N);
for n=1:N
    for m=1:M
        v1 = Xrec(m,n,:);
        v2 = data(m,n,:);
        v1 = double(v1(:));
        v2 = double(v2(:));
        sa(m,n) = real(SpectralAngleMapper(v1,v2+eps));
    end
end

p = mean(p); % psnr
s= mean(s); % ssim
r = mean(rm); % rmse
sam = mean(sa(:)); % sam Measure spectral similarity using spectral angle mapper
%disp("PSNR "+ num2str(p)+ " SSIM "+num2str(s)+" RMSE "+num2str(r)+" SAM "+num2str(sam));
%disp("---------------------------------------------------------------------------------------------------------")
end