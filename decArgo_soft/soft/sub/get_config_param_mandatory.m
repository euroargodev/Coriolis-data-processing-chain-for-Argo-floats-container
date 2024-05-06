   % ------------------------------------------------------------------------------
% Retrieve the list of configuration parameters we want to see (even if not
% modified) for a given decoder.
%
% SYNTAX :
%  [o_configParamName] = get_config_param_mandatory(a_decoderId)
%
% INPUT PARAMETERS :
%   a_decoderId : float decoder Id
%
% OUTPUT PARAMETERS :
%   o_configParamName : configuration parameter list
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   06/21/2014 - RNU - creation
% ------------------------------------------------------------------------------
function [o_configParamName] = get_config_param_mandatory(a_decoderId)

% output parameter initialization
o_configParamName = [];

% current float WMO number
global g_decArgo_floatNum;

switch (a_decoderId)
   
   case {1, 3, 4, 11, 12, 17, 19, 24, 25, 27, 28, 29, 30, 31, 32}
      % Provor Argos
      o_configParamName = [ ...
         {'CONFIG_CycleTime_days'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
            
   case {105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 301, 302, 303}
      % Remocean & Arvor-CM
      o_configParamName = [ ...
         {'CONFIG_NumberOfSubCycles_NUMBER'}; ...
         {'CONFIG_CycleTime_hours'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         {'CONFIG_TransmissionEndCycle_LOGICAL'}; ...
         ];
      
   case {121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133}
      % CTS5
      o_configParamName = [ ...
         {'CONFIG_CycleTime_seconds'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {201, 202, 203, 204, 205, 206, 207, 208, 209, 215, 216, 218, 221}
      % Provor Iridium
      o_configParamName = [ ...
         {'CONFIG_CycleTime_days'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {210, 211, 212, 222, 213, 214, 217, 223, 224, 225, 226}
      % Arvor-ARN Iridium
      % Arvor-ARN-Ice Iridium 5.45 & 5.47
      % Provor-ARN-DO Iridium
      % Provor-ARN-DO-Ice Iridium
      % Arvor-ARN-DO-Ice Iridium 5.46
      % Arvor-ARN-DO-Ice Iridium 5.48
      % Arvor-ARN-Ice RBR Iridium 5.49
      % Provor-ARN-DO-Ice Iridium 5.76
      % Arvor-ARN-Ice RBR 1 Hz Iridium 5.51
      o_configParamName = [ ...
         {'CONFIG_CycleTime_hours'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {219, 220}
      % Arvor-C Iridium 5.3 & 5.301
      % nothing
      
   case {1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, ...
         1012, 1013, 1014, 1015, 1016, 1021, 1022}
      % Apex Argos
      o_configParamName = [ ...
         {'CONFIG_CycleTime_hours'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, ...
         1201, 1314}
      % Apex Iridium Rudics & Sbd
      % Navis
      o_configParamName = [ ...
         {'CONFIG_CycleTime_minutes'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1321, 1322, 1323}
      % Apex APF11 Iridium
      o_configParamName = [ ...
         {'CONFIG_CycleTime_minutes'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {2001, 2002, 2003}
      % NOVA/DOVA
      o_configParamName = [ ...
         {'CONFIG_CycleTime_days'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   case {3001}
      % NEMO
      o_configParamName = [ ...
         {'CONFIG_CycleTime_minutes'}; ...
         {'CONFIG_ParkPressure_dbar'}; ...
         {'CONFIG_ProfilePressure_dbar'}; ...
         ];
      
   otherwise
      fprintf('WARNING: Float #%d: No mandatory configuration parameter list defined yet for decoderId #%d\n', ...
         g_decArgo_floatNum, ...
         a_decoderId);
end

return