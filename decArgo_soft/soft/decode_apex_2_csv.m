% ------------------------------------------------------------------------------
% Decode APEX data to a CSV file.
%
% SYNTAX :
%   decode_apex_2_csv or decode_apex_2_csv(6900189, 7900118)
%
% INPUT PARAMETERS :
%   varargin : WMO number of APEX floats to be decoded
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   07/10/2015 - RNU - creation
% ------------------------------------------------------------------------------
function decode_apex_2_csv(varargin)

% default values initialization
init_default_values;

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

g_decArgo_realtimeFlag = 0;
g_decArgo_delayedModeFlag = 0;

% configuration values initialization
init_config_values([]);

% measurement codes initialization
init_measurement_codes;

% output CSV file Id
global g_decArgo_outputCsvFileId;

% configuration values
global g_decArgo_floatListFileName;
global g_decArgo_dirOutputLogFile;
global g_decArgo_dirOutputCsvFile;

global g_decArgo_generateNcTraj31;
global g_decArgo_generateNcTraj32;
global g_decArgo_generateNcMultiProf;
global g_decArgo_generateNcMonoProf;
global g_decArgo_generateNcTech;
global g_decArgo_generateNcMeta;

global g_decArgo_processRemainingBuffers;
g_decArgo_processRemainingBuffers = 1;


% create list of floats to be decoded
if (nargin == 0)
   % float list is given in configuration file
   if ~(exist(g_decArgo_floatListFileName, 'file') == 2)
      fprintf('ERROR: Float file list not found: %s\n', g_decArgo_floatListFileName);
      return
   end
   
   fprintf('List of processed floats: %s\n', g_decArgo_floatListFileName);
   floatList = load(g_decArgo_floatListFileName);
else
   % floats are given in varargin
   floatList = cell2mat(varargin);
end

% log file creation
if (nargin == 0)
   [pathstr, name, ext] = fileparts(g_decArgo_floatListFileName);
   name = ['_' name];
else
   name = sprintf('_%d', floatList);
end

logFileName = [g_decArgo_dirOutputLogFile '/decode_apex_2_csv' name '_' datestr(now, 'yyyymmddTHHMMSS') '.log'];
diary(logFileName);

% output CSV file creation
outputFileName = [g_decArgo_dirOutputCsvFile '/apex_decoded_data' name '_' datestr(now, 'yyyymmddTHHMMSS') '.csv'];
fidOut = fopen(outputFileName, 'wt');
if (fidOut == -1)
   fprintf('ERROR: Unable to create CSV output file: %s\n', outputFileName);
   return
end
g_decArgo_outputCsvFileId = fidOut;
g_decArgo_generateNcTraj31 = 0;
g_decArgo_generateNcTraj32 = 0;
g_decArgo_generateNcMultiProf = 0;
g_decArgo_generateNcMonoProf = 0;
g_decArgo_generateNcTech = 0;
g_decArgo_generateNcMeta = 0;

% decode the floats of the list
decode_apex(floatList);

fclose(g_decArgo_outputCsvFileId);

diary off;

return
