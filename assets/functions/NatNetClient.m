function client = NatNetClient(HostIP, ClientIP, ConnectionType)
%SPAWNNATNETCLIENT Instantiates NatNet Object
%   Returns NatNetClient handler, used to interface between Optitrack and
%   Matlab. Function inputs default to recommended values, 
%   leave blank unless you have reason otherwise.

%   NOTE:
%   - Requires that natnet.p be located on matlab path.
%   - If natnet.p not present, run pcode('natnet.m') to regenerate.
%   - If natnet.m not present, dl NatNetSDK from Optitrack website (it's free)
%   - Confirms connection w/ motive before returning client handler.

%   TODO:
%   - Wrapper around natnet.getFrameOfLabelledMarker which allows for
%   specifying WHICH marker
%   - 
    

    % Create & set up client
    fprintf("Spinning up Optitrack NatNetClient Handler...\n")
    client = natnet;
    
	client.HostIP = '127.0.0.1';
	client.ClientIP = '127.0.0.1';
	client.ConnectionType = 'Multicast';

    % Connection parameters
    % User provided values override defaults 
    if (nargin > 0)
        if (~isempty(HostIP))
    	    client.HostIP = HostIP;
        end
        if (~isempty(ClientIP))
            client.ClientIP = ClientIP;
        end
        if (~isempty(ConnectionType))
            client.ConnectionType = ConnectionType;
        end
    end

    fprintf("Connecting to Optitrack...\n")
    client.connect;
    
    % Reattempt connection if necessary
    while (client.IsConnected == 0)
        fprintf( ...
            "Failed to connect to Optitrack!\n" + ...
            "Make sure that Motive is running and " + ...
            "streaming is turned on (found under 'server').\n\n" ...
        );

        fprintf("Script execution has been paused.\n");
        
        retry = input("Press 'r' to retry, or any other key to quit.", "s");

        if (lower(retry) == 'r')
            client.connect;
        else
            client.delete;
            quit();
        end
    end

    fprintf("Successfully linked with Optitrack.")


end

