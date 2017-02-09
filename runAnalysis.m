%% Load data
glidingdata = importfile('DatasetGliding.csv');

%% Reference data (Bird reference dimensions)
WingSpan_Reference = 0.67;%[m]
WingArea_Reference = 0.0652;%[m2]
BodyArea_Reference = 0.0129*(.215)^(.614);% .215 being the mean body mass

%% Add variables to gliding data 
glidingdata.SpanEfficiency_ShapeSpec = 1./(glidingdata.SpanRatio.^2./glidingdata.SpanEfficiency ...
    + sigma_fit_(glidingdata.WingSpan,glidingdata.Height) ... % wall correction
    );

glidingdata.TailGap = glidingdata.TailHeight./WingSpan_Reference;

glidingdata.TailSpanRatio = glidingdata.TailSpan./WingSpan_Reference;

%% Posture correlations
mdl_SpanEfficiencyShapeSpec = fitlm(glidingdata, ...
    'SpanEfficiency_ShapeSpec ~ SpanCamber + PrimSep8 + TailGap + TailSpanRatio')


%% predict span efficiency for main wing only
notaildata = table(...
    glidingdata.SpanEfficiency_ShapeSpec, ...
    glidingdata.SpanCamber, ...
    glidingdata.PrimSep8, ...
    0*glidingdata.TailGap, ...% remove tail gap
    min(glidingdata.TailSpanRatio)*glidingdata.TailSpanRatio ,... % minimum tail span
    'VariableNames',{'SpanEfficiency','SpanCamber','PrimSep8','TailGap','TailSpanRatio'});

ypred = predict(mdl_SpanEfficiencyShapeSpec,notaildata);

scatter(glidingdata.AirSpeed,ypred,'o')

%% Range of span efficiencies
fprintf('\nRange of predicted main-wing span efficiencies:\n')
fprintf('Minimum span efficiency: %.3f\n', min(ypred))
fprintf('Minimum span efficiency: %.3f\n', max(ypred))

%% statistics by WT angle and speed
grouptable = table(ypred,glidingdata.AirSpeed,round(10*glidingdata.GlideAngle)*100+floor(glidingdata.AirSpeed),...
    'VariableNames',{'predSpanEfficiency','AirSpeed','grp'});

ypred_grp = grpstats(grouptable,'grp',{'mean','sem','min','max'});

errorbar(ypred_grp.mean_AirSpeed,ypred_grp.mean_predSpanEfficiency,ypred_grp.sem_predSpanEfficiency)
