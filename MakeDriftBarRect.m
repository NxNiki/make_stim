function BarRect = MakeDriftBarRect(Duration, BarWidth, MoveDirection, StimRect, frameRate)
% Input: BarWidth and StimRect are in pixel units.
% MoveDirection: [1:right, 2:bottom, 3:left, 4:top]
% Output: BarRect: 4 by N frames matrix, each column is the Rect (left,
% top, right, bottom) of a single frame.



% Convert movieDuration in seconds to duration in frames to draw:
NumFrames=round(Duration * frameRate);

BarRect = repmat(StimRect(:),1,NumFrames);
switch MoveDirection
    case 1
        BarRect(1,:) = linspace(StimRect(1), StimRect(3)-BarWidth, NumFrames);       
        BarRect(3,:) = linspace(StimRect(1)+BarWidth, StimRect(3), NumFrames);
    case 2
        BarRect(2,:) = linspace(StimRect(2), StimRect(4)-BarWidth, NumFrames);       
        BarRect(4,:) = linspace(StimRect(2)+BarWidth, StimRect(4), NumFrames);
    case 3
        BarRect(1,:) = linspace(StimRect(3)-BarWidth, StimRect(1), NumFrames);       
        BarRect(3,:) = linspace(StimRect(3), StimRect(1)+BarWidth, NumFrames);
    case 4
        BarRect(2,:) = linspace(StimRect(4)-BarWidth, StimRect(2), NumFrames);       
        BarRect(4,:) = linspace(StimRect(4), StimRect(2)+BarWidth, NumFrames);
end

    
 