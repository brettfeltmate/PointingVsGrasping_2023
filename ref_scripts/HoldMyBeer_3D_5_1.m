% HoldMyBeer_3D
% Makes use of Certus Optotrack for a go before you know experiment 
clear all;
disp('Running HoldMyBeer')

close all

import java.awt.Robot
import java.awt.event.*;
mouse = Robot;

clocks = [];

if exist('Opto_Ready','var') == 1
    % check if the value is true
    if Opto_Ready == true
        % do nothing, everything is ready
    else
        % do things needed for prep
        camera_file = 'standard'; 
        config_file = 'example_simple_config_file2.ini'; %change Opto variables here 

        % Just gotta pray these work
        optotrak_startup;
        optotrak_set_up_system(camera_file, config_file);
        
        Opto_Ready = true; %used so it doesn't reset the system every time

    end
else 
    % do things needed for prep
    camera_file = 'standard'; 
    config_file = 'example_simple_config_file2.ini'; %change Opto variables here 

    % Just gotta pray these work
    optotrak_startup;
    optotrak_set_up_system(camera_file, config_file);

    Opto_Ready = true; %used so it doesn't reset the system every time
end

% Gather infromation about Participant (literally just dummy proofing to
% make sure you're using the script that you think you are using)
participant_num = input('Enter the number of the Participant: ');

while 1
    
    PvsG = input('Grasping or Pointing? G/P','s');
    PvsG = char(PvsG);
    
    if strcmp(PvsG,'P') == 1 || strcmp(PvsG,'G') == 1 ...
            || strcmp(PvsG,'p') == 1 ||  strcmp(PvsG,'g') == 1
        break
    else
        disp('Not a valid input')
    end
    
end

while 1
    
    RvsL = input('Right or Let Hand? R/L','s');
    RvsL = char(RvsL);
    
    if strcmp(RvsL,'R') == 1 || strcmp(RvsL,'r') == 1 ...
            || strcmp(RvsL,'L') == 1 || strcmp(RvsL,'l') == 1
        break
    else
        disp('Not a valid input')
    end
    
end

while 1
    
    GvsK = input('Go-Before or Know-Before? G/K','s');
    GvsK = char(GvsK);
    
    if strcmp(GvsK,'G') == 1 || strcmp(GvsK,'g') == 1 ...
            || strcmp(GvsK,'K') == 1 || strcmp(GvsK,'k') == 1
        break
    else
        disp('Not a valid input')
    end
    
end

if strcmp(PvsG,'P') == 1
    PvsG = 'Point';
end
if strcmp(PvsG,'p') == 1
    PvsG = 'Point';
end
if strcmp(PvsG,'G') == 1
    PvsG = 'Grasp';
end
if strcmp(PvsG,'g') == 1
    PvsG = 'Grasp';
end
if strcmp(RvsL,'R') == 1
    RvsL = 'Right';
end
if strcmp(RvsL,'r') == 1
    RvsL = 'Right';
end
if strcmp(RvsL,'L') == 1
    RvsL = 'Left';
end
if strcmp(RvsL,'l') == 1
    RvsL = 'Left';
end
if strcmp(GvsK,'G') == 1
    GvsK = 'Go-Before';
end
if strcmp(GvsK,'g') == 1
    GvsK = 'Go-Before';
end
if strcmp(GvsK,'K') == 1
    GvsK = 'Know-Before';
end
if strcmp(GvsK,'k') == 1
    GvsK = 'Know-Before';
end

text_output = strcat('Participant_',num2str(participant_num),'_Running_',RvsL,'_',PvsG, '_with_',GvsK);

% Double Check Information
while 1
    
    response = input(text_output,'s');
    break
    
end

filename = strcat('P',num2str(participant_num,'%03.0f'), '_',RvsL,'_',PvsG, '_with_',GvsK);

% Set up variables for use in experiment
number_of_trials = 30; %15 that go right and 15 that go left, must be an even number in total
number_of_frames_per_trial = 100000; %Large enough that it will never actually reach this

one = ones(1,number_of_trials/2);
zero = zeros(1,number_of_trials/2);
rights = one;
rights(1,(number_of_trials/2+1):number_of_trials) = zero;
rights = rights(randperm(length(rights)));

marker = 7;

global participant_data %doesn't have to be global, but it helps keep track the variable

% Go-Before-you-know Version
if strcmp(GvsK, 'Go-Before')
    
    clear one zero rights 
    number_of_trials = 60;
    
    % Set up variables for use in experiment
    %number_of_trials = 30; %15 that go right and 15 that go left, must be an even number in total
    number_of_frames_per_trial = 100000; %Large enough that it will never actually reach this

    one = ones(1,number_of_trials/2);
    zero = zeros(1,number_of_trials/2);
    rights = one;
    rights(1,(number_of_trials/2+1):number_of_trials) = zero;
    rights = rights(randperm(length(rights)));

    
    for i=1:number_of_trials

        % Set perameters for figure
        screen_size = get(0,'screensize');
        length_figure = screen_size(1,3);
        hight_figure = screen_size(1,4);
        correction = 0; %only needed if there's something off with your screen
        P(1:16,1:16) = NaN; % pointer infromation, but I don't think it works on Matlab 2015...

        % Generate actual figure
        figure1 = figure('Position', [0 0 length_figure hight_figure], 'Color',[0 0 0],...
            'MenuBar','none','resize','off','numbertitl','off');
        axes1 = axes('Units', 'Pixels','Visible','off','Parent',figure1);
        axis equal;
        hold('all');
        rectangle('Parent',axes1,'Position',[0 0 length_figure hight_figure],'EdgeColor',[0 0 0],...
            'FaceColor',[0 0 0]); % Creats a black box that covers anything that might be on the screen
        BoxW = 100;
        set(gca, 'Position', get(gca, 'OuterPosition')- ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]); %don't ask me what this does...

        pause(0.0001)

        %fprintf('Hold B to begin trial') %Only relevant for testing

        %Wait for the first botton click. Note that if they click the wrong
        %button the script will advance but currently it must be the B button
        %or it will break
        pause()

        %used to see how long they are holding down the B key for
        tic

        %Forced wait for certain amount of time holding the keyboard
        while 1

            % Check keyboard
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;

            %Included to make sure that everything stays on the figure,
            %othewise matlab pops up
            mouse.mouseMove(500,0);
            mouse.mousePress(InputEvent.BUTTON1_MASK); %CAREFUL WITH THIS! It will lock your mouse!
            % it you get locked your best bet is force closing matlab.
            % Sometimes you can click your way out of it but it's inconsistant

            if keyCode(1,66) == 0 % 66 if the B key but only on PC for some reason?
                tic
            end

            if keyCode(1,66) == 1
                if toc > 0.5
                    figure1 = text(length_figure/2, hight_figure/2, 'Begin', 'Color', 'w','FontSize',20); 
                    break
                end
            end

            pause(0.0001) % Just leave this, important for displaying objects

        end

        % Wait for them to realease the B key now
        while 1

            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;

            if  keyCode(1,66) == 0
                mouse.mouseRelease(InputEvent.BUTTON1_MASK);
                buttonReleased = toc;
                break
            end

            pause(0.00001) % leave it
        end

        clocks(i,:) = clock;

        % This tic is used for time stamping everything, pretty important so
        % don't delete it
        tic
        box = 0; %variable for marking whether display box is present yet
        trial_end_detected = 0;
        time_velocity_reached = 0; % don't worry about this, just leave it
        for j=1:number_of_frames_per_trial

            %[fail, framecounter(1, j), position3d_array(1, j, :), flags(1, j)] = DataGetNext3D_as_array();
            %times(1,j) = toc; % keep this after getting the data point so that it's not throttled

            % check velocity is fast enough
            %{
            if j > 1 && box == 0
                
                

                % skip if there aren't 2 consecutive data points to analyze
                if isnan(position3d_array(1,j,marker)) == 1 || isnan(position3d_array(1,j-1,marker)) == 1
                    continue
                end

                % Calculate velocity based on position and time differences
                position_difference = position3d_array(1,j,marker) - position3d_array(1,j-1,marker);
                time_difference = times(1,j) - times(1,j-1);

                % 300 = ~3m/s 
                if abs( position_difference/time_difference) > 100

                    % check which side had been randomly assigned to appear and
                    % display a white box
                    pause(0.00001) % Needed for display purposes
                    if rights(1,i) == 0 %Left
                        figure1 = rectangle('Position', [0 1000 length_figure/2 hight_figure],...
                            'EdgeColor',[1 1 1],'FaceColor',[1 1 1]);
                    elseif rights(1,i) == 1 %Right
                        figure1 = rectangle('Position', [length_figure/2 1000,...
                            length_figure/2 hight_figure],'EdgeColor',[1 1 1],'FaceColor',[1 1 1]);
                    else
                        error('boxes didnt show') %Shouldnb't ever really do this... hopefully
                    end

                    pause(0.00001) % Needed for display purposes
                    box = 1; %mark boxes present so it doesn't keep checking velocity
                    time_velocity_reached = toc;
                    %

                end 

            end
            %}

            pause(0.00001) % Needed for display purposes
            if rights(1,i) == 0 %Left
                figure1 = rectangle('Position', [0 1000 length_figure/2 hight_figure],...
                    'EdgeColor',[1 1 1],'FaceColor',[1 1 1]);
            elseif rights(1,i) == 1 %Right
                figure1 = rectangle('Position', [length_figure/2 1000,...
                    length_figure/2 hight_figure],'EdgeColor',[1 1 1],'FaceColor',[1 1 1]);
            else
                error('boxes didnt show') %Shouldnb't ever really do this... hopefully
            end

            %{
            %check when they've come to rest again
            if toc > 0.1 && box == 1 && trial_end_detected == 0
                
                % Calculate velocity based on position and time differences
                position_difference = position3d_array(1,j,marker) - position3d_array(1,j-1,marker);
                time_difference = times(1,j) - times(1,j-1);
                
                % check the math to see if they are slow enough
                if abs(position_difference/time_difference) < 50
                    trial_end = toc; 
                    trial_end_detected = 1;
                    %check if too slow
                    if trial_end > 0.65
                        figure1 = text(length_figure/2, (hight_figure/2)+100, 'Too Slow', 'Color', 'y','FontSize',20);
                    end
                else
                    trial_end = 0;
                end
                
            end
            %}

            %Stop recording data after 1 second of boxes appearing
            if toc > time_velocity_reached+1.3
                break
            end

        end
        
        position_set = strcat('position_trial_',num2str(i));
        times_set = strcat('times_trial_',num2str(i));

        % gather all the data so that it's not lost on each loop
        %participant_data.time_velocity_reached(i,1) = time_velocity_reached;
        participant_data.fingerOffButton(i,1) = buttonReleased;
        %participant_data.(position_set) = position3d_array; 
        %participant_data.(times_set) = times;
        participant_data.right_1_left_0(i,1) = rights(1,i);
        participant_data.clocks = clocks;
        %participant_data.trial_end(i,1) = trial_end;

        %clearing unwanted variables as a preventative measure, making sure
        %that nothing gets carried over (it would mess up the script otherwise)
        %The better was to do this is just set the variables at the beggining
        %of each loop
        
        clearvars -except Opto_Ready participant_data filename mouse rights number_of_frames_per_trial...
            marker time_velocity_reached clocks

        close all

    end
    
