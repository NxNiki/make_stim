function save_mv(tex, file_name, output_path)
cur_dir = pwd;
if nargin==3
    if ~exist(output_path,'dir')
        mkdir(output_path)
    end
    cd(output_path)
end

if ~iscell(tex)
    tex = {tex};
end

first_tex = tex{1};
num_cell = length(tex);
[width, height, num_frames] = cellfun(@size,tex);


if any(diff(width) | diff(height))
    error('size of all cell elements of tex should be identical')
end

colormode = ndims(first_tex)-3; % 0 grayscale, 1 color
total_frames = sum(num_frames);

% OPEN_MV              Open a MV file and write the file header
%
%     mvfid = open_mv(fname,numframes,width,height,colormode)
%              
%     INPUTS
%          fname      - movie filename as a string
%          numframes  - number of frames
%          width      - x resoltion
%          height     - y resoltion
%          colormode  - 0 for grayscale, 1 for color, default = 0
%
%     OUTPUTS
%          mvfid      - file handler of the MV file
%
%     MISC: use fwrite(mvfid,data,'uchar') to write your data into MV file
%
%     yuxi 08.01.2001

%----- Open file
[mvfid,message] = fopen(file_name,'wb','ieee-le');
if mvfid < 0; fprintf('\n%s\n',message); end

%-- Write the header
fwrite(mvfid,'MV','char');            % ID
fwrite(mvfid,[0 0],'char');
fwrite(mvfid,width(1),'int32');         
fwrite(mvfid,height(1),'int32');        
fwrite(mvfid,total_frames,'int32');     
fwrite(mvfid,colormode,'int32');   
for j = 1: num_cell
    t = tex{j};
    for i = 1:num_frames(j)
        fwrite(mvfid, t(:,:,i)','uchar');
    end
end

fclose(mvfid);
cd(cur_dir);


