%PointVsGrasp_Exp2_v4_May_14th

% This script is designed to run a reaching task involving oclussion
% goggles. The script will block vision from the participant while the
% researcher sets up the environment. Once the environment is set the
% researcher will press enter, which will trigger the script to continue.
% The goggles will then become transparent and the participant will reach
% towards to target that gets cued. 



% Rundown of occlusion goggles

% PLATO_trial(1); %turns them on
% PLATO_lens(1); %opens them
% PLATO_trial(0); %turns them off / closes them

% It's pretty simple functions to operate them, theres some software
% required for your computer to figure out how to connect to them through
% Matlab but after that you'll only need the 3 above functions. What each
% of the functions do is written beside the function itself. In order for
% them to actually work you have to always turn them on first and then open
% them. Make sure that you do this every time before your try to open them,
% usually I just always keep those two functions together. When closing
% them all you need is one function


disp('Running PointVsGrasp_Exp2_v3')

clear all
close all

% check that goggles work before going ahead with everying
% if the goggles are not plugged in, the script will still run but will
% skip over the goggle functionality. 
gogglesPresent = true;
try
    PLATO_trial(1); %turns them on
    PLATO_lens(1); %opens them
catch
    gogglesPresent = false;
    disp('Warning: goggles are not plugged in') 
    pause() % wait for person to press enter to continue
end
%}
%}

% Load in file with all possible conditions
load('GraspingExp2Trials.mat')

% Create prompt to gather infromation about participant
prompt = {'Enter participant ID:'
     'Enter participant age:'
     'Enter participant sex (''m'' or ''f''):'
     'Enter participant handedness (''r'' or ''l''):'
    };
dlg_title = 'Demographics';
num_lines = 1;
dems = inputdlg(prompt,dlg_title,num_lines);

% creat test configuration. This allows you to enter "test" on the first
% line of the prompt and everything else empty
if strcmp(char(dems(1)), 'test') 
    disp('id, age, sex, and hand are overwritten in test mode')
    id = 99;
    age = 99;
    sex = 99;
    hand = 99;
    participant_num = 999;
    PorG = 1;  
else
    id = char(dems(1));
    age = char(dems(2));
    sex = char(dems(3));
    hand = char(dems(4));
    
    if rem(id,2) == 1
        PorG = 1;
    else
        PorG = 2;
    end

    % get numbers
    id = str2num(id);
    age = str2num(age);
    participant_num = id;
    
    % checking for valid inputs for sex
    if (strcmp(sex, 'm') == 1)
        sex = 1;
    elseif (strcmp(sex, 'f') == 1)
        sex = 2;
    else     
        error('nonvalid sex');  % should also get and error when putting in response matrix
    end

    % checking for valid inputs for handedness
    if (strcmp(hand, 'l') == 1)
        hand = 1;
    elseif (strcmp(hand, 'r') == 1)
        hand = 2;
    else
        error('nonvalid handedness');  % should also get and error when putting in response matrix
    end  

end

% Prevent Overwritting Data
fileName = strcat('P',num2str(participant_num),'_PvsG_Exp2_Pointing.mat');
if exist(fileName) == 0 
    % continue as normal
else
    error('Participant file already exists') 
    % In this case, if the file exists but you know it's the naming that
    % you want to give the file, just delete the file and rerun everything
    % with that info
end

% Randomize trials
numTrials = length(GraspingExp2Trials);
randomizer = randperm(numTrials);
randomizer = randomizer';
randomizer(:,2:4) = GraspingExp2Trials;
trials = sortrows(randomizer);