% Know-Before-you-go Version
elseif strcmp(GvsK, 'Know-Before')
    
    for i=1:number_of_trials
        
        trial_end = 0;

        % Set perameters for figure
        screen_size = get(0,'screensize');
        length_figure = screen_size(1,3);
        hight_figure = screen_size(1,4);
        correction = 0; %only needed if there's something off with your screen
        P(1:16,1:16) = NaN; % pointer infromation, but I don't think it works on Matlab 2015...

        % Generate actual figure
        figure1 = figure('Position', [0 0 length_figure hight_figure], 'Color',[0 0 0],...
            'MenuBar','none','resize','off','numbertitl','off');
        axes1 = axes('Units', 'Pixels','Visible','off','Parent',figure1);
        axis equal;
        hold('all');
        rectangle('Parent',axes1,'Position',[0 0 length_figure hight_figure],'EdgeColor',[0 0 0],...
            'FaceColor',[0 0 0]); % Creats a black box that covers anything that might be on the screen
        set(gca, 'Position', get(gca, 'OuterPosition')- ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]); %don't ask me what this does...

        pause(0.0001)

        %fprintf('Hold B to begin trial') %Only relevant for testing

        %Wait for the first botton click. Note that if they click the wrong
        %button the script will advance but currently it must be the B button
        %or it will break
        pause()

        %used to see how long they are holding down the B key for
        tic
        
        % Randomized Pause
        k = rand;
        if k < 0.33
           k = 0.3;
        elseif (0.33 < k) && (k < 0.66)
            k = 0.5;
        elseif k > 0.66
            k = 0.7;
        else
            error('error in randomizing time')
        end 

        %Forced wait for certain amount of time holding the keyboard
        while 1

            % Check keyboard
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;

            %Included to make sure that everything stays on the figure,
            %othewise matlab pops up
            mouse.mouseMove(500,0);
            mouse.mousePress(InputEvent.BUTTON1_MASK); %CAREFUL WITH THIS! It will lock your mouse!
            % it you get locked your best bet is force closing matlab.
            % Sometimes you can click your way out of it but it's inconsistant

            if keyCode(1,66) == 0 % 66 if the B key but only on PC for some reason?
                tic
            end

            if keyCode(1,66) == 1
                if toc > k
                    
                    % check which side had been randomly assigned to appear and
                    % display a white box
                    pause(0.00001) % Needed for display purposes
                    if rights(1,i) == 0 %Left
                        figure1 = rectangle('Position', [0 1000 length_figure/2 hight_figure],...
                            'EdgeColor',[1 1 1],'FaceColor',[1 1 1]);
                    elseif rights(1,i) == 1 %Right
                        figure1 = rectangle('Position', [length_figure/2 1000,...
                            length_figure/2 hight_figure],'EdgeColor',[1 1 1],'FaceColor',[1 1 1]);
                    else
                        error('boxes didnt show') %Shouldnb't ever really do this... hopefully
                    end
                    pause(0.00001) % Needed for display purposes 
                    tic %used to calculate response time and difference between frames
                    break
                end
            end
        end

        clocks(i,:) = clocks;
        % Wait for them to realease the B key now
        moving = 0;
        j = 1;
        response_time = 9999; %don't worry about this, leave it
        while 1
            
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            [fail, framecounter(1, j), position3d_array(1, j, :), flags(1, j)] = DataGetNext3D_as_array();
            times(1,j) = toc;
    
            if  keyCode(1,66) == 0 && moving == 0
                mouse.mouseRelease(InputEvent.BUTTON1_MASK);
                response_time = toc;
                moving = 1;
            end
            
            %check when they've come to rest again
            if toc > response_time + 0.1 && moving == 1 
                
                % Calculate velocity based on position and time differences
                position_difference = position3d_array(1,j,marker) - position3d_array(1,j-1,marker);
                time_difference = times(1,j) - times(1,j-1);
                
                % check the math to see if they are slow enough
                if abs(position_difference/time_difference) < 50
                    trial_end = toc; 
                    
                    %check if too slow
                    if trial_end > 0.65
                        figure1 = text(length_figure/2, (hight_figure/2)+100, 'Too Slow', 'Color', 'y','FontSize',20);
                    end
                end
                
            end
            
            %Stop recording data after 1 second of moving
            if toc > response_time+1
                break
            end
                
            
            j = j+1;
            
        end
        
        

        position_set = strcat('position_trial_',num2str(i));
        times_set = strcat('times_trial_',num2str(i));

        % gather all the data so that it's not lost on each loop
        %participant_data.time_velocity_reached(i,1) = time_velocity_reached;
        participant_data.responseTime(i,1) = response_time;
        participant_data.(position_set) = position3d_array; 
        participant_data.(times_set) = times;
        participant_data.right_1_left_0(i,1) = rights(1,i);
        participant_data.trial_end(i,1) = trial_end;
        participant_data.clocks = clocks;
        %participant_data.time_velocity_reached = time_velocity_reached;
        
        %clearing unwanted variables as a preventative measure, making sure
        %that nothing gets carried over (it would mess up the script otherwise)
        %The better was to do this is just set the variables at the beggining
        %of each loop

        clearvars -except Opto_Ready participant_data filename mouse rights number_of_frames_per_trial...
            marker clocks

        close all

    end
    
