function [code1, code2, rndcode] = combination(levelList,repeat)
% by Niki 2014/6/29
% add code1 by Niki 2015/1/26
% add rndcode
% add cell array input containing arbitary contents that will be the value
% of code, rather than 1:n round numbers.
% by Niki 2015/7/20
% add parameter repeat. Niki 2015/7/21

% see also RandomGroup.m find_rep_ind

%{
combination([3,2,2,2,45])
combination([3,4,2,2])
combination([3,3,2,2])
combination([3,6,2,2])
[a,b]= combination([1,3,4])
[a,b]= combination([2,3,4])
[a,b]= combination({[2,3,4],[0.1,0.2,0.3]})
[a,b,c]= combination({[2,3,4],[0.1,0.2,0.3]},3)
%}

if nargin<2||isempty(repeat)
    repeat = 1;
end

if iscell(levelList)
    lL = levelList;
    levelList = cellfun(@numel,lL);
else
    lL = [];
end

rows=prod(levelList);
cols=length(levelList);

if cols==0
    code1 = [];
    code2 = [];
    rndcode = [];
    return
end

code2=nan(rows,cols);
code1=code2;

code2(:,1) = kron(ones(1,rows/levelList(1)),1:levelList(1))';
for i=2:cols-1
    reptition = prod(levelList(1:i-1));
    code2(:,i)= kron(1:rows/reptition, ones(1,reptition))';
    code2(:,i)= mod(code2(:,i)-1,levelList(i))+1;
end
code2(:,cols) = kron(1:levelList(cols),ones(1,rows/levelList(cols)))';
code2 = repmat(code2, repeat, 1);

% code1 has the order of rows rearranged, which is more commonly used in
% Psychological experiments. It can be obtained by sortrows(code2, 1:cols),
% but we think sort algorithms may take longer time to run.
code1(:,1) = kron(1:levelList(1),ones(1,rows/levelList(1)))';
for i=2:cols-1
    reptition = prod(levelList(i+1:cols));
    code1(:,i)= kron(1:rows/reptition, ones(1,reptition))';
    code1(:,i)= mod(code1(:,i)-1,levelList(i))+1;
end
code1(:,cols) = kron(ones(1,rows/levelList(cols)),1:levelList(cols))';
code1 = repmat(code1, repeat, 1);

% randomize the row index of code:
ind = randperm(rows*repeat);
rndcode = code1(ind,:);

% replace code with value if levelList is cell array:
if ~isempty(lL)
    for i = 1:cols
        val = lL{i};
        code1(:,i) = val(code1(:,i));
        code2(:,i) = val(code2(:,i));
        rndcode(:,i) = val(rndcode(:,i));
    end
end

end

