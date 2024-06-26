% ------------------------------------------------------------------------------
% Convert sensor counts to physical values for temperatures.
%
% SYNTAX :
%  [o_tempValues] = sensor_2_value_for_temp_204_to_214_217_219_220_222_to_226(a_tempCounts)
%
% INPUT PARAMETERS :
%   a_tempCounts : temperature counts
%
% OUTPUT PARAMETERS :
%   o_tempValues : temperature values
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%  03/11/2015 - RNU - creation
% ------------------------------------------------------------------------------
function [o_tempValues] = sensor_2_value_for_temp_204_to_214_217_219_220_222_to_226(a_tempCounts)

% output parameters initialization
o_tempValues = [];

% default values
global g_decArgo_tempDef;
global g_decArgo_tempCountsDef;

% convert counts to values
o_tempValues = a_tempCounts;
idDef = find(a_tempCounts == g_decArgo_tempCountsDef);
o_tempValues(idDef) = ones(length(idDef), 1)*g_decArgo_tempDef;
idNoDef = find(a_tempCounts ~= g_decArgo_tempCountsDef);
o_tempValues(idNoDef) = twos_complement_dec_argo(o_tempValues(idNoDef), 16)/1000;

return
