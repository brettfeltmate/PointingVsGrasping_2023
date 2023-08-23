%{

Pointing vs Grasping 

PSEUDOCODE

-_-_ Script Sequence _-_-

setup
- establish connection with optitrack
- If necessary, supply config to NNC
- Init experiment data container
- Init experiment data template
- Set up screen & display params (i.e., sizings, trial stimuli)
- Determine block ordering (task, hand-used)
- Collect demographics

% Spawn client
NNClient = NatNetClient()

% Peek at assets/data, used for setup
assets = NNClient.getModelDescription
frame = NNClient.getFrame









block()
- Set task demand (point vs grasp; likely specifying which listener to use)
- Present instructions
- For 1:nTrials: call, in sequence, _prep, _run, _wrapup

trial_prep:
- Determine target location
- Initialize flags governing trial events
- Initialize data container for trial (a clone of template)
- Present (some sort of) signal that trial has started
- enable listener(s)

Trial_run:
- Essentially a series of time-delayed fuses
- Listeners (in background) monitor & flag movements
- After some delay, abort trial if no movement
- Otherwise, present target identifier once desired velocity achieved
- After some delay, abort trial if target not reached
- Otherwise, end trial 

Trial_wrapup:
- Stop NNC
- Textually admonish Ss for errors made (if any)
- Maybe some data checking????
- Insert trial data into experiment container and clear


-_-_ ./project_functions/ _-_-

NatNetClient()
- Spins up & returns natnetclient
- All interactions w/ Optitrack handled through client
- Functionally complete, needs to be tested.
- TODO: have it fetch & preview sample frame


PollDemographics()
- Exactly what it sounds like
- Not started.
- I'm thinking demographic data will be stored separate from performance

Cartographer()
- 

-_-_ Listeners _-_-

 


%}


