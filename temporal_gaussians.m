  %depends on temporal_representation.m   Plots temporal activation
  %profiles and visualizes the changes in mean and variance for TRU units
  

%Set up some color properties for plotting lines
  cmaps=[0 0 0;
    0 .25 0;
    0 .5 0;
    0 .75 0;
    0 1 0;
    .1 1 .1];
    cred=0:(.7/5):.7;
    cgr=fliplr(0:.6/5:.6);
    cbl=ones(1,6).*.25;
    cbl=0:.75/2:.75;cbl=[cbl fliplr(cbl)];
    cmaps=[cred' cgr',cbl'];


  bmaps=[1 0 0;
    1 .25 0;
    1 .5 0;
    1 .75 0;
    1 1 0;
    1 1 .5];


%Do some data processing to get temporal profiles
    time_mat=[];
    beg_mat=[];
x=0:.1:800;
for i=1:length(initPos);
    thispos=initPos(i);
    thissig=initSigs(i);
    curract=(1./1).*exp(-(thispos-x).^2./(2.*thissig.^3));
    time_mat=[time_mat;curract];
    
    thispos=begPos(i);
    thissig=begSigs(i);
    curract=(1./1).*exp(-(thispos-x).^2./(2.*thissig.^3));
    beg_mat=[beg_mat;curract];

end

close all

%PLOT TEMPORAL PROFILE OF TRUs
 plot(time_mat(2,51:8000), 'LineWidth', 4, 'Color', cmaps(1,:));
 hold on
 plot(time_mat(3,51:8000), 'LineWidth', 4, 'Color', cmaps(3,:));
 plot(time_mat(4,51:8000), 'LineWidth', 4, 'Color', cmaps(4,:));
  plot(time_mat(5,51:8000), 'LineWidth', 4, 'Color', cmaps(6,:));

 set(gcf, 'Color', 'white')
 xticks([])
 ylabel('Activity')
 title('Temporal Profiles')
 set(gca, 'FontSize', 24, 'FontWeight', 'bold')
  box off
 
 
 figure



%PLOT INITIAL and CURRENT TRU CENTERS
 subplot(1,2,1)
 plot(initPos-begPos,'Color',[0 .0 0],'LineWidth', 2)
  hold on
 scatter( 1:length(initPos)-3,initPos(1:end-3)-begPos(1:end-3), 'MarkerFaceColor',[0 .0 0], 'MarkerEdgeColor',[0 .5 0])
 plot(zeros(1,length(initPos)-3), 'Color',[.7 .7 0.7], 'LineWidth', 2, 'LineStyle', '-')
 scatter( 1:length(initPos)-3,zeros(1,length(initPos)-3), 'MarkerFaceColor',[0 0 0], 'MarkerEdgeColor',[0 0 0])

ylim([-40 20])
xlim([1 length(initPos(1:end-3))])
box off
set(gca, 'FontSize', 18, 'FontWeight', 'bold')
xticks([])
 ylabel('Delta Position')
 xlabel('TRU #')
hold off



%PLOT INITIAL and CURRENT TRU VARIANCE
 subplot(1,2,2)
plot(ones(length(initPos)).*begSigs(1), 'Color',[.7 .7 0.7], 'LineWidth', 2);%, 'LineStyle', '-')

 hold on
 plot(initSigs(1:end-3),'Color',[0 .0 0],'LineWidth', 3)
% legend({'Initial Value','FinalValue'})
  scatter( 1:length(initPos)-3,initSigs(1:end-3), 'MarkerFaceColor',[0 .0 0], 'MarkerEdgeColor',[0 .0 0])
scatter( 1:length(initPos)-3,zeros(1,length(initPos)-3)+begSigs(1), 'MarkerFaceColor',[0 0 0], 'MarkerEdgeColor',[0 0 0])

ylim([0 40])
xlim([1 length(initPos(1:end-3))])
box off
set(gca, 'FontSize', 18, 'FontWeight', 'bold')
xticks([])
 ylabel('Delta Variance')
 xlabel('TRU #')
hold off

set(gcf, 'Color','white', 'Position', [250 250 1000 300])
