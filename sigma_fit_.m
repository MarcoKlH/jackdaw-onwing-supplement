function Y = sigma_fit_(Wingspan,Height)
% Wingspan is in-flight wingspan
% Height is height above wind tunnel centre
load WallCorrection_sigma_fit.mat

beta = Wingspan/1.2;
xi = Height/1.1;
Y = nan(size(beta));
slc = ~(isnan(beta)|isnan(xi)|isinf(beta)|isinf(xi));
Y(slc) = sigma_fit(beta(slc),xi(slc));