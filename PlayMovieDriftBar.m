clear
clc

mat_file_dir='/Users/Niki/Documents/MATLAB/Niki/stim_maker/drift_mask';
matfile_name = '001_left_right.mat';
repetition = 12;

try
    % Screen('Preference', 'SkipSyncTests', 1);
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;
    
    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);
    
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end
    
    % Open a double buffered fullscreen window and select a gray background
    % color:
    [w, screenRect]=Screen('OpenWindow',screenNumber, gray);
    ListenChar(1)
    screenRect(3) = screenRect(4);
    load([mat_file_dir, filesep, matfile_name], 'tex', 'fps')
    movie_tex = tex;
    % Compute each frame of the movie and convert the those frames, stored in
    % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
    numFrames=size(tex,3); % temporal period, in frames, of the drifting grating
    textrue = nan(1,numFrames);
    for i=1:numFrames
        textrue(i)=Screen('MakeTexture', w, movie_tex(:,:,i));
    end
    clear movie_tex mat_file_dir matfile_name
    
    % Run the movie animation for a fixed period.
    movieDurationSecs=numFrames/fps;
    frameRate=Screen('FrameRate',screenNumber);
    
    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if frameRate == 0
        frameRate=60;
    end
    
    % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    % play movie with different speed recurrently:
    %movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    % play movie with same speed:
    movieFrameIndices=ceil((1:movieDurationFrames)/(frameRate/fps));
    
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    onset = nan(movieDurationFrames, repetition);
    while repetition>0
        % Animation loop:
        for i=1:movieDurationFrames
            % Draw image:
            Screen('DrawTexture', w, textrue(movieFrameIndices(i)),[], screenRect);
            Screen('DrawText', w, [num2str(repetition), num2str(frameRate)],10 );
            % Show it at next display vertical retrace. Please check DriftDemo2
            % and later, as well as DriftWaitDemo for much better approaches to
            % guarantee a robust and constant animation display timing! This is
            % very basic and not best practice!
            [~, onset(i, end-repetition+1)]= Screen('Flip', w);
            [~, ~, keyCode] = KbCheck();
            if any(strcmp(KbName(keyCode), {'ESCAPE','Escape','ESC','esc'}))
                ListenChar(1)
                sca;
                return;
            end
        end
        repetition=repetition-1;
    end
    
    Priority(0);
    
    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclosed textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll') and we
    % have 12 textues here:
    Screen('Close');
    
    % Close window:
    Screen('CloseAll');
    ListenChar(1)
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('Close', w);
    Screen('CloseAll');
    Priority(0);
    ListenChar(1)
    psychrethrow(psychlasterror);
end %try..catch..
