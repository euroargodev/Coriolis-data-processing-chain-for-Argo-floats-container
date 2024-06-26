% ------------------------------------------------------------------------------
% Convert sensor counts to physical values for temperature.
%
% SYNTAX :
%  [o_value] = sensor_2_value_for_apex_apf11_temperature(a_sensorValue)
%
% INPUT PARAMETERS :
%   a_sensorValue : temperature counts
%
% OUTPUT PARAMETERS :
%   o_value : temperature values
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/10/2018 - RNU - creation
% ------------------------------------------------------------------------------
function [o_value] = sensor_2_value_for_apex_apf11_temperature(a_sensorValue)

if (a_sensorValue > 32767)
   o_value = (65535 - a_sensorValue)*(-1);
else
   o_value = a_sensorValue;
end
o_value = o_value/1000;

return