% Begin trial loops 
for trialNum = 1:numTrials
    
    disp(trialNum)
    
    % Figure Preameters
    screen_size = get(0,'screensize');
    length_figure = screen_size(1,3);
    hight_figure = screen_size(1,4);
    P(1:16,1:16) = NaN; % pointer infromation
    
    %Figure Initialization
    figure1 = figure('Position', [0 0 length_figure hight_figure], 'Color',[0 0 0],...
        'MenuBar','none','resize','off','numbertitl','off');
    axes1 = axes('Units', 'Pixels','Visible','off','Parent',figure1);
    axis equal;
    hold('all');
    rectangle('Parent',axes1,'Position',[0 0 length_figure hight_figure],...
        'EdgeColor',[0 0 0],'FaceColor',[0 0 0]); % Creats a black box that 
        % covers anything that might be on the screen
    set(gca, 'Position', get(gca, 'OuterPosition')- ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

    % ask participant to get finger on button
    text(length_figure/2 - 150, hight_figure/2, 'Press Button', 'Color', 'w', 'FontSize', 44)
    
    pause(0.00001) % for display reasons
    
    % wait for them to press button 
    %Forced wait for certain amount of time holding the keyboard
    while 1
        % Check keyboard
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        % check that the write button is being pressed (B key for this
        % experiment). To change the button, change 66 to whatever button
        % you want
        if keyCode(1,66) == 0 % 66 if the B key but only on PC for some reason?
            tic
        end

        if keyCode(1,66) == 1
            if toc > 0.1
                if gogglesPresent == true
                    PLATO_trial(0); %turns them off / closes them
                else
                    disp('goggles closed')
                end
                break
            end
        end
    end
    
    % This is just to cover up some pervious text
    text(length_figure/2 - 150, hight_figure/2, 'Press Button', 'Color', 'black', 'FontSize', 44)
    
    % Display layout for Victoria
    % this is only shown to victoria so that she can create the setup for
    % the participant
    squareHW = 100;
    hightOfset = squareHW /2;
    XOfset = squareHW /2;
    distanceBetweenBlocks = 700;
    z = distanceBetweenBlocks/2;
    y = distanceBetweenBlocks+z;
    fromCenter1 = z;
    fromCenter2 = y;
    centerX = length_figure /2;
    centerY = hight_figure /2;
    
    % Make outlines and Boxes for possible targets
    if trials(trialNum,2) > 0 
        rectangle('Position',[centerX-fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
    else
        rectangle('Position',[centerX-fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[0 0 0],'EdgeColor',[1 1 1])
    end
    
    if trials(trialNum,3) > 0
        rectangle('Position',[centerX-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
    else
        rectangle('Position',[centerX-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[0 0 0],'EdgeColor',[1 1 1])
    end
    
    if trials(trialNum,4) > 0
        rectangle('Position',[centerX+fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
        'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
    else
        rectangle('Position',[centerX+fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
        'FaceColor',[0 0 0],'EdgeColor',[1 1 1])
    end
    
    % This will check to make sure that participant hasn't taken their
    % finger off the B key. If they do, their goggles will still remained
    % closed but Victoria will receive a prompt to tell the participant to
    % keep their finger on the B key
    while 1

        % Check keyboard
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        % check that they are still holding key
        if keyCode(1,66) == 0
            text(hight_figure/6 ,length_figure/4, 'Tell hem to keep holding button', 'Color', 'w', 'FontSize', 44)
        end
        
        % This one check for when the participant is still holding the B
        % key, and for when Victoria pushes the Enter button. Once this
        % happenes, the experiment will continue
        if keyCode(1,13) == 1 && keyCode(1,66) == 1 % CHANGE THIS TO ENTER BUTTON
            break
        end

        pause(0.0001) % Just leave this, important for displaying object

    end
    
    % clear the screen so the participant doesn't see what victoria was
    % seeing
    close all
    
    % Display layout for Participant
    % Figure Initialization
    figure1 = figure('Position', [0 0 length_figure hight_figure], 'Color',[0 0 0],...
        'MenuBar','none','resize','off','numbertitl','off');
    axes1 = axes('Units', 'Pixels','Visible','off','Parent',figure1);
    axis equal;
    hold('all');
    rectangle('Parent',axes1,'Position',[0 0 length_figure hight_figure],...
        'EdgeColor',[0 0 0],'FaceColor',[0 0 0]); % Creats a black box that 
        % covers anything that might be on the screen
    set(gca, 'Position', get(gca, 'OuterPosition')- ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
    
    pause(0.1); % trust me and just leave it as two seperate pauses
    pause(0.1);
    
    if gogglesPresent == true
        PLATO_trial(1); % have to turn them back on again 
        PLATO_lens(1); % them you will be able to open them again
    else
        disp('goggles now open')
    end
    
    % check that key is still down. 
    % this part makes sure that the participant keeps their finger on the
    % button until something shows up on the screen. The goggles will be
    % open, but there is a delay before they are qued to reach for
    % something
    tic
    while 1 
         % Check keyboard
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        % check that they are still holding key
        if keyCode(1,66) == 0
            text(hight_figure/6 ,length_figure/4, 'Let go too soon, hold down button', 'Color', 'w', 'FontSize', 44)
            pause(0.00001)
        elseif toc > 1 %waits 1 second
            break
        end
        
        
    end
    
    tic
    
    % display the target that the participant will actially reach for 
    if trials(trialNum,2) > 1 
        rectangle('Position',[centerX-fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
    else
        %rectangle('Position',[centerX-fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
         %   'FaceColor',[0 0 0],'EdgeColor',[1 1 1])
    end
    
    if trials(trialNum,3) > 1
        rectangle('Position',[centerX-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
    else
       % rectangle('Position',[centerX-XOfset centerY-hightOfset squareHW squareHW],...
        %    'FaceColor',[0 0 0],'EdgeColor',[1 1 1])
    end
    
    if trials(trialNum,4) > 1
        rectangle('Position',[centerX+fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
            'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
    else
        %rectangle('Position',[centerX+fromCenter1-XOfset centerY-hightOfset squareHW squareHW],...
         %   'FaceColor',[0 0 0],'EdgeColor',[1 1 1])
    end
    
    %}
    
    
    
    % given them time to perform eveyrthing and reset
    pause(2)
    
    % Trial End
    close all 
    
    save(fileName)

end

