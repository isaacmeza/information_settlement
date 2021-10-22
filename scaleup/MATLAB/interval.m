function [ l ] = interval( x )
%Objective function in the problem
%           min (prctile(Y,x(2))-prctile(Y,x(1)))^2 
%               s.t. 
%           x(2)-x(1)>=51
%  
global Y

l=(prctile(Y,x(2))-prctile(Y,x(1)))^2;

end

