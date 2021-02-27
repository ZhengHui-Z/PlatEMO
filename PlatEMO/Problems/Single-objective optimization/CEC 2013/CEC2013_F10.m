classdef CEC2013_F10 < PROBLEM
% <single> <real> <large>
% 20-nonseparable shifted and rotated Rastrigin's function

%------------------------------- Reference --------------------------------
% X. Li, K. Tang, M. N. Omidvar, Z. Yang, and K. Qin, Benchmark functions
% for the CEC'2013 special session and competition on large-scale global
% optimization, RMIT University, Australia, 2013.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2021 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    properties
        Xopt;	% Optimal decision vector
        R25;    % Rotation matrices
        R50;
        R100;
        p;      % Rank of decision variables
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            CallStack = dbstack('-completenames');
            load(fullfile(fileparts(CallStack(1).file),'CEC2013.mat'),'Data');
            obj.Xopt = Data{10}.xopt;
            obj.R25  = Data{10}.R25;
            obj.R50  = Data{10}.R50;
            obj.R100 = Data{10}.R100;
            obj.p    = Data{10}.p;
            obj.M    = 1;
            obj.D    = 1000;
            obj.lower    = zeros(1,obj.D) - 32;
            obj.upper    = zeros(1,obj.D) + 32;
            obj.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            S = [50 50 25 25 100 100 25 25 50 25 100 25 100 50 25 25 25 100 50 25];
            W = [3.13e-1 1.51e1 2.32e3 8.06e-4 1.14e1 3.55e0 3.00e1 9.98e-1 1.62e0 1.51e0 6.08e-1 4.46e6 6.81e-5 1.36e-1 7.89e-4 5.99e4 1.85e0 2.48e1 5.43e-1 3.92e1];
            PopDec = PopDec - repmat(obj.Xopt,size(PopDec,1),1);
            PopObj = zeros(size(PopDec,1),1);
            for i = 1 : length(S)
                loc = obj.p(sum(S(1:i-1))+1:sum(S(1:i)));
                switch S(i)
                    case 25
                        PopDec(:,loc) = PopDec(:,loc)*obj.R25;
                    case 50
                        PopDec(:,loc) = PopDec(:,loc)*obj.R50;
                    case 100
                        PopDec(:,loc) = PopDec(:,loc)*obj.R100;
                end
            	PopObj = PopObj + W(i)*Ackley(Tdiag(Tasy(Tosz(PopDec(:,loc)),0.2),10));
            end
        end
    end
end

function F = Ackley(X)
    F = -20.*exp(-0.2.*sqrt(mean(X.^2,2))) - exp(mean(cos(2*pi*X),2)) + 20 + exp(1);
end

function Z = Tosz(X)
    X1 = zeros(size(X));
    X1(X~=0) = log(abs(X(X~=0)));
    C1 = zeros(size(X)) + 5.5;
    C1(X>0) = 10;
    C2 = zeros(size(X)) + 3.1;
    C2(X>0) = 7.9;
    Z = sign(X).*exp(X1+0.049*(sin(C1.*X1)+sin(C2.*X1)));
end

function Z = Tasy(X,beta)
    Z = X.^(1+repmat(beta*linspace(0,1,size(X,2)),size(X,1),1).*sqrt(X));
    Z(X<=0) = X(X<=0);
end

function Z = Tdiag(X,alpha)
    Z = X.*repmat(sqrt(alpha).^linspace(0,1,size(X,2)),size(X,1),1);
end