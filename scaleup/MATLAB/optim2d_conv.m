function [I,xcut,ycut,l,m ] = optim2d_conv ( X ,type,threshold )
%Suppose we have n points in a bounded region of the plane.  
%The problem is is to divide it in 4 regions (with a horizontal and a
%vertical line) such that the sum of a metric in each region is minimized.
%
%
%This algorithm is a greedy algorithm with a 'homotopy continuation'-type 
%spirit, in the sense that it subdivides the problem in two one-dimensional
%problems, but taking into account the 4 regions (so it differs 
%substantially from the projections into the one-dimensional case. 
%In odd iterations it looks for the optimal xcut starting with the optimal
%ycut found in the previous iteration (that's why it has a homotopy-like
%spirit).
%
%It is relatively easy to prove convergence of this method, with optimal
%'global' solutions.
%
%Input:
%X : A matriz whose first two columns represents points in the plane.
%type : type of metric to use
%
%   1: Sum of eigenvalues of variance-covariance matrix 
%   2: Area of alphaShape  
%   3: Area of convex hull
%   4: Minimum length of 'final' interval (acumulating 51% of predicted
%   values according to an exogenous specified model)
%threshold : Value of the step size increase in the search for the cuts (x
%and y dimension) to improve speed computation.
%
%Output:
%I : 4 x 2 matrix, storing in each row the 'best' interval (in the sense 
%   of minimum distance) that encloses (at least) 51% of the observations 
%   of the points falling in each of the 4 regions.
%xcut : Cut in x-axis 
%ycut : Cut in y-axis
%l : vector containing the length of each interval from I
%m : minimum value of the global objective function
%

global Z

%Initialization
maxiter=floor(length(X)/10);

if maxiter>100
    maxiter=100;
end

m=Inf; tol=Inf; iter=1; ycut=mean(X(:,2)); ind=2;

%Sorts the points in the x and y dimensions, in order to look in those
%directions
S=sort(X(:,1:2));
%We trimm to make step sizes af length at least the threshold
qx=diff(S(:,1))>threshold(1,1); qy=diff(S(:,2))>threshold(1,2);
Sx=S(qx,1);  Sy=S(qy,2);


while (tol>1e-07 && iter<maxiter )
    
    %Previous value of optimal weighted sum of metrics
    m0=m;
    

    %In odd iterations it looks for optimal xcut
    if mod(iter,2)==1    
        n=length(Sx);
    else
    	n=length(Sy);
    end

    for i=1:n

        %In odd iterations it looks for optimal xcut
        if mod(iter,2)==1    
            xcut=Sx(i);
        else
            ycut=Sy(i);
        end



        %Division into 4 regions according to the x=S(i,1) and y=S(j,2) cuts
        %r1 is the region corresponding to the first cuadrant and going
        %clockwise
        r1=X(X(:,1)>=xcut & X(:,2)>=ycut,:);
        r2=X(X(:,1)>xcut & X(:,2)<ycut,:);
        r3=X(X(:,1)<=xcut & X(:,2)<=ycut,:);
        r4=X(X(:,1)<xcut & X(:,2)>ycut,:);

        %Computation of weights according to exogenous distribution Z which
        %contains X.
        w1=Z(Z(:,1)>=xcut & Z(:,2)>=ycut,:);
        w2=Z(Z(:,1)>xcut & Z(:,2)<ycut,:);
        w3=Z(Z(:,1)<=xcut & Z(:,2)<=ycut,:);
        w4=Z(Z(:,1)<xcut & Z(:,2)>ycut,:);

        %Computation of metric in each region   
        if isempty(r1)==1
            if isempty(w1)==1
                d1=0;
            else
                if type==4
                    d1=metric(w1,2);
                else
                    d1=metric(w1,type);
                end
            end
        else
            d1=metric(r1,type);
        end

        if isempty(r2)==1
            if isempty(w2)==1
                d2=0;
            else
                if type==4
                    d2=metric(w2,2);
                else
                    d2=metric(w2,type);
                end
            end
        else
            d2=metric(r2,type);
        end

        if isempty(r3)==1
            if isempty(w3)==1
                d3=0;
            else
                if type==4
                    d3=metric(w3,2);
                else
                    d3=metric(w3,type);
                end
            end
        else
            d3=metric(r3,type);
        end

        if isempty(r4)==1
            if isempty(w4)==1
                d4=0;
            else
                if type==4
                    d4=metric(w4,2);
                else
                    d4=metric(w4,type);
                end
            end
        else
            d4=metric(r4,type);
        end

        %Total distance weighted by observations in each region
        d=length(w1)*d1+length(w2)*d2+length(w3)*d3+length(w4)*d4;

        %Minimum metric function
        m=min(d,m);

        if d==m
            ind=i;
        end

    end

    %Optimal cuts
    if mod(iter,2)==1    
        xcut=S(ind,1);
    else
        ycut=S(ind,2);
    end

    %Updates
    iter=iter+1;
    tol=abs(m-m0);
  
end


%Determine intervals I in each region
r1=X(X(:,1)>=xcut & X(:,2)>=ycut,:);
r2=X(X(:,1)>xcut & X(:,2)<ycut,:);
r3=X(X(:,1)<=xcut & X(:,2)<=ycut,:);
r4=X(X(:,1)<xcut & X(:,2)>ycut,:);
     
I=zeros(4,2);
if isempty(r1)==1
    I(1,:)=[Inf,Inf];
else
    [~ ,I(1,:)]=metric(r1,4);
end
   
if isempty(r2)==1
    I(2,:)=[Inf,Inf];
else
    [~ ,I(2,:)]=metric(r2,4);
end
        
if isempty(r3)==1
    I(3,:)=[Inf,Inf];
else
    [~ ,I(3,:)]=metric(r3,4);
end
        
if isempty(r4)==1
    I(4,:)=[Inf,Inf];
else
    [~ ,I(4,:)]=metric(r4,4);
end

%Length of intervals
l=abs(I(:,1)-I(:,2));

end

