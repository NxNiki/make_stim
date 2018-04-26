function [ varout ] = checkvar( varin, varargin )
%CHECKVAR check input variable for specific data type
%   Example:
%       tf = checkvar(1:10,'scalar')
%       tf = checkvar(1,'interger',[0,10])
%
%   by Niki 2015/7/17

n = length(varargin);
for i = 1:n
    if ischar(varargin{i})
        switch varargin{i}
            case 'logical'
                if islogical(varin)
                    varout = varin;
                elseif all(varin==1|varin==0)
                    varout = logical(varin);
                else
                    error('not logical input')
                end
            case 'integer'
                if isinteger(varin)
                    varout = varin;
                elseif all(~mod(varin,1))
                    varout = int16(varin);
                else
                    error('not integer/round number input')
                end
            case 'scalar'
                if numel(varin)==1
                    varout = varin;
                else
                    error('not scalar input')
                end
            otherwise
                showerr(varargin{i})
        end
    elseif numel(varargin{i})==2&&isnumeric(varargin{i})
        range = varargin{i};
        if all(varin<=range(2)&varin>=range(1))
            varout = varin;
        else
            error('input not in range: %f to %f', range)
        end
    else
        showerr(varargin{i})
    end
end

    function showerr(var)
        disp(var)
        error('not defined input')
    end

end