else
    error('Something went terribly wrong... good luck')
end

%Save Functions 
save(filename, 'participant_data')

% might have to change the clear all 
%clear all
%Opto_Ready = true;

clear all
 %Opto_Ready = true;

%{







% All of the following was used for testing pruposes. Might be helpful in
% making new scripts but it's not actually improtant for this study

camera_file = 'standard'; 
        config_file = 'example_simple_config_file2.ini'; %change Opto variables here 
optotrak_startup;
optotrak_set_up_system(camera_file, config_file);
clear position3d_array
j = 1;
i = 1;
while 1
    [fail, framecounter(i, j), position3d_array(i, j, :), flags(i, j)] = DataGetNext3D_as_array();
    disp(position3d_array(i,j,4))
    j=j+1;
end

tic
i = 1;
j = 1;
while 1
    [fail, framecounter(i, j), position3d_array(i, j, :), flags(i, j)] = DataGetNext3D_as_array();
    %disp(position3d_array(i,j,4))
    times(i,j) = toc;
    
    % check velocity
    if j > 1 

        if isnan(position3d_array(i,j,4)) == 1 || isnan(position3d_array(i,j-1,4)) == 1
            continue
        end

        position_difference = position3d_array(i,j,4) - position3d_array(i,j-1,4);
        disp(position_difference)

        time_difference = times(1,j) - times(1,j-1);

        if position_difference/time_difference > 100

            % make display appear
            disp('yes')

        end 

    end
    j = j + 1;
end


i=1;
j=1;
while 1
    [fail, framecounter(i, j), position3d_array(i, j, :), flags(i, j)] = DataGetNext3D_as_array();
times(1,j) = toc;
end

optotrak_startup;
optotrak_set_up_system(camera_file, config_file);
DataBufferInitializeFile(0,'raw_data.dat');
DataGetNext3D_as_array;
DataBufferStart;
disp('yes')
pause(0.5)
optotrak_stop_buffering_and_write_out;
[, position] = optotrak_convert_raw_file_to_position3d_array('raw_data.dat')


while 1
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
end
%}


