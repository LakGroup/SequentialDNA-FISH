function [lmx,lmy,mask,A_est,c_est] = find_localizations(img,sigma,alpha)
% Gaussian kernel
w = ceil(4*sigma);
x = -w:w;
g = exp(-x.^2/(2*sigma^2));
u = ones(1,length(x));

% convolutions
imgXT = padarrayXT(img, [w w], 'symmetric');
fg = conv2(g', g, imgXT, 'valid');
fu = conv2(u', u, imgXT, 'valid');
fu2 = conv2(u', u, imgXT.^2, 'valid');

% Laplacian of Gaussian
gx2 = g.*x.^2;
imgLoG = 2*fg/sigma^2 - (conv2(g, gx2, imgXT, 'valid')+conv2(gx2, g, imgXT, 'valid'))/sigma^4;
imgLoG = imgLoG / (2*pi*sigma^2);

% 2-D kernel
g = g'*g;
n = numel(g);
gsum = sum(g(:));
g2sum = sum(g(:).^2);

% solution to linear system
A_est = (fg - gsum*fu/n) / (g2sum - gsum^2/n);
c_est = (fu - A_est*gsum)/n;

%------------------------------------
%PRE-FILTER
J = [g(:) ones(n,1)]; % g_dA g_dc
C = inv(J'*J);

f_c = fu2 - 2*c_est.*fu + n*c_est.^2; % f-c
RSS = A_est.^2*g2sum - 2*A_est.*(fg - c_est*gsum) + f_c;
RSS(RSS<0) = 0; % negative numbers may result from machine epsilon/roundoff precision
sigma_e2 = RSS/(n-3);

sigma_A = sqrt(sigma_e2*C(1,1));

% standard deviation of residuals
sigma_res = sqrt(RSS/(n-1));

kLevel = norminv(1-alpha/2.0, 0, 1);

SE_sigma_c = sigma_res/sqrt(2*(n-1)) * kLevel;
df2 = (n-1) * (sigma_A.^2 + SE_sigma_c.^2).^2 ./ (sigma_A.^4 + SE_sigma_c.^4);
scomb = sqrt((sigma_A.^2 + SE_sigma_c.^2)/n);
T = (A_est - sigma_res*kLevel) ./ scomb;
pval = tcdf(-T, df2);

% mask of admissible positions for local maxima
mask = pval < 0.05;
%------------------------------------

% all local max
allMax = locmax2d(imgLoG, 2*ceil(sigma)+1);

% local maxima above threshold in image domain
imgLM = allMax .* mask;
[lmy, lmx] = find(imgLM~=0);   

% waitbar(0.5,f,'Localizing...Local Threshold')
% if sum(imgLM(:))~=0 % no local maxima found, likely a background image
%     % -> set threshold in LoG domain
%     logThreshold = min(imgLoG(imgLM~=0));
%     logMask = imgLoG >= logThreshold;
%     
%     % combine masks
%     mask = mask | logMask;
%     
%     % re-select local maxima
%     imgLM = allMax .* mask;   
%     waitbar(0.7,f,'Localizing...Finding Spots')
%     [lmy, lmx] = find(imgLM~=0);    
% end

% idx = false(length(lmx),1);
% for i = 1:length(lmx)
%     if img(lmy(i),lmx(i))>1000
%         idx(i) = true;
%     end
% end
% lmx = lmx(idx);
% lmy = lmy(idx);
end