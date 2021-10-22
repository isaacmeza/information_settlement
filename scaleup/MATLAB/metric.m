function [ d, x ] = metric( r,type )
%Function calculates a metric function to measure the dispersion of the
%points in a bounded region of the plane
%
%Input:
%r : Set of points in R2
%type : type of metric to use
%
%   1: Sum of eigenvalues of variance-covariance matrix 
%   2: Area of alphaShape  
%   3: Area of convex hull
%   4: Minimum length of 'final' interval (acumulating 51% of predicted
%   values according to an exogenous specified model)
%
%Output:
%d : metric
%x :  In case type=4 is selected, x=(x(1),x(2)) is the minimum length
%interval
%
%

x=[];
global beta Y

switch type
    case 1
        d = trace(cov(r(:,1:2)));
    case 2
        d = area(alphaShape(r(:,1),r(:,2)));
    case 3
        d = area(alphaShape(r(:,1),r(:,2),Inf));
    case 4
        %Predicted values according to exogenous specified linear model
        Y=beta(1)+r*beta(2:end);

        %Solves the following problem
%           min (prctile(Y,x(2))-prctile(Y,x(1)))^2 
%               s.t. 
%           x(2)-x(1)>=51
        
        A=[1,-1; 0 0];
        b=[-51;0];
        lb = [0,0];
        ub=[100,100];
        x0=[24, 76];
        options = optimoptions('fmincon','Algorithm','sqp');
        [x,d] = fmincon('interval',x0,A,b,[],[],lb,ub,[],options);
        %Returns interval
        x=prctile(Y,x);      
    otherwise
        warning('Type of metric should be 1, 2, 3 or 4')
end

end

