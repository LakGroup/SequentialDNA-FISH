function pstruct = fit_gaussian(img,lmx,lmy,mask,alpha,A_est,sigma,c_est)
mode = 'xyAc';

lmIdx = sub2ind(size(img), lmy, lmx);  

if ~isempty(lmIdx)
    % run localization on local maxima
    
    pstruct = fitGaussians2D(img, lmx, lmy, A_est(lmIdx), sigma*ones(1,length(lmIdx)),...
        c_est(lmIdx), mode, 'mask', mask, 'alpha', alpha,'ConfRadius', [], 'WindowSize', []);
    
    % remove NaN values
    idx = ~isnan([pstruct.x]);
    if sum(idx)~=0
        fnames = fieldnames(pstruct);
        for k = 1:length(fnames)
            pstruct.(fnames{k}) = pstruct.(fnames{k})(idx);
        end
        
        % significant amplitudes
        idx = [pstruct.hval_Ar] == 1;
        
        % eliminate duplicate positions (resulting from localization)
        
        pM = [pstruct.x' pstruct.y'];
        idxKD = KDTreeBallQuery(pM, pM, 0.25*ones(numel(pstruct.x),1));
        idxKD = idxKD(cellfun(@numel, idxKD)>1);
        for k = 1:length(idxKD)
            RSS = pstruct.RSS(idxKD{k});
            idx(idxKD{k}(RSS ~= min(RSS))) = 0;
        end       
        
        if sum(idx)>0
            fnames = fieldnames(pstruct);
            for k = 1:length(fnames)
                pstruct.(fnames{k}) = pstruct.(fnames{k})(idx);
            end
            pstruct.hval_Ar = logical(pstruct.hval_Ar);
            pstruct.hval_AD = logical(pstruct.hval_AD);
            pstruct.isPSF = ~pstruct.hval_AD;
            
        else
            pstruct = [];
        end
    else
        pstruct = [];
    end
end
% %signal to noise correction
% A = pstruct.A;
% c = pstruct.c;
% idx = (A+c)./c>=signal_to_noise;
% 
% pstruct.x = pstruct.x(idx);
% pstruct.y = pstruct.y(idx);
% pstruct.A = pstruct.A(idx);
% pstruct.s = pstruct.s(idx);
% pstruct.c = pstruct.c(idx);
% pstruct.x_pstd = pstruct.x_pstd(idx);
% pstruct.y_pstd = pstruct.y_pstd(idx);
% pstruct.A_pstd = pstruct.A_pstd(idx);
% pstruct.s_pstd = pstruct.s_pstd(idx);
% pstruct.c_pstd = pstruct.c_pstd(idx);
% pstruct.x_init = pstruct.x_init(idx);
% pstruct.y_init = pstruct.y_init(idx);
% pstruct.sigma_r = pstruct.sigma_r(idx);
% pstruct.SE_sigma_r = pstruct.SE_sigma_r(idx);
% pstruct.RSS = pstruct.RSS(idx);
% pstruct.pval_Ar = pstruct.pval_Ar(idx);
% pstruct.mask_Ar = pstruct.mask_Ar(idx);
% pstruct.hval_Ar = pstruct.hval_Ar(idx);
% pstruct.hval_AD = pstruct.hval_AD(idx);
% pstruct.isPSF = pstruct.isPSF(idx);

% CC = bwconncomp(mask);
% labels = labelmatrix(CC);
% loclabels = labels(sub2ind(size(img), pstruct.y_init, pstruct.x_init));
% idx = setdiff(1:CC.NumObjects, loclabels);
% CC.PixelIdxList(idx) = [];
% CC.NumObjects = length(CC.PixelIdxList);
% mask = labelmatrix(CC)~=0;
end
%x : estimated x-positions
%y : estimated y-positions
%A : estimated amplitudes
%s : estimated standard deviations of the PSF
%c : estimated background intensities

%x_pstd : standard deviations, estimated by error propagation y_pstd : "
%A_pstd : "
%s_pstd : "
%c_pstd : "
%sigma_r : standard deviation of the background (residual)
%SE_sigma_r : standard error of sigma_r
%pval_Ar : p-value of an amplitude vs. background noise test (p < 0.05 -> significant amplitude)