% ------------------------------------------------------------------------------
% Get the basic structure to store APEX APF11 Ice detection information.
%
% SYNTAX :
%  [o_iceDetection] = get_ice_detection_apx_apf11_init_struct
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%   o_iceDetection : APEX APF11 Ice detection structure
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/27/2021 - RNU - creation
% ------------------------------------------------------------------------------
function [o_iceDetection] = get_ice_detection_apx_apf11_init_struct

thermalDetect = struct( ...
   'sampleTime', [], ...
   'sampleTimeAdj', [], ...
   'sampleNum', [], ...
   'samplePres', [], ...
   'samplePresAdj', [], ...
   'sampleTemp', [], ...
   'medianTempTime', '', ...
   'medianTempTimeAdj', '', ...
   'medianTemp', '', ...
   'detectTime', '', ...
   'detectTimeAdj', '', ...
   'detectPres', '', ...
   'detectPresAdj', '', ...
   'detectMedianPres', '', ...
   'detectMedianPresAdj', '', ...
   'detectNbSample', '' ...
   );

breakupDetect = struct( ...
   'detectTime', [], ...
   'detectTimeAdj', [], ...
   'detectFlag', [] ...
   );

ascent = struct( ...
   'abortTypeTime', '', ...
   'abortTypeTimeAdj', '', ...
   'abortType', 0 ...
   );

% output parameter
o_iceDetection = struct( ...
   'thermalDetect', thermalDetect, ...
   'breakupDetect', breakupDetect, ...
   'ascent', ascent ...
   );

return
