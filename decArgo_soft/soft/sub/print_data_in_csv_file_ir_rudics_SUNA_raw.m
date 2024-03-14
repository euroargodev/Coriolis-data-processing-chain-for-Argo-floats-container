% ------------------------------------------------------------------------------
% Print raw SUNA sensor data in output CSV file.
%
% SYNTAX :
%  print_data_in_csv_file_ir_rudics_SUNA_raw( ...
%    a_decoderId, a_cycleNum, a_profNum, a_phaseNum, ...
%    a_dataSUNARaw)
%
% INPUT PARAMETERS :
%   a_decoderId   : float decoder Id
%   a_cycleNum    : cycle number of the packet
%   a_profNum     : profile number of the packet
%   a_phaseNum    : phase number of the packet
%   a_dataSUNARaw : raw SUNA data
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/11/2013 - RNU - creation
% ------------------------------------------------------------------------------
function print_data_in_csv_file_ir_rudics_SUNA_raw( ...
   a_decoderId, a_cycleNum, a_profNum, a_phaseNum, ...
   a_dataSUNARaw)

% current float WMO number
global g_decArgo_floatNum;

% output CSV file Id
global g_decArgo_outputCsvFileId;

% global default values
global g_decArgo_dateDef;

% unpack the input data
a_dataSUNARawDate = a_dataSUNARaw{1};
a_dataSUNARawDateTrans = a_dataSUNARaw{2};
a_dataSUNARawPres = a_dataSUNARaw{3};
a_dataSUNARawConcNitra = a_dataSUNARaw{4};

% select the data (according to cycleNum, profNum and phaseNum)
idDataRaw = find((a_dataSUNARawDate(:, 1) == a_cycleNum) & ...
   (a_dataSUNARawDate(:, 2) == a_profNum) & ...
   (a_dataSUNARawDate(:, 3) == a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; SUNA raw; Date; PRES (dbar); MOLAR_NITRATE (micromole/l)\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

data = [];
for idL = 1:length(idDataRaw)
   data = [data; ...
      a_dataSUNARawDate(idDataRaw(idL), 4:end)' ...
      a_dataSUNARawDateTrans(idDataRaw(idL), 4:end)' ...
      a_dataSUNARawPres(idDataRaw(idL), 4:end)' ...
      a_dataSUNARawConcNitra(idDataRaw(idL), 4:end)'];
end
idDel = find((data(:, 3) == 0) & (data(:, 4) == 0));
data(idDel, :) = [];

data(:, 3) = sensor_2_value_for_pressure_ir_rudics_sbd2(data(:, 3), a_decoderId);
data(:, 4) = sensor_2_value_for_concNitra_ir_rudics(data(:, 4));

for idL = 1:size(data, 1)
   if (data(idL, 1) ~= g_decArgo_dateDef)
      if (data(idL, 2) == 1)
         date = [julian_2_gregorian_dec_argo(data(idL, 1)) ' (T)'];
      else
         date = [julian_2_gregorian_dec_argo(data(idL, 1)) ' (C)'];
      end
      fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; SUNA raw; %s; %.1f; %g\n', ...
         g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
         date, data(idL, 3:4));
   else
      fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; SUNA raw; ; %.1f; %g\n', ...
         g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
         data(idL, 3:4));
   end
end

return
