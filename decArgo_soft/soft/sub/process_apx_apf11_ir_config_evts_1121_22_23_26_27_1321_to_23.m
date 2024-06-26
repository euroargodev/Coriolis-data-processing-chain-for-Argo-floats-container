% ------------------------------------------------------------------------------
% Get configuration information from Apex APF11 events.
%
% SYNTAX :
%  [o_missionCfg, o_sampleCfg] = process_apx_apf11_ir_config_evts_1121_22_23_26_27_1321_to_23(a_events)
%
% INPUT PARAMETERS :
%   a_events : input system_log file event data
%
% OUTPUT PARAMETERS :
%   o_missionCfg : mission configuration data
%   o_sampleCfg  : sample configuration data
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/27/2018 - RNU - creation
% ------------------------------------------------------------------------------
function [o_missionCfg, o_sampleCfg] = process_apx_apf11_ir_config_evts_1121_22_23_26_27_1321_to_23(a_events)

% output parameters initialization
o_missionCfg = [];
o_sampleCfg = [];

% current float WMO number
global g_decArgo_floatNum;

% current cycle number
global g_decArgo_cycleNum;


% mission configuration
PATTERN_START = '-----------Mission Parameters-----------';
PATTERN_END = '----------------------------------------';

events = a_events(find( ...
   strcmp({a_events.functionName}, 'MissionCfg') | ...
   strcmp({a_events.functionName}, 'mission_cfg') ...
   ));
configRec = [];
for idEv = 1:length(events)
   evt = events(idEv);
   dataStr = evt.message;
   if (any(strfind(dataStr, PATTERN_START)))
      configRec = [evt.timestamp {[]}];
      configStruct = [];
   elseif (any(strfind(dataStr, PATTERN_END)))
      configRec{2} = configStruct;
      o_missionCfg = [o_missionCfg; configRec];
      configRec = [];
   else
      if (~isempty(configRec))

         line = evt.message;
         info = textscan(line, '%s', 'delimiter', ' ');
         info = info{:};
         configStruct.(info{1}) = [];
         configStruct.(info{1}) = info(2:end)';
      end
   end
end

% sample configuration
PATTERN_START = '#-----------Sample Config-----------';
PATTERN_END = '#-----------------------------------';

events = a_events(find( ...
   strcmp({a_events.functionName}, 'SampleCfg') | ...
   strcmp({a_events.functionName}, 'sample_cfg') ...
   ));
configRec = [];
configStruct = [];
for idEv = 1:length(events)
   evt = events(idEv);
   dataStr = evt.message;
   if (any(strfind(dataStr, PATTERN_START)))
      configRec = [evt.timestamp {[]}];
      configStruct = [];
   elseif (any(strfind(dataStr, PATTERN_END)))
      if (~isempty(configStruct))
         configRec{2} = configStruct;
         o_sampleCfg = [o_sampleCfg; configRec];
         configRec = [];
      end
   else
      if (~isempty(configRec))
         line = evt.message;

         if ((line(1) == '<') && (line(end) == '>'))

            phase = line(2:end-1);
            if (~isfield(configStruct, phase))
               configStruct.(phase) = [];
            end

         elseif (strncmpi(line, 'SAMPLE', length('SAMPLE')))

            sampType = 'SAMPLE';
            if (~isfield(configStruct.(phase), sampType))
               configStruct.(phase).(sampType) = [];
            end

            % default values
            start = 2500;
            stop = 0;
            interval = 0;
            units = 1; % 1: DBAR, 2:SEC
            count = 1;

            info = textscan(line, '%s');
            info = info{:};

            if (~strcmpi(info{1}, 'SAMPLE'))
               fprintf('ERROR: Float #%d Cycle #%d: Inconsistent sample data\n\n', ...
                  g_decArgo_floatNum, g_decArgo_cycleNum);
               return
            end

            idF = find(strcmp('DBAR', info), 1);
            if (~isempty(idF))
               info(idF) = [];
            end
            idF = find(strcmp('SEC', info), 1);
            if (~isempty(idF))
               units = 2;
               info(idF) = [];
            end

            sensor = info{2};
            if (~isfield(configStruct.(phase).(sampType), sensor))
               configStruct.(phase).(sampType).(sensor) = [];
            end

            if (length(info) >= 3)
               start = str2num(info{3});
            end
            if (length(info) >= 4)
               stop = str2num(info{4});
            end
            if (length(info) >= 5)
               interval = str2num(info{5});
            end
            if (length(info) >= 6)
               count = str2num(info{6});
            end

            configStruct.(phase).(sampType).(sensor) = [configStruct.(phase).(sampType).(sensor); ...
               start stop interval units count];

         elseif (strncmpi(line, 'PROFILE', length('PROFILE')))

            sampType = 'PROFILE';
            if (~isfield(configStruct.(phase), sampType))
               configStruct.(phase).(sampType) = [];
            end

            % default values
            start = 2000;
            stop = 0;
            bin_size = 2;
            rate = 1;

            info = textscan(line, '%s');
            info = info{:};

            if (~strcmpi(info{1}, 'PROFILE'))
               fprintf('ERROR: Float #%d Cycle #%d: Inconsistent sample data\n\n', ...
                  g_decArgo_floatNum, g_decArgo_cycleNum);
               return
            end

            sensor = info{2};
            if (strcmp(sensor, 'PTSH'))
               sensor = 'PH';
               bin_size = 1;
               rate = -1;
            end
            if (~isfield(configStruct.(phase).(sampType), sensor))
               configStruct.(phase).(sampType).(sensor) = [];
            end

            if (length(info) >= 3)
               start = str2num(info{3});
            end
            if (length(info) >= 4)
               stop = str2num(info{4});
            end
            if (length(info) >= 5)
               bin_size = str2num(info{5});
            end
            if (length(info) >= 6)
               rate = str2num(info{6});
            end

            configStruct.(phase).(sampType).(sensor) = [configStruct.(phase).(sampType).(sensor); ...
               start stop bin_size rate];

         elseif (strncmpi(line, 'MEASURE', length('MEASURE')))

            sampType = 'MEASURE';
            if (~isfield(configStruct.(phase), sampType))
               configStruct.(phase).(sampType) = [];
            end

            % default values
            start = -1;
            stop = -1;
            interval = -1;
            count = -1;

            info = textscan(line, '%s');
            info = info{:};

            if (~strcmpi(info{1}, 'MEASURE'))
               fprintf('ERROR: Float #%d Cycle #%d: Inconsistent sample data\n\n', ...
                  g_decArgo_floatNum, g_decArgo_cycleNum);
               return
            end

            sensor = info{2};
            if (~isfield(configStruct.(phase).(sampType), sensor))
               configStruct.(phase).(sampType).(sensor) = [];
            end

            configStruct.(phase).(sampType).(sensor) = [configStruct.(phase).(sampType).(sensor); ...
               start stop interval count];

         end
      end
   end
end

return
