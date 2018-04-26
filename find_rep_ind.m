function rep = find_rep_ind(code)
%FIND_REP_IND find the repetition index of rows in code.
%   by Niki 2015/7/21.
%   see also combination.m

%{
repeat = 3;
[~,~,code] = combination([3,4],repeat);
rep = find_rep_ind(code)
%}

[~,~,ib] = unique(code,'rows');
len = length(ib);
rep = ones(len,1);

for i=2:len
    rep(i) = rep(i) + sum(ismember(ib(1:i-1),ib(i)));
end

