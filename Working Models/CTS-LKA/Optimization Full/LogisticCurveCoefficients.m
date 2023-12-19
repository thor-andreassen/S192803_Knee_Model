function [k,x0,y0,L,logist_func] = LogisticCurveCoefficients(a,b,p_a,p_b,xa,xb)
    % inputs are
    % a is the value of the function at X=-INF
    % b is the value of the function at X=INF
    % xa is a known x value to describe the curve slope at
    % xb is a known x value to describe the curve slope at
    % p_a is the percentile of the total function (0 to 1) of the curve at the point xa
    % p_b is the percentile of the total function (0 to 1) of the curve at the
    % point xb

    % outputs are
    % k is the exponential rate
    % x0 is the center offset
    % y0 is the vertical offset
    % L is the logistic amplitude scaling

    % Note the Standard SIGMOID function has an L of 1, an x0 of 0, a y0 of 9
    % and a k of 1.

    t2 = p_a-1.0;
    t3 = 1.0./p_a;
    t4 = p_b-1.0;
    t5 = 1.0./p_b;
    t6 = t2.*t3;
    t7 = t4.*t5;
    t8 = -t6;
    t9 = -t7;
    t10 = log(t8);
    t11 = log(t9);
    t12 = -t11;
    t13 = t10+t12;
    k=-t13./(xa-xb);
    x0=-(t11.*xa-t10.*xb)./t13;
    y0=a;
    L=b-a;
    logist_func=@(x) L/(1+exp(-k*(x-x0)))+y0;
end