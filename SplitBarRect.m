function [ BarRectOut ] = SplitBarRect( BarRectIn, NumBlocks, ScreenRect )
%SplitBarRect
%   Split rectangulars in to sub rects so that we can draw square
%   gratings. BarRectIn should by 4 by N (frames) matrix. BarRectOut is 4
%   by N by Num matrix

BarRectOut = repmat(BarRectIn, 1,1,NumBlocks);
if (BarRectIn(3,1)-BarRectIn(1,1))<(BarRectIn(4,1)-BarRectIn(2,1)) % vertical bar
    BlockLength = ScreenRect(4)/NumBlocks;
    BarRectOut(4,:,1) = BarRectOut(2,:,1) + BlockLength;
    for iblock = 2:NumBlocks
        BarRectOut(2,:,iblock) = BarRectOut(4,:,iblock-1);
        BarRectOut(4,:,iblock) = BarRectOut(2,:,iblock) + BlockLength;
    end
else
    BlockLength = ScreenRect(3)/NumBlocks;
    BarRectOut(3,:,1) = BarRectOut(1,:,1) + BlockLength;
    for iblock = 2:NumBlocks
        BarRectOut(1,:,iblock) = BarRectOut(3,:,iblock-1);
        BarRectOut(3,:,iblock) = BarRectOut(1,:,iblock) + BlockLength;
    end
end

BarRectOut = round(BarRectOut);

