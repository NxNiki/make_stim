% this script do not need the prepared movie text.
% Niki 2016/4/1
% add drift_grating to make texture.
% Niki 2016/6/29.
% use grating to make texture frame by frame. To cope with out of memory
% problem on 32 bit system. But this may suffer timing precision. We solve
% this problem by storing texture into cell array rather than 3-D matrix.
% Niki 2016/6/29.

clear;clc

% define parameters of drift grating texture:
StimDuration = 3;% seconds
% TFRange = [0.5,1,2,4];
TFRange = [0.5,1];

ITI = 10;
Contrast = 1;
spatial_frq = 0.02; % cycles per degree (cpd)
orientation = 0;

TriggerWidth = 60; % pixel size of Trigger Stingal (a white square on the bottom right corner on the screen)
TriggerDuration = 2; % seconds, this should be large enough to allow compute tex for the upcoming stimuli.
PreStimDuration = 3;

TFList = Shuffle(perms(TFRange),2)';
NumTrials = numel(TFList);
TrialOnset = cumsum(rand(NumTrials,1)*2+ITI+PreStimDuration+StimDuration+TriggerDuration)-StimDuration-PreStimDuration-TriggerDuration;

try
    
    Screen('Preference', 'SkipSyncTests', 1);
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
    [w, screenRect]=Screen('OpenWindow',screenNumber, black);
    HideCursor
    ListenChar(2) % suppress input from keybroad to appear in the command window or script
    
    frameRate=Screen('FrameRate',screenNumber);
    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if frameRate == 0
        frameRate=60;
    end
    
    % right bottom:
    %TriggerRect = [screenRect([3,4])-TriggerWidth, screenRect([3,4])]';
    % right top:
    TriggerRect = [screenRect(3)-TriggerWidth, screenRect([2,3]), TriggerWidth]';
    
    framesPerTrial = StimDuration*frameRate;
    
    % run this just when testing. Saving onset time of each frame may cause
    % memory problem.
    % frame_onset = nan(framesPerTrial,NumTrials);
    actual_trial_onset = nan(2, NumTrials);
    
    % use class screen to find view angle, in order to use spatial frequency
    % correctly.
    
    scr = screen;
    scr.resolution = screenRect(3:4);
    scr.view_elevation = 0;
    view_angle = scr.view_angle_rad; %[-theta_h, theta_v1, theta_h, -theta_v2];
    
    % waitframes = 1 means: Redraw every monitor refresh. If your GPU is
    % not fast enough to do this, you can increment this to only redraw
    % every n'th refresh. All animation paramters will adapt to still
    % provide the proper grating. However, if you have a fine grating
    % drifting at a high speed, the refresh rate must exceed that
    % "effective" grating speed to avoid aliasing artifacts in time, i.e.,
    % to make sure to satisfy the constraints of the sampling theorem
    % (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
    % you don't know what this means):
    waitframes = 1;
    % Query duration of one monitor refresh interval:
    ifi=Screen('GetFlipInterval', w);
    % Translate frames into seconds for screen update interval:
    waitduration = (waitframes - 0.5) * ifi;
    
    [x,y]=meshgrid(linspace(view_angle(1), view_angle(3),screenRect(3)), ...
        linspace(view_angle(2), view_angle(4),screenRect(4)));
    angle=-orientation*pi/180;
    [x,y]=rotate_coordinates(x,y,angle);
    f=spatial_frq*360;
    inc=mean(white-gray)*Contrast;
    
    % clear unusefull variables to save memory space:
    clear scr x Contrast ifi waitframes angle orientation view_angle TFRange spatial_frq screenRect
    
    while 1
        WaitSecs(0.2);
        [~, ~, keyCode] = KbCheck();
        if any(strcmp(KbName(keyCode), {'ESCAPE','Escape','ESC','esc'}))
            ListenChar(1)
            sca;
            return;
        elseif any(strcmp(KbName(keyCode), {'space','s'}))
            break
        end
    end
    
    % Draw the 1st frame:
    % draw background, comment if use black as background:
    %Screen('Fillrect', w, gray);
    
    DrawFormattedText(w, 'Start', 'center', 'center', white);
    vbl = Screen('Flip',w);
    startSecs = Screen('Flip',w, vbl+1);
    
    for i_trial = 1:NumTrials
        
        % just make texture (phase list) for one cycle to save memory space.
        % try to make it as concise as possible to increase
        % speed.
        stm_length = min([StimDuration,1/TFList(i_trial)]);
        drift_omega = 2*pi*TFList(i_trial);
        texframes = stm_length*frameRate;
        phase_list = linspace(0, drift_omega*stm_length, texframes) + rand(1)*2*pi;
        m=sin(f*y - phase_list(1));

        % Draw Trigger:
        Screen('Fillrect', w, white, TriggerRect);
        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp as timing baseline for our redraw loop:
        [vbl, actual_trial_onset(1,i_trial)]=Screen('Flip', w, startSecs+TrialOnset(i_trial));

        % Trigger disappear:
        vbl=Screen('Flip', w, startSecs+TrialOnset(i_trial)+TriggerDuration);
        
        % draw 1st frame:
        texture = Screen('MakeTexture', w, (gray(1)+inc*m));
        [vbl, actual_trial_onset(2,i_trial)]= Screen('Flip', w, vbl+PreStimDuration);

        for i=2:framesPerTrial
            % Draw image:
            m=sin(f*y - phase_list(mod(i-1, texframes)+1));            
            texture = Screen('MakeTexture', w, gray(1)+inc*m);
            Screen('DrawTexture', w, texture)
            
            % Screen('DrawText', w, [num2str(i_rep), num2str(frameRate)],10 );
            
            % Flip 'waitframes' monitor refresh intervals after last redraw.
            % Providing this 'when' timestamp allows for optimal timing
            % precision in stimulus onset, a stable animation framerate and at
            % the same time allows the built-in "skipped frames" detector to
            % work optimally and report skipped frames due to hardware
            % overload:
            %[vbl, frame_onset(i,i_trial)]= Screen('Flip', w, vbl + waitduration);
            
            [vbl]= Screen('Flip', w, vbl + waitduration);
        end
        
        % iti:
        vbl2 = Screen('Flip', w);
        while 1&&vbl2<vbl+1
            vbl2 = WaitSecs(0.2);
            [~, ~, keyCode] = KbCheck();
            if any(strcmp(KbName(keyCode), {'ESCAPE','Escape','ESC','esc'}))
                ListenChar(1)
                sca;
                return;
            end
        end
    end
    WaitSecs(ITI);
    Priority(0);
    
    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclosed textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll')
    Screen('Close');
    
    % Close window:
    Screen('CloseAll');
    ListenChar(1);
    ShowCursor;
    
%     difonset = diff(frame_onset);
%     plot(difonset);
%     title(['total duration: ' num2str(range(frame_onset(:)))])

    actual_trial_onset=actual_trial_onset-startSecs;
    plot(bsxfun(@minus, actual_trial_onset',TrialOnset))
    
    save(['PlayMovieDriftGratingStimInfo',datestr(now,'yyyymmddTHHMMSS')],'actual_trial_onset','TrialOnset','TFList')
    
catch
    Screen('CloseAll');
    Priority(0);
    ListenChar(1);
    ShowCursor;
    psychrethrow(psychlasterror);
end %try..catch..


