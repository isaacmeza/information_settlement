clear all
clc
warning('Off')

%Initial/structural parameters
global beta Z

%Total distribution
Z = xlsread('Z.xlsx');
%Linear Model
%    Intercept  sueldo  c_antiguedad ....
beta=[79.71004	-0.0015592	7.20004	-11.79303	12.30647	-0.0003065	-0.9779801	-0.353942	-34.83342	-52.79145	-41.31354	-23.56658	-20.72387	-5.195107	-37.42051]';

%Distribution of settlement for less than 1 year
X = xlsread('X.xlsx');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results

tic
[I1, xcut(1),ycut(1),l1,m(1,1) ] = optim2d_conv( X ,1, [0,0] );
time(1,1)=toc;

tic
[I2, xcut(2),ycut(2),l2,m(2,1) ] = optim2d_conv( X ,2, [0,0] );
time(2,1)=toc;

tic
[I3, xcut(3),ycut(3),l3,m(3,1) ] = optim2d_conv( X ,3, [0,0] );
time(3,1)=toc;

tic
[I4, xcut(4),ycut(4),l4,m(4,1) ] = optim2d_conv( X ,4, [0,0] );
time(4,1)=toc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Graph scatter plot with division and intervals in each region

for t=1:4    
    
    switch t
        case 1
            metric='Trace Var/Cov';
            I=round(I1,2);
        case 2
            metric='alphaShape';
            I=round(I2,2);
        case 3
            metric='ConvexHull';
            I=round(I3,2);
        otherwise
            metric='Optimum Interval';
            I=round(I4,2);
    end

    %Division into regions
    r1=X(X(:,1)>=xcut(t) & X(:,2)>=ycut(t),:);
    r2=X(X(:,1)>xcut(t) & X(:,2)<ycut(t),:);
    r3=X(X(:,1)<=xcut(t) & X(:,2)<=ycut(t),:);
    r4=X(X(:,1)<xcut(t) & X(:,2)>ycut(t),:);

    %Print figure
    close all
    fig=figure; 
    hax=axes; 
    hold on 
    plot(r1(:,1),r1(:,2),'*',r2(:,1),r2(:,2),'*',r3(:,1),r3(:,2),'*',r4(:,1),r4(:,2),'*','markers',5) 
    line([xcut(t) xcut(t)],get(hax,'YLim'),'Color',[1 0 0])
    line(get(hax,'XLim'),[ycut(t) ycut(t)],'Color',[1 0 0])
    xlabel('Wage (Pesos)')
    ylabel('Tenure (Years)')
    title(sprintf('Prediction intervals and division.  Metric : %s',metric))
    legend(sprintf('[ %.2f , %.2f ]', I(1,1), I(1,2)), sprintf('[ %.2f , %.2f ]', I(2,1), I(2,2)), sprintf('[ %.2f , %.2f ]', I(3,1), I(3,2)), sprintf('[ %.2f , %.2f ]', I(4,1), I(4,2)));
    hold off
    saveas(gcf,strcat('Interval_',sprintf('%i',t),'.png'));
    saveas(gcf,strcat('Interval_',sprintf('%i',t),'.pdf'));
end

close all
