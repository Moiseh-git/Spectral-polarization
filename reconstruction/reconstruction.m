function [Xrec] = reconstruction(J,mask,method)
if(method == 1)
    [Xrec] = ConvolutionFilterdemosaicking(J,mask); % Convolution Filter
elseif(method == 2)
    [Xrec] = IterativeIntensityDifference(J,mask);  % Iterative Intensity Difference
elseif(method == 3)
    [Xrec] = IntensityDifference(J,mask); % Intensity Difference
elseif(method == 4)
    [Xrec] = WeightedBillinearMethod(J); % Weighted Billinear Method
elseif(method == 0 || method == 5)
    [Xrec] = interpolation(J); % Scattered data interpolation methods
elseif(method == 6)
    [Xrec] = IterativeNearbyChannelDifference(J,mask); % Iterative Nearby Channel Difference(ItNCD)
elseif(method == 7)
    [Xrec] = SpectralDifference(J,mask); % Spectral Difference (SD)
elseif(method == 8)
    [Xrec] = IterativeSpectralDifference(J,mask); % Iterative Spectral Difference (ItSD)
elseif(method == 9)
    %[Xrec] = PseudoPanchromaticImageDifference(J,mask); % Iterative Spectral Difference (SD)
    I_MOS =sum(J,3);
    num_band = 16;
    [I_final]=run_PPID(I_MOS,FilterPattern,num_band,PPI);
    Xrec = I_final;
elseif(method == 10)
    %TRevSCI-net
end
end