% ------------------------------------------------------------------------------
% Print float programmed technical data in output CSV file.
%
% SYNTAX :
%  print_float_prog_tech_data_in_csv_file_ir_rudics( ...
%    a_decoderId, ...
%    a_cyProfPhaseList, a_cyProfPhaseIndexList, ...
%    a_floatProgTech)
%
% INPUT PARAMETERS :
%   a_decoderId            : float decoder Id
%   a_cyProfPhaseList      : information (cycle #, prof #, phase #) on each
%                            received packet
%   a_cyProfPhaseIndexList : index list of the data to print
%   a_floatProgTech        : float programmed technical data
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
function print_float_prog_tech_data_in_csv_file_ir_rudics( ...
   a_decoderId, ...
   a_cyProfPhaseList, a_cyProfPhaseIndexList, ...
   a_floatProgTech)

% current float WMO number
global g_decArgo_floatNum;

% current cycle number
global g_decArgo_cycleNum;

% packet type 254
dataCyProfPhaseList = a_cyProfPhaseList(a_cyProfPhaseIndexList, :);
cycleList = unique(dataCyProfPhaseList(:, 3));

if (~isempty(cycleList))
   if (length(cycleList) > 1)
      fprintf('WARNING: Float #%d Cycle #%d: more than one cycle data in the float programmed technical data SBD files\n', ...
         g_decArgo_floatNum, g_decArgo_cycleNum);
   else
      if (~ismember(a_decoderId, [111, 113, 114, 115, 116]))
         if (cycleList(1) ~= g_decArgo_cycleNum)
            fprintf('DEC_WARNING: Float #%d Cycle #%d: data cycle number (%d) differs from float programmed technical data SBD file name cycle number (%d)\n', ...
               g_decArgo_floatNum, g_decArgo_cycleNum, ...
               cycleList(1), g_decArgo_cycleNum);
         end
      end
   end
end

% print the float programmed technical data
cycleProfList = unique(dataCyProfPhaseList(:, 3:4), 'rows');
for idCyPr = 1:size(cycleProfList, 1)
   cycleNum = cycleProfList(idCyPr, 1);
   profNum = cycleProfList(idCyPr, 2);
   
   idPack = find((dataCyProfPhaseList(:, 3) == cycleNum) & ...
      (dataCyProfPhaseList(:, 4) == profNum));
   
   if (~isempty(idPack))
      % index list of the data
      typeDataList = find((a_cyProfPhaseList(:, 1) == 254));
      dataIndexList = [];
      for id = 1:length(idPack)
         dataIndexList = [dataIndexList; find(typeDataList == a_cyProfPhaseIndexList(idPack(id)))];
      end
      if (~isempty(dataIndexList))
         for idP = 1:length(dataIndexList)
            print_float_prog_tech_data_in_csv_file_ir_rudics_one( ...
               a_decoderId, cycleNum, profNum, dataIndexList(idP), ...
               a_floatProgTech);
         end
      end
   end
end

return
