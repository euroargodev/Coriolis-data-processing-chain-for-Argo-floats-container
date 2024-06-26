% ------------------------------------------------------------------------------
% Generate meta data for Remocean floats (SENSOR, PARAMETER and CALIBRATION
% information) and miscellaneous configuration parameters.
%
% SYNTAX :
%  generate_csv_meta_remocean or generate_csv_meta_remocean(varargin)
%
% INPUT PARAMETERS :
%   varargin : WMO number of floats to process
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   06/02/2014 - RNU - creation
% ------------------------------------------------------------------------------
function generate_csv_meta_remocean(varargin)

% to switch between Coriolis and JPR configurations
CORIOLIS_CONFIGURATION_FLAG = 0;

if (CORIOLIS_CONFIGURATION_FLAG)

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % CORIOLIS CONFIGURATION - START

   % calibration coefficients decoded from data
   calibFileName = '/home/coriolis_dev/gestion/exploitation/argo/flotteurs-coriolis/Bgc-Argo/CTS4/DataFromFloatToMeta/CalibCoef/calib_coef.txt';

   % show mode state decoded from data
   showModeFileName = '/home/coriolis_dev/gestion/exploitation/argo/flotteurs-coriolis/Bgc-Argo/CTS4/DataFromFloatToMeta/ShowMode/show_mode.txt';

   % SUNA output pixel numbers decoded from data
   outputPixelFileName = '/home/coriolis_dev/gestion/exploitation/argo/flotteurs-coriolis/Bgc-Argo/CTS4/DataFromFloatToMeta/SunaOutputPixel/output_pixel.txt';

   % list of sensors mounted on floats
   SENSOR_LIST_FILE_NAME = '/home/coriolis_exp/binlx/co04/co0414/co041404/decArgo_config_floats/argoFloatInfo/float_sensor_list.txt';

   % meta-data file exported from Coriolis data base
   dataBaseFileName = '/home/idmtmp7/vincent/matlab/DB_export/new_rem_meta.txt';

   % directory to store the log and csv files
   DIR_LOG_CSV_FILE = '/home/coriolis_exp/binlx/co04/co0414/co041402/data/csv';

   % CORIOLIS CONFIGURATION - END
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % JPR CONFIGURATION - START

   % calibration coefficients decoded from data
   calibFileName = 'C:\Users\jprannou\_RNU\DecPrv_info\PROVOR_CTS4\DataFromFloatToMeta\CalibCoef\calib_coef.txt';
   calibFileName = 'C:\Users\jprannou\OneDrive - Capgemini\Desktop\SOS_VB_2\calib_coef.txt';

   % show mode state decoded from data
   showModeFileName = 'C:\Users\jprannou\_RNU\DecPrv_info\PROVOR_CTS4\DataFromFloatToMeta\ShowMode\show_mode.txt';

   % SUNA output pixel numbers decoded from data
   outputPixelFileName = 'C:\Users\jprannou\_RNU\DecPrv_info\PROVOR_CTS4\DataFromFloatToMeta\SunaOutputPixel\output_pixel.txt';
   outputPixelFileName = 'C:\Users\jprannou\OneDrive - Capgemini\Desktop\SOS_VB_2\output_pixel.txt';

   % list of sensors mounted on floats
   SENSOR_LIST_FILE_NAME = 'C:\Users\jprannou\_DATA\IN\decArgo_config_floats\argoFloatInfo\float_sensor_list.txt';
   SENSOR_LIST_FILE_NAME = 'C:\Users\jprannou\OneDrive - Capgemini\Desktop\SOS_VB_2\float_sensor_list.txt';

   % meta-data file exported from Coriolis data base
   dataBaseFileName = 'C:\Users\jprannou\_RNU\DecPrv_info\_configParamNames\DB_Export\db_export_CTS4_5906868.txt';
   dataBaseFileName = 'C:\Users\jprannou\OneDrive - Capgemini\Desktop\SOS_VB_2\db_export.txt';

   % directory to store the log and csv files
   DIR_LOG_CSV_FILE = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\';

   % JPR CONFIGURATION - END
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

% default values initialization
init_default_values;


% configuration parameters
configVar = [];
configVar{end+1} = 'FLOAT_LIST_FILE_NAME';
configVar{end+1} = 'FLOAT_INFORMATION_FILE_NAME';

% get configuration parameters
g_decArgo_realtimeFlag = 0;
g_decArgo_delayedModeFlag = 0;
[configVal, unusedVarargin, inputError] = get_config_dec_argo(configVar, []);
floatListFileName = configVal{1};
floatInformationFileName = configVal{2};

% floatListFileName = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\SOS_VB_20170620\new_rem.txt';
% floatInformationFileName = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\SOS_VB_20170620\_provor_floats_information_co.txt';

if (nargin == 0)
   
   % floats to process come from floatListFileName
   if ~(exist(floatListFileName, 'file') == 2)
      fprintf('ERROR: File not found: %s\n', floatListFileName);
      return
   end
   
   fprintf('Floats from list: %s\n', floatListFileName);
   floatList = load(floatListFileName);
else
   % floats to process come from input parameters
   floatList = cell2mat(varargin);
end

% create and start log file recording
if (nargin == 0)
   [pathstr, name, ext] = fileparts(floatListFileName);
   name = ['_' name];
else
   name = sprintf('_%d', floatList);
end

logFile = [DIR_LOG_CSV_FILE '/' 'generate_csv_meta_remocean' name '_' datestr(now, 'yyyymmddTHHMMSS') '.log'];
diary(logFile);
tic;

% create the CSV output file
outputFileName = [DIR_LOG_CSV_FILE '/' 'generate_csv_meta_remocean' name '_' datestr(now, 'yyyymmddTHHMMSS') '.csv'];
fidOut = fopen(outputFileName, 'wt');
if (fidOut == -1)
   return
end
header = ['PLATFORM_CODE;TECH_PARAMETER_ID;DIM_LEVEL;CORIOLIS_TECH_METADATA.PARAMETER_VALUE;TECH_PARAMETER_CODE'];
fprintf(fidOut, '%s\n', header);

% get floats information
[listWmoNum, listDecId, listArgosId, listFrameLen, ...
   listCycleTime, listDriftSamplingPeriod, listDelay, ...
   listLaunchDate, listLaunchLon, listLaunchLat, ...
   listRefDay, listEndDate, listDmFlag] = get_floats_info(floatInformationFileName);

% read calib file
fId = fopen(calibFileName, 'r');
if (fId == -1)
   fprintf('ERROR: Unable to open file: %s\n', calibFileName);
   return
end
calibData = textscan(fId, '%s');
calibData = calibData{:};
fclose(fId);

calibData = reshape(calibData, 4, size(calibData, 1)/4)';

% read show mode file
fId = fopen(showModeFileName, 'r');
if (fId == -1)
   fprintf('ERROR: Unable to open file: %s\n', showModeFileName);
   return
end
showModeData = textscan(fId, '%s');
showModeData = showModeData{:};
fclose(fId);

showModeData = reshape(showModeData, 3, size(showModeData, 1)/3)';

% read output pixel file
fId = fopen(outputPixelFileName, 'r');
if (fId == -1)
   fprintf('ERROR: Unable to open file: %s\n', outputPixelFileName);
   return
end
outputPixelData = textscan(fId, '%s');
outputPixelData = outputPixelData{:};
fclose(fId);

outputPixelData = reshape(outputPixelData, 3, size(outputPixelData, 1)/3)';

% get sensor list
[wmoSensorList, nameSensorList] = get_sensor_list(SENSOR_LIST_FILE_NAME);

% read meta file
fprintf('Processing file: %s\n', dataBaseFileName);
fId = fopen(dataBaseFileName, 'r');
if (fId == -1)
   fprintf('ERROR: Unable to open file: %s\n', dataBaseFileName);
   return
end
metaFileContents = textscan(fId, '%s', 'delimiter', '\t');
metaFileContents = metaFileContents{:};
fclose(fId);

metaFileContents = regexprep(metaFileContents, '"', '');

metaData = reshape(metaFileContents, 5, size(metaFileContents, 1)/5)';

metaWmoList = metaData(:, 1);
% for id = 1:length(metaWmoList)
%    if (isempty(str2num(metaWmoList{id})))
%       fprintf('%s is not a valid WMO number\n', metaWmoList{id});
%       return
%    end
% end
S = sprintf('%s*', metaWmoList{:});
metaWmoList = sscanf(S, '%f*');

% process the floats
nbFloats = length(floatList);
for idFloat = 1:nbFloats
   
   floatNum = floatList(idFloat);
   fprintf('%03d/%03d %d\n', idFloat, nbFloats, floatNum);
   
   % get the list of sensors for this float
   idSensor = find(wmoSensorList == floatNum);
   if (isempty(idSensor))
      fprintf('ERROR: Unknown sensor list for float #%d - nothing done for this float (PLEASE UPDATE "%s" file)\n', ...
         floatNum, SENSOR_LIST_FILE_NAME);
      continue
   end
   sensorList = nameSensorList(idSensor);
   if (length(sensorList) ~= length(unique(sensorList)))
      fprintf('ERROR: Duplicated sensors for float #%d - nothing done for this float (PLEASE CHECK "%s" file)\n', ...
         floatNum, SENSOR_LIST_FILE_NAME);
      continue
   end
   
   % find decoder Id
   idF = find(listWmoNum == floatNum, 1);
   if (isempty(idF))
      fprintf('ERROR: No information on float #%d - nothing done for this float\n', floatNum);
      continue
   end
   floatDecId = listDecId(idF);
   
   % retrieve float version
   [floatVersion] = get_float_version(floatNum, metaWmoList, metaData);
   
   [platformFamily] = get_platform_family_db(floatNum, floatDecId, metaWmoList, metaData);
   fprintf(fidOut, '%d;2081;1;%s;PLATFORM_FAMILY;%s\n', floatNum, platformFamily, floatVersion);
   
   [platformType] = get_platform_type_db(floatNum, floatDecId, metaWmoList, metaData);
   fprintf(fidOut, '%d;2209;1;%s;PLATFORM_TYPE;%s\n', floatNum, platformType, floatVersion);
   
   [wmoInstType] = get_wmo_inst_type_db(floatNum, floatDecId, metaWmoList, metaData);
   fprintf(fidOut, '%d;13;1;%s;PR_PROBE_CODE;%s\n', floatNum, wmoInstType, floatVersion);
   
   % sensor information
   for idSensor = 1:length(sensorList)
      [sensorName, sensorDimLevel, sensorMaker, sensorModel] = get_sensor_info(sensorList{idSensor}, floatDecId, floatNum, metaWmoList, metaData);
      for idS = 1:length(sensorName)
         fprintf(fidOut, '%d;408;%d;%s;SENSOR;%s\n', floatNum, sensorDimLevel(idS), sensorName{idS}, floatVersion);
         fprintf(fidOut, '%d;409;%d;%s;SENSOR_MAKER;%s\n', floatNum, sensorDimLevel(idS), sensorMaker{idS}, floatVersion);
         fprintf(fidOut, '%d;410;%d;%s;SENSOR_MODEL;%s\n', floatNum, sensorDimLevel(idS), sensorModel{idS}, floatVersion);
         [sensorSn] = get_sensor_sn(sensorName{idS}, floatNum, metaWmoList, metaData);
         if (~isempty(sensorSn))
            fprintf(fidOut, '%d;411;%d;%s;SENSOR_SERIAL_NO;%s\n', floatNum, sensorDimLevel(idS), sensorSn, floatVersion);
         end
      end
   end
   
   % parameter information
   for idSensor = 1:length(sensorList)
      sunaApfFlag = 1;
      [paramName, paramDimLevel, paramSensor, paramUnits, paramAccuracy, paramResolution] = ...
         get_sensor_parameter_info(sensorList{idSensor}, floatNum, floatDecId, sunaApfFlag, metaWmoList, metaData);
      for idP = 1:length(paramName)
         fprintf(fidOut, '%d;415;%d;%s;PARAMETER;%s\n', floatNum, paramDimLevel(idP), paramName{idP}, floatVersion);
         fprintf(fidOut, '%d;2100;%d;%s;PARAMETER_SENSOR;%s\n', floatNum, paramDimLevel(idP), paramSensor{idP}, floatVersion);
         fprintf(fidOut, '%d;2206;%d;%s;PARAMETER_UNITS;%s\n', floatNum, paramDimLevel(idP), paramUnits{idP}, floatVersion);
         fprintf(fidOut, '%d;2207;%d;%s;PARAMETER_ACCURACY;%s\n', floatNum, paramDimLevel(idP), paramAccuracy{idP}, floatVersion);
         fprintf(fidOut, '%d;2208;%d;%s;PARAMETER_RESOLUTION;%s\n', floatNum, paramDimLevel(idP), paramResolution{idP}, floatVersion);
      end
   end
   
   % vector board information
   [vectorShowMode, sensorShowMode] = get_show_mode(showModeData, floatNum);
   if (~isempty(vectorShowMode))
      fprintf(fidOut, '%d;2202;1;%d;VECTOR_BOARD_SHOW_MODE_STATE;%s\n', floatNum, vectorShowMode, floatVersion);
   end
   if (~isempty(sensorShowMode))
      fprintf(fidOut, '%d;2203;1;%d;SENSOR_BOARD_SHOW_MODE_STATE;%s\n', floatNum, sensorShowMode, floatVersion);
   end
   
   % SUNA output pixel numbers information
   if (~isempty(find(strcmp(sensorList, 'SUNA') == 1, 1)))
      [pixelBegin, pixelEnd] = get_output_pixel(outputPixelData, floatNum);
      if (~isempty(pixelBegin))
         fprintf(fidOut, '%d;2204;1;%d;SUNA_APF_OUTPUT_PIXEL_BEGIN;%s\n', floatNum, pixelBegin, floatVersion);
      end
      if (~isempty(pixelEnd))
         fprintf(fidOut, '%d;2205;1;%d;SUNA_APF_OUTPUT_PIXEL_END;%s\n', floatNum, pixelEnd, floatVersion);
      end
   end
   
   % sensor misc information
   [techParId, techParDimLev, techParCode, techParValue] = ...
      get_sensor_misc_info(sensorList, floatNum, floatDecId, metaWmoList, metaData);
   if (~isempty(techParId))
      for idT = 1:length(techParId)
         fprintf(fidOut, '%d;%s;%s;%s;%s;%s\n', ...
            floatNum, techParId{idT}, techParDimLev{idT}, techParValue{idT}, techParCode{idT}, floatVersion);
      end
   end
   
end

fclose(fidOut);

ellapsedTime = toc;
fprintf('done (Elapsed time is %.1f seconds)\n', ellapsedTime);

diary off;

return

% ------------------------------------------------------------------------------
function [o_sensorName, o_sensorDimLevel, o_sensorMaker, o_sensorModel] = get_sensor_info(a_inputSensorName, a_decId, a_floatNum, a_metaWmoList, a_metaData)

o_sensorName = [];
o_sensorDimLevel = [];
o_sensorMaker = [];
o_sensorModel = [];

switch a_inputSensorName
   case  'CTD'
      o_sensorName = [{'CTD_PRES'} {'CTD_TEMP'} {'CTD_CNDC'}];
      o_sensorDimLevel = [1 2 3];
      o_sensorMaker = [{'SBE'} {'SBE'} {'SBE'}];
      o_sensorModel = [{'SBE41CP'} {'SBE41CP'} {'SBE41CP'}];
      for idS = 1:length(o_sensorName)
         [sensorModel] = get_sensor_model(o_sensorName{idS}, a_floatNum, a_metaWmoList, a_metaData);
         if (~isempty(sensorModel))
            if (~strcmp(sensorModel, o_sensorModel{idS}))
               fprintf('INFO: DB SENSOR_MODEL (''%s'') not replaced by default one (''%s'')\n', ...
                  sensorModel, o_sensorModel{idS});
               o_sensorModel(idS) = {sensorModel};
            end
         end
      end
      for idS = 1:length(o_sensorMaker)
         [sensorMaker] = get_sensor_maker(o_sensorName{idS}, a_floatNum, a_metaWmoList, a_metaData);
         if (~isempty(sensorMaker))
            if (~strcmp(sensorMaker, o_sensorMaker{idS}))
               fprintf('INFO: DB SENSOR_Maker (''%s'') not replaced by default one (''%s'')\n', ...
                  sensorMaker, o_sensorMaker{idS});
               o_sensorMaker(idS) = {sensorMaker};
            end
         end
      end

   case 'OPTODE'
      o_sensorName = {'OPTODE_DOXY'};
      o_sensorDimLevel = [101];
      o_sensorMaker = {'AANDERAA'};
      [sensorModel] = get_sensor_model('OPTODE_DOXY', a_floatNum, a_metaWmoList, a_metaData);
      if (~isempty(sensorModel))
         o_sensorModel = {sensorModel};
      end
      
   case 'OCR'
      o_sensorName = [{'RADIOMETER_DOWN_IRR380'} {'RADIOMETER_DOWN_IRR412'} {'RADIOMETER_DOWN_IRR490'} {'RADIOMETER_PAR'}];
      o_sensorDimLevel = [201 202 203 204];
      o_sensorMaker = [{'SATLANTIC'} {'SATLANTIC'} {'SATLANTIC'} {'SATLANTIC'}];
      o_sensorModel = [{'SATLANTIC_OCR504_ICSW'} {'SATLANTIC_OCR504_ICSW'} {'SATLANTIC_OCR504_ICSW'} {'SATLANTIC_OCR504_ICSW'}];      
      
   case 'ECO3'
      
      switch a_decId
         case {105, 106, 107, 110, 111, 113, 114, 116}
            o_sensorName = [{'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} {'FLUOROMETER_CDOM'}];
            o_sensorDimLevel = [301 302 303];
            o_sensorMaker = [{'WETLABS'} {'WETLABS'} {'WETLABS'}];
            o_sensorModel = [{'ECO_FLBBCD'} {'ECO_FLBBCD'} {'ECO_FLBBCD'}];
            
         case {108, 109, 115}
            o_sensorName = [{'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} {'BACKSCATTERINGMETER_BBP532'}];
            o_sensorDimLevel = [301 302 303];
            o_sensorMaker = [{'WETLABS'} {'WETLABS'} {'WETLABS'}];
            o_sensorModel = [{'ECO_FLBB2'} {'ECO_FLBB2'} {'ECO_FLBB2'}];
            
         otherwise
            fprintf('ERROR: No sensor info for ECO3 sensor for decId #%d\n', a_decId);
      end
      
   case 'CROVER'
      o_sensorName = {'TRANSMISSOMETER_CP660'};
      o_sensorDimLevel = [501];
      o_sensorMaker = {'WETLABS'};
      o_sensorModel = {'C_ROVER'};
      
   case 'SUNA'
      o_sensorName = {'SPECTROPHOTOMETER_NITRATE'};
      o_sensorDimLevel = [601];
      o_sensorMaker = {'SATLANTIC'};
      o_sensorModel = {'SUNA_V2'};
      
   case {'FLBB', 'ECO2'}
      o_sensorName = [{'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'}];
      o_sensorDimLevel = [401 402];
      o_sensorMaker = [{'WETLABS'} {'WETLABS'}];
      o_sensorModel = [{'ECO_FLBB'} {'ECO_FLBB'}];
      
   case 'FLNTU'
      o_sensorName = [{'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_TURBIDITY'}];
      o_sensorDimLevel = [403 404];
      o_sensorMaker = [{'WETLABS'} {'WETLABS'}];
      o_sensorModel = [{'ECO_FLNTU'} {'ECO_FLNTU'}];
      
   case 'CYCLOPS'
      o_sensorName = [{'AUX_FLUOROMETER_CHLA2'}];
      o_sensorDimLevel = [2001];
      o_sensorMaker = [{'TURNER_DESIGN'}];
      o_sensorModel = [{'CYCLOPS-7_FLUOROMETER'}];
      
   case 'SEAPOINT'
      o_sensorName = [{'AUX_BACKSCATTERINGMETER_TURBIDITY2'}];
      o_sensorDimLevel = [2101];
      o_sensorMaker = [{'SEAPOINT'}];
      o_sensorModel = [{'SEAPOINT_TURBIDITY_METER'}];

   case 'TRANSISTOR_PH'
      o_sensorName = {'TRANSISTOR_PH'};
      o_sensorDimLevel = [701];
      o_sensorMaker = {'SBE'};
      o_sensorModel = {'SEAFET'};

   otherwise
      fprintf('ERROR: No sensor name for %s\n', a_inputSensorName);
end

return

% ------------------------------------------------------------------------------
function [o_techParId, o_techParDimLev, o_techParCode, o_techParValue] = ...
   get_sensor_misc_info(a_sensorList, a_floatNum, a_decId, a_metaWmoList, a_metaData)

o_techParId = [];
o_techParDimLev = [];
o_techParCode = [];
o_techParValue = [];

for idSensor = 1:length(a_sensorList)
   
   techParId = [];
   techParDimLev = [];
   techParCode = [];
   techParValue = [];
   
   switch a_sensorList{idSensor}
      case  'CTD'
         
      case 'OPTODE'
         codeList = [ ...
            {'OPTODE_VERTICAL_PRES_OFFSET'} ...
            ];
         ifEmptyList = [ ...
            {'-0.06'} ...
            ];
         techParIdList = [ ...
            {'2199'} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
         
      case 'OCR'
         codeList = [ ...
            {'OCR_DOWN_IRR_BANDWIDTH'}; ...
            {'OCR_DOWN_IRR_WAVELENGTH'}; ...
            {'OCR_VERTICAL_PRES_OFFSET'} ...
            ];
         ifEmptyList = [ ...
            {[{'10'}; {'10'}; {'10'}]}; ...
            {[{'380'}; {'412'}; {'490'}]}; ...
            {'-0.08'} ...
            ];
         techParIdList = [ ...
            {'2196'}; ...
            {'2197'}; ...
            {'2198'} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
         
      case 'ECO3'
         switch a_decId
            case {105, 106, 107, 110, 111, 113, 114, 116}
               codeList = [ ...
                  {'ECO_BETA_ANGLE'}; ...
                  {'ECO_BETA_BANDWIDTH'}; ...
                  {'ECO_BETA_WAVELENGTH'}; ...
                  {'ECO_CDOM_FLUO_EMIS_BANDWIDTH'}; ...
                  {'ECO_CDOM_FLUO_EMIS_WAVELENGTH'}; ...
                  {'ECO_CDOM_FLUO_EXCIT_BANDWIDTH'}; ...
                  {'ECO_CDOM_FLUO_EXCIT_WAVELENGTH'}; ...
                  {'ECO_CHLA_FLUO_EMIS_BANDWIDTH'}; ...
                  {'ECO_CHLA_FLUO_EMIS_WAVELENGTH'}; ...
                  {'ECO_CHLA_FLUO_EXCIT_BANDWIDTH'}; ...
                  {'ECO_CHLA_FLUO_EXCIT_WAVELENGTH'}; ...
                  {'ECO_VERTICAL_PRES_OFFSET'} ...
                  ];
               ifEmptyList = [ ...
                  {'124'}; ...
                  {''}; ...
                  {'700'}; ...
                  {''}; ...
                  {'460'}; ...
                  {''}; ...
                  {'370'}; ...
                  {''}; ...
                  {'695'}; ...
                  {''}; ...
                  {'470'}; ...
                  {'0.1'} ...
                  ];
               techParIdList = [ ...
                  {'2184'}; ...
                  {'2185'}; ...
                  {'2186'}; ...
                  {'2187'}; ...
                  {'2188'}; ...
                  {'2189'}; ...
                  {'2190'}; ...
                  {'2191'}; ...
                  {'2192'}; ...
                  {'2193'}; ...
                  {'2194'}; ...
                  {'2195'} ...
                  ];
               [techParId, techParDimLev, techParCode, techParValue] = ...
                  get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
            case {108, 109, 115}
               codeList = [ ...
                  {'ECO_BETA_ANGLE'}; ...
                  {'ECO_BETA_BANDWIDTH'}; ...
                  {'ECO_BETA_WAVELENGTH'}; ...
                  {'ECO_CHLA_FLUO_EMIS_BANDWIDTH'}; ...
                  {'ECO_CHLA_FLUO_EMIS_WAVELENGTH'}; ...
                  {'ECO_CHLA_FLUO_EXCIT_BANDWIDTH'}; ...
                  {'ECO_CHLA_FLUO_EXCIT_WAVELENGTH'}; ...
                  {'ECO_VERTICAL_PRES_OFFSET'} ...
                  ];
               ifEmptyList = [ ...
                  {'124'}; ...
                  {''}; ...
                  {'700'}; ...
                  {''}; ...
                  {'695'}; ...
                  {''}; ...
                  {'470'}; ...
                  {'0.1'} ...
                  ];
               techParIdList = [ ...
                  {'2184'}; ...
                  {'2185'}; ...
                  {'2186'}; ...
                  {'2191'}; ...
                  {'2192'}; ...
                  {'2193'}; ...
                  {'2194'}; ...
                  {'2195'} ...
                  ];
               [techParId, techParDimLev, techParCode, techParValue] = ...
                  get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
            otherwise
               fprintf('ERROR: No sensor misc info for ECO3 sensor for decId #%d\n', a_decId);
         end
         
      case 'CROVER'
         codeList = [ ...
            {'CROVER_IN_PUMPED_STREAM'}; ...
            {'CROVER_BEAM_ATT_WAVELENGTH'}; ...
            {'CROVER_VERTICAL_PRES_OFFSET'} ...
            ];
         ifEmptyList = [ ...
            {'0'}; ...
            {'660'}; ...
            {''} ...
            ];
         techParIdList = [ ...
            {'2181'}; ...
            {'2182'}; ...
            {''} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
         
      case 'SUNA'
         codeList = [ ...
            {'SUNA_VERTICAL_PRES_OFFSET'}; ...
            {'SUNA_WITH_SCOOP'} ...
            ];
         ifEmptyList = [ ...
            {'1.5'}; ...
            {'0'} ...
            ];
         techParIdList = [ ...
            {'2200'}; ...
            {'2201'} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
         
      case {'FLBB', 'ECO2'}
         codeList = [ ...
            {'FLBB_BETA_ANGLE'}; ...
            {'FLBB_BETA_BANDWIDTH'}; ...
            {'FLBB_BETA_WAVELENGTH'}; ...
            {'FLBB_CHLA_FLUO_EMIS_BANDWIDTH'}; ...
            {'FLBB_CHLA_FLUO_EMIS_WAVELENGTH'}; ...
            {'FLBB_CHLA_FLUO_EXCIT_BANDWIDTH'}; ...
            {'FLBB_CHLA_FLUO_EXCIT_WAVELENGTH'}; ...
            {'FLBB_VERTICAL_PRES_OFFSET'} ...
            ];
         ifEmptyList = [ ...
            {'142'}; ...
            {''}; ...
            {'700'}; ...
            {''}; ...
            {'695'}; ...
            {''}; ...
            {'470'}; ...
            {''} ...
            ];
         techParIdList = [ ...
            {'2247'}; ...
            {'2248'}; ...
            {'2249'}; ...
            {'2250'}; ...
            {'2251'}; ...
            {'2252'}; ...
            {'2253'}; ...
            {'2254'} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
         
      case 'FLNTU'
         codeList = [ ...
            {'FLNTU_CHLA_FLUO_EMIS_BANDWIDTH'}; ...
            {'FLNTU_CHLA_FLUO_EMIS_WAVELENGTH'}; ...
            {'FLNTU_CHLA_FLUO_EXCIT_BANDWIDTH'}; ...
            {'FLNTU_CHLA_FLUO_EXCIT_WAVELENGTH'}; ...
            {'FLNTU_VERTICAL_PRES_OFFSET'}; ...
            {'FLNTU_TURBIDITY_WAVELENGTH'} ...
            ];
         ifEmptyList = [ ...
            {''}; ...
            {'695'}; ...
            {''}; ...
            {'470'}; ...
            {''}; ...
            {'700'} ...
            ];
         techParIdList = [ ...
            {''}; ...
            {'2306'}; ...
            {''}; ...
            {'2305'}; ...
            {''}; ...
            {'2309'} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);         
         
      case 'CYCLOPS'
         codeList = [ ...
            {'CYC_CHLA_FLUO_EMIS_BANDWIDTH'}; ...
            {'CYC_CHLA_FLUO_EMIS_WAVELENGTH'}; ...
            {'CYC_CHLA_FLUO_EXCIT_BANDWIDTH'}; ...
            {'CYC_CHLA_FLUO_EXCIT_WAVELENGTH'}; ...
            {'CYC_VERTICAL_PRES_OFFSET'} ...
            ];
         ifEmptyList = [ ...
            {'95'}; ...
            {'695'}; ...
            {''}; ...
            {'460'}; ...
            {''} ...
            ];
         techParIdList = [ ...
            {'2314'}; ...
            {'2312'}; ...
            {''}; ...
            {'2311'}; ...
            {''} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);         
         
      case 'SEAPOINT'
         codeList = [ ...
            {'STM_TURBIDITY_WAVELENGTH'}; ...
            {'STM_VERTICAL_PRES_OFFSET'} ...
            ];
         ifEmptyList = [ ...
            {'880'}; ...
            {''} ...
            ];
         techParIdList = [ ...
            {'2316'}; ...
            {''} ...
            ];
         [techParId, techParDimLev, techParCode, techParValue] = ...
            get_data(codeList, ifEmptyList, techParIdList, a_floatNum, a_metaWmoList, a_metaData);
         
      case 'TRANSISTOR_PH'
         % nothing yet
         
      otherwise
         fprintf('ERROR: No sensor misc information for %s\n', a_sensorList{idSensor});
   end
   
   if (~isempty(techParId))
      o_techParId = [o_techParId; techParId];
      o_techParDimLev = [o_techParDimLev; techParDimLev];
      o_techParCode = [o_techParCode; techParCode];
      o_techParValue = [o_techParValue; techParValue];
   end
end

return

% ------------------------------------------------------------------------------
function [o_techParId, o_techParDimLev, o_techParCode, o_techParValue] = ...
   get_data(a_codeList, a_ifEmptyList, a_techParIdList, a_floatNum, a_metaWmoList, a_metaData)

o_techParId = [];
o_techParDimLev = [];
o_techParCode = [];
o_techParValue = [];

idForWmo = find(a_metaWmoList == a_floatNum);

for idC = 1:length(a_codeList)
   
   idF1 = find(strcmp(a_metaData(idForWmo, 5), a_codeList{idC}));
   if (~isempty(idF1))
      o_techParId = [o_techParId; a_metaData(idForWmo(idF1), 2)];
      o_techParDimLev = [o_techParDimLev; a_metaData(idForWmo(idF1), 3)];
      o_techParCode = [o_techParCode; a_metaData(idForWmo(idF1), 5)];
      o_techParValue = [o_techParValue; a_metaData(idForWmo(idF1), 4)];
   elseif (~isempty(a_ifEmptyList{idC}))
      emptyList = a_ifEmptyList{idC};
      if (size(emptyList, 1) > 1)
         for id = 1:size(emptyList, 1)
            o_techParId = [o_techParId; a_techParIdList(idC)];
            o_techParDimLev = [o_techParDimLev; {num2str(id)}];
            o_techParCode = [o_techParCode; a_codeList(idC)];
            o_techParValue = [o_techParValue; emptyList(id)];
         end
      else
         o_techParId = [o_techParId; a_techParIdList(idC)];
         o_techParDimLev = [o_techParDimLev; {'1'}];
         o_techParCode = [o_techParCode; a_codeList(idC)];
         o_techParValue = [o_techParValue; a_ifEmptyList(idC)];
      end
      
      fprintf('INFO: Sensor info ''%s'' is missing for float #%d - value set to default\n', ...
         a_codeList{idC}, a_floatNum);
   end
end

return

% ------------------------------------------------------------------------------
function [o_sensorSn] = get_sensor_sn(a_sensorName, a_floatNum, a_metaWmoList, a_metaData)

o_sensorSn = [];

idForWmo = find(a_metaWmoList == a_floatNum);

idF1 = find(strcmp(a_metaData(idForWmo, 4), a_sensorName) & ...
   strcmp(a_metaData(idForWmo, 5), 'SENSOR'));
if (~isempty(idF1))
   dimLevel = a_metaData(idForWmo(idF1), 3);
   idF2 = find(strcmp(a_metaData(idForWmo, 3), dimLevel) & ...
      strcmp(a_metaData(idForWmo, 5), 'SENSOR_SERIAL_NO'));
   if (~isempty(idF2))
      o_sensorSn = a_metaData{idForWmo(idF2), 4};
   else
      fprintf('ERROR: Sensor serial number not found for sensor %s of float %d\n', ...
         a_sensorName, a_floatNum);
   end
else
   fprintf('ERROR: Sensor %s not found for float %d\n', ...
      a_sensorName, a_floatNum);
end

return

% ------------------------------------------------------------------------------
function [o_sensorModel] = get_sensor_model(a_sensorName, a_floatNum, a_metaWmoList, a_metaData)

o_sensorModel = [];

idForWmo = find(a_metaWmoList == a_floatNum);

idF1 = find(strcmp(a_metaData(idForWmo, 4), a_sensorName) & ...
   strcmp(a_metaData(idForWmo, 5), 'SENSOR'));
if (~isempty(idF1))
   dimLevel = a_metaData(idForWmo(idF1), 3);
   idF2 = find(strcmp(a_metaData(idForWmo, 3), dimLevel) & ...
      strcmp(a_metaData(idForWmo, 5), 'SENSOR_MODEL'));
   if (~isempty(idF2))
      o_sensorModel = strtrim(a_metaData{idForWmo(idF2), 4});
   else
      fprintf('ERROR: Sensor model not found for sensor %s of float %d\n', ...
         a_sensorName, a_floatNum);
   end
else
   fprintf('ERROR: Sensor %s not found for float %d\n', ...
      a_sensorName, a_floatNum);
end

return

% ------------------------------------------------------------------------------
function [o_sensorMaker] = get_sensor_maker(a_sensorName, a_floatNum, a_metaWmoList, a_metaData)

o_sensorMaker = [];

idForWmo = find(a_metaWmoList == a_floatNum);

idF1 = find(strcmp(a_metaData(idForWmo, 4), a_sensorName) & ...
   strcmp(a_metaData(idForWmo, 5), 'SENSOR'));
if (~isempty(idF1))
   dimLevel = a_metaData(idForWmo(idF1), 3);
   idF2 = find(strcmp(a_metaData(idForWmo, 3), dimLevel) & ...
      strcmp(a_metaData(idForWmo, 5), 'SENSOR_MAKER'));
   if (~isempty(idF2))
      o_sensorMaker = strtrim(a_metaData{idForWmo(idF2), 4});
   else
      fprintf('ERROR: Sensor maker not found for sensor %s of float %d\n', ...
         a_sensorName, a_floatNum);
   end
else
   fprintf('ERROR: Sensor %s not found for float %d\n', ...
      a_sensorName, a_floatNum);
end

return

% ------------------------------------------------------------------------------
function [o_floatVersion] = get_float_version(a_floatNum, a_metaWmoList, a_metaData)

o_floatVersion = [];

idForWmo = find(a_metaWmoList == a_floatNum);

idF = find(strcmp(a_metaData(idForWmo, 5), 'PR_VERSION'));
if (~isempty(idF))
   o_floatVersion = a_metaData{idForWmo(idF), 4};
else
   fprintf('ERROR: Float version not found for float %d\n', ...
      a_floatNum);
end

return

% ------------------------------------------------------------------------------
function [o_platformFamily] = get_platform_family_db(a_floatNum, a_decId, a_metaWmoList, a_metaData)
   
o_platformFamily = [];

global g_decArgo_floatNum;
g_decArgo_floatNum = a_floatNum;


% retrieve default value
defaultPlatformFamily = get_platform_family(a_decId);

% retrieve data base value
idForWmo = find(a_metaWmoList == a_floatNum);

idF = find(strcmp(a_metaData(idForWmo, 5), 'PLATFORM_FAMILY'));
if (~isempty(idF))
   o_platformFamily = a_metaData{idForWmo(idF), 4};
end

if (~isempty(o_platformFamily))
   if (~strcmp(o_platformFamily, defaultPlatformFamily))
      fprintf('WARNING: Float #%d decid #%d: DB platform family (%s) differs from default value (%s) - set to default value\n', ...
         a_floatNum, a_decId, ...
         o_platformFamily, defaultPlatformFamily);
      o_platformFamily = defaultPlatformFamily;
   end
else
   o_platformFamily = defaultPlatformFamily;
   fprintf('INFO: Float #%d decid #%d: DB platform family is missing - set to default value (%s)\n', ...
      a_floatNum, a_decId, ...
      o_platformFamily);
end

return

% ------------------------------------------------------------------------------
function [o_platformType] = get_platform_type_db(a_floatNum, a_decId, a_metaWmoList, a_metaData)
   
o_platformType = [];

global g_decArgo_floatNum;
g_decArgo_floatNum = a_floatNum;


% retrieve default value
defaultPlatformType = get_platform_type(a_decId);

% retrieve data base value
idForWmo = find(a_metaWmoList == a_floatNum);

idF = find(strcmp(a_metaData(idForWmo, 5), 'PLATFORM_TYPE'));
if (~isempty(idF))
   o_platformType = a_metaData{idForWmo(idF), 4};
end

if (~isempty(o_platformType))
   if (~strcmp(o_platformType, defaultPlatformType))
      fprintf('WARNING: Float #%d decid #%d: DB platform type (%s) differs from default value (%s) - set to default value\n', ...
         a_floatNum, a_decId, ...
         o_platformType, defaultPlatformType);
      o_platformType = defaultPlatformType;
   end
else
   o_platformType = defaultPlatformType;
   fprintf('INFO: Float #%d decid #%d: DB platform type is missing - set to default value (%s)\n', ...
      a_floatNum, a_decId, ...
      o_platformType);
end

return

% ------------------------------------------------------------------------------
function [o_wmoInstType] = get_wmo_inst_type_db(a_floatNum, a_decId, a_metaWmoList, a_metaData)
   
o_wmoInstType = [];

global g_decArgo_floatNum;
g_decArgo_floatNum = a_floatNum;


% retrieve default value
defaultWmoInstType = get_wmo_instrument_type(a_decId);

% retrieve data base value
idForWmo = find(a_metaWmoList == a_floatNum);

idF = find(strcmp(a_metaData(idForWmo, 5), 'PR_PROBE_CODE'));
if (~isempty(idF))
   o_wmoInstType = a_metaData{idForWmo(idF), 4};
end

if (~isempty(o_wmoInstType))
   if (~strcmp(o_wmoInstType, defaultWmoInstType))
      fprintf('WARNING: Float #%d decid #%d: DB WMO instrument type (%s) differs from default value (%s) - set to default value\n', ...
         a_floatNum, a_decId, ...
         o_wmoInstType, defaultWmoInstType);
      o_wmoInstType = defaultWmoInstType;
   end
else
   o_wmoInstType = defaultWmoInstType;
   fprintf('INFO: Float #%d decid #%d: DB WMO instrument type is missing - set to default value (%s)\n', ...
      a_floatNum, a_decId, ...
      o_wmoInstType);
end

return

% ------------------------------------------------------------------------------
function [o_paramName, o_paramDimLevel, o_paramSensor, ...
   o_paramUnits, o_paramAccuracy, o_paramResolution] = ...
   get_sensor_parameter_info(a_inputSensorName, a_floatNum, a_decId, ...
   a_sunaApfFlag, a_metaWmoList, a_metaData)

o_paramName = [];
o_paramDimLevel = [];
o_paramSensor = [];
o_paramUnits = [];
o_paramAccuracy = [];
o_paramResolution = [];

switch a_inputSensorName
   case  'CTD'
      o_paramName = [ ...
         {'PRES'} {'TEMP'} {'PSAL'} ...
         ];
      o_paramDimLevel = [1 2 3];
      o_paramSensor = [ ...
         {'CTD_PRES'} {'CTD_TEMP'} {'CTD_CNDC'} ...
         ];
      o_paramUnits = [ ...
         {'decibar'} {'degree_Celsius'} {'psu'} ...
         ];
      
   case 'OPTODE'
      switch a_decId
         case {106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116}
            o_paramName = [ ...
               {'C1PHASE_DOXY'} {'C2PHASE_DOXY'} {'TEMP_DOXY'} {'DOXY'} {'PPOX_DOXY'} ...
               ];
            o_paramDimLevel = [101 102 103 104 109];
            o_paramSensor = [ ...
               {'OPTODE_DOXY'} {'OPTODE_DOXY'} {'OPTODE_DOXY'} {'OPTODE_DOXY'} {'OPTODE_DOXY'} ...
               ];
            o_paramUnits = [ ...
               {'degree'} {'degree'} {'degree_Celsius'} {'micromole/kg'} {'millibar'} ...
               ];
            
         case {301}
            o_paramName = [ ...
               {'C1PHASE_DOXY'} {'C2PHASE_DOXY'} {'TEMP_DOXY'} {'DOXY'} ...
               ];
            o_paramDimLevel = [101 102 103 104];
            o_paramSensor = [ ...
               {'OPTODE_DOXY'} {'OPTODE_DOXY'} {'OPTODE_DOXY'} {'OPTODE_DOXY'} ...
               ];
            o_paramUnits = [ ...
               {'degree'} {'degree'} {'degree_Celsius'} {'micromole/kg'} ...
               ];
            
         case {302, 303}
            o_paramName = [ ...
               {'DPHASE_DOXY'} {'TEMP_DOXY'} {'DOXY'} ...
               ];
            o_paramDimLevel = [101 103 104];
            o_paramSensor = [ ...
               {'OPTODE_DOXY'} {'OPTODE_DOXY'} {'OPTODE_DOXY'} ...
               ];
            o_paramUnits = [ ...
               {'degree'} {'degree_Celsius'} {'micromole/kg'} ...
               ];
            
         otherwise
            fprintf('ERROR: No parameter list for OPTODE sensor for decId #%d\n', a_decId);
      end
      
   case 'OCR'
      o_paramName = [ ...
         {'RAW_DOWNWELLING_IRRADIANCE380'} {'RAW_DOWNWELLING_IRRADIANCE412'} ...
         {'RAW_DOWNWELLING_IRRADIANCE490'} {'RAW_DOWNWELLING_PAR'} ...
         {'DOWN_IRRADIANCE380'} {'DOWN_IRRADIANCE412'} ...
         {'DOWN_IRRADIANCE490'} {'DOWNWELLING_PAR'} ...
         ];
      o_paramDimLevel = [201 202 203 204 205 206 207 208];
      o_paramSensor = [ ...
         {'RADIOMETER_DOWN_IRR380'} {'RADIOMETER_DOWN_IRR412'} ...
         {'RADIOMETER_DOWN_IRR490'} {'RADIOMETER_PAR'} ...
         {'RADIOMETER_DOWN_IRR380'} {'RADIOMETER_DOWN_IRR412'} ...
         {'RADIOMETER_DOWN_IRR490'} {'RADIOMETER_PAR'} ...
         ];
      o_paramUnits = [ ...
         {'count'} {'count'} {'count'} {'count'} ...
         {'W/m^2/nm'} {'W/m^2/nm'} {'W/m^2/nm'} {'microMoleQuanta/m^2/sec'} ...
         ];
      
   case 'ECO3'
      
      switch a_decId
         case {105, 106, 107, 110, 111, 113, 114, 116}
            o_paramName = [ ...
               {'FLUORESCENCE_CHLA'} {'BETA_BACKSCATTERING700'} {'FLUORESCENCE_CDOM'} ...
               {'CHLA'} {'CHLA_FLUORESCENCE'} {'BBP700'} {'CDOM'} ...
               ];
            o_paramDimLevel = [301 302 304 305 311 306 308];
            o_paramSensor = [ ...
               {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} {'FLUOROMETER_CDOM'} ...
               {'FLUOROMETER_CHLA'} {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} {'FLUOROMETER_CDOM'} ...
               ];
            o_paramUnits = [ ...
               {'count'} {'count'} {'count'} ...
               {'mg/m3'} {'ru'} {'m-1'} {'ppb'} ...
               ];
            
         case {108, 109, 115}
            o_paramName = [ ...
               {'FLUORESCENCE_CHLA'} {'BETA_BACKSCATTERING700'} {'BETA_BACKSCATTERING532'} ...
               {'CHLA'} {'CHLA_FLUORESCENCE'} {'BBP700'} {'BBP532'} ...
               ];
            o_paramDimLevel = [301 302 303 305 311 306 307];
            o_paramSensor = [ ...
               {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} {'BACKSCATTERINGMETER_BBP532'} ...
               {'FLUOROMETER_CHLA'} {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} {'BACKSCATTERINGMETER_BBP532'} ...
               ];
            o_paramUnits = [ ...
               {'count'} {'count'} {'count'} ...
               {'mg/m3'} {'ru'} {'m-1'} {'m-1'} ...
               ];
            
         otherwise
            fprintf('ERROR: No parameter list for ECO3 sensor for decId #%d\n', a_decId);
      end
      
   case 'CROVER'
      o_paramName = [ ...
         {'CP660'} ...
         ];
      o_paramDimLevel = [501];
      o_paramSensor = [ ...
         {'TRANSMISSOMETER_CP660'} ...
         ];
      o_paramUnits = [ ...
         {'m-1'} ...
         ];
      
   case 'SUNA'
      if (a_sunaApfFlag == 0)
         o_paramName = [ ...
            {'MOLAR_NITRATE'} {'NITRATE'} ...
            ];
         o_paramDimLevel = [605 608];
         o_paramSensor = [ ...
            {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
            ];
         o_paramUnits = [ ...
            {'micromole/l'} {'micromole/kg'} ...
            ];
      else
         switch a_decId
            case {105, 106, 107, 108, 109, 111, 114, 115}
               o_paramName = [ ...
                  {'TEMP_NITRATE'} ...
                  {'TEMP_SPECTROPHOTOMETER_NITRATE'} ...
                  {'HUMIDITY_NITRATE'} ...
                  {'UV_INTENSITY_DARK_NITRATE'} ...
                  {'FIT_ERROR_NITRATE'} ...
                  {'UV_INTENSITY_NITRATE'} ...
                  {'NITRATE'} ...
                  ];
               o_paramDimLevel = [601 602 603 604 606 607 608];
               o_paramSensor = [ ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  {'SPECTROPHOTOMETER_NITRATE'} ...
                  ];
               o_paramUnits = [ ...
                  {'degree_Celsius'} ...
                  {'degree_Celsius'} ...
                  {'percent'} ...
                  {'count'} ...
                  {'dimensionless'} ...
                  {'count'} ...
                  {'micromole/kg'} ...
                  ];
            case {110, 113, 116}
               o_paramName = [ ...
                  {'TEMP_NITRATE'} ...
                  {'TEMP_SPECTROPHOTOMETER_NITRATE'} ...
                  {'HUMIDITY_NITRATE'} ...
                  {'UV_INTENSITY_DARK_NITRATE'} ...
                  {'FIT_ERROR_NITRATE'} ...
                  {'UV_INTENSITY_NITRATE'} ...
                  {'NITRATE'} ...
                  {'BISULFIDE'} ...
                  ];
               o_paramDimLevel = [601 602 603 604 606 607 608 609];
               o_paramSensor = [ ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  {'SPECTROPHOTOMETER_NITRATE'} {'SPECTROPHOTOMETER_NITRATE'} ...
                  ];
               o_paramUnits = [ ...
                  {'degree_Celsius'} ...
                  {'degree_Celsius'} ...
                  {'percent'} ...
                  {'count'} ...
                  {'dimensionless'} ...
                  {'count'} ...
                  {'micromole/kg'} ...
                  {'micromole/kg'} ...
                  ];               
            otherwise
               fprintf('ERROR: No parameter list for SUNA sensor for decId #%d\n', a_decId);
         end
      end
      
   case {'FLBB', 'ECO2'}
      o_paramName = [ ...
         {'FLUORESCENCE_CHLA'} {'BETA_BACKSCATTERING700'} ...
         {'CHLA'} {'CHLA_FLUORESCENCE'} {'BBP700'} ...
         ];
      o_paramDimLevel = [401 402 403 405 404];
      o_paramSensor = [ ...
         {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} ...
         {'FLUOROMETER_CHLA'} {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_BBP700'} ...
         ];
      o_paramUnits = [ ...
         {'count'} {'count'} ...
         {'mg/m3'} {'ru'} {'m-1'} ...
         ];
      
   case 'FLNTU'
      o_paramName = [ ...
         {'FLUORESCENCE_CHLA'} {'SIDE_SCATTERING_TURBIDITY'} ...
         {'CHLA'} {'CHLA_FLUORESCENCE'} {'TURBIDITY'} ...
         ];
      o_paramDimLevel = [401 405 403 405 406];
      o_paramSensor = [ ...
         {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_TURBIDITY'} ...
         {'FLUOROMETER_CHLA'} {'FLUOROMETER_CHLA'} {'BACKSCATTERINGMETER_TURBIDITY'} ...
         ];
      o_paramUnits = [ ...
         {'count'} {'count'} ...
         {'mg/m3'} {'ru'} {'ntu'} ...
         ];
      
   case 'CYCLOPS'
      o_paramName = [ ...
         {'FLUORESCENCE_VOLTAGE_CHLA'}...
         {'CHLA2'}...
         ];
      o_paramDimLevel = [2001 2002];
      o_paramSensor = [ ...
         {'AUX_FLUOROMETER_CHLA2'}...
         {'AUX_FLUOROMETER_CHLA2'}...
         ];
      o_paramUnits = [ ...
         {'volt'}...
         {'mg/m3'}...
         ];
      
   case 'SEAPOINT'
      o_paramName = [ ...
         {'VOLTAGE_TURBIDITY'}...
         {'TURBIDITY2'}...
         ];
      o_paramDimLevel = [2101 2102];
      o_paramSensor = [ ...
         {'AUX_BACKSCATTERINGMETER_TURBIDITY2'}...
         {'AUX_BACKSCATTERINGMETER_TURBIDITY2'}...
         ];
      o_paramUnits = [ ...
         {'volt'}...
         {'ntu'}...
         ];
      
   case 'TRANSISTOR_PH'
      o_paramName = [ ...
         {'VRS_PH'} ...
         {'PH_IN_SITU_FREE'} ...
         {'PH_IN_SITU_TOTAL'} ...
         ];
      o_paramDimLevel = [701 702 703];
      o_paramSensor = [ ...
         {'TRANSISTOR_PH'} ...
         {'TRANSISTOR_PH'} ...
         {'TRANSISTOR_PH'} ...
         ];
      o_paramUnits = [ ...
         {'volt'} ...
         {'dimensionless'} ...
         {'dimensionless'} ...
         ];

   otherwise
      fprintf('ERROR: No sensor parameters for sensor %s\n', a_inputSensorName);
end

for idP = 1:length(o_paramName)
   [o_paramAccuracy{end+1}, o_paramResolution{end+1}] = get_parameter_info(o_paramName{idP}, a_floatNum, a_metaWmoList, a_metaData);
end
o_paramAccuracy = o_paramAccuracy';
o_paramResolution = o_paramResolution';

return

% ------------------------------------------------------------------------------
function [o_paramAccuracy, o_paramResolution] = ...
   get_parameter_info(a_paramName, a_floatNum, a_metaWmoList, a_metaData)

o_paramAccuracy = [];
o_paramResolution = [];

idForWmo = find(a_metaWmoList == a_floatNum);

idF1 = find(strcmp(a_metaData(idForWmo, 4), a_paramName) & ...
   strcmp(a_metaData(idForWmo, 5), 'PARAMETER'));
if (~isempty(idF1))
   dimLevel = a_metaData(idForWmo(idF1), 3);
   
   idF2 = find(strcmp(a_metaData(idForWmo, 3), dimLevel) & ...
      strcmp(a_metaData(idForWmo, 5), 'PARAMETER_ACCURACY'));
   if (~isempty(idF2))
      o_paramAccuracy = a_metaData{idForWmo(idF2), 4};
   end
   if (isempty(o_paramAccuracy))
      if (strcmp(a_paramName, 'PRES'))
         o_paramAccuracy = '2.4';
         fprintf('INFO: ''%s'' PARAMETER_ACCURACY is missing - set to ''%s''\n', a_paramName, o_paramAccuracy);
      elseif (strcmp(a_paramName, 'TEMP'))
         o_paramAccuracy = '0.002';
         fprintf('INFO: ''%s'' PARAMETER_ACCURACY is missing - set to ''%s''\n', a_paramName, o_paramAccuracy);
      elseif (strcmp(a_paramName, 'PSAL'))
         o_paramAccuracy = '0.005';
         fprintf('INFO: ''%s'' PARAMETER_ACCURACY is missing - set to ''%s''\n', a_paramName, o_paramAccuracy);
      elseif (strcmp(a_paramName, 'DOXY'))
         o_paramAccuracy = '10%';
         fprintf('INFO: ''%s'' PARAMETER_ACCURACY is missing - set to ''%s''\n', a_paramName, o_paramAccuracy);
      elseif (strcmp(a_paramName, 'NITRATE'))
         o_paramAccuracy = '2';
         fprintf('INFO: ''%s'' PARAMETER_ACCURACY is missing - set to ''%s''\n', a_paramName, o_paramAccuracy);
      end
   end
   
   idF3 = find(strcmp(a_metaData(idForWmo, 3), dimLevel) & ...
      strcmp(a_metaData(idForWmo, 5), 'PARAMETER_RESOLUTION'));
   if (~isempty(idF3))
      o_paramResolution = a_metaData{idForWmo(idF3), 4};
   end
   if (isempty(o_paramResolution))
      if (strcmp(a_paramName, 'PRES'))
         o_paramResolution = '1';
         fprintf('INFO: ''%s'' PARAMETER_RESOLUTION is missing - set to ''%s''\n', a_paramName, o_paramResolution);
      elseif (strcmp(a_paramName, 'TEMP'))
         o_paramResolution = '0.001';
         fprintf('INFO: ''%s'' PARAMETER_RESOLUTION is missing - set to ''%s''\n', a_paramName, o_paramResolution);
      elseif (strcmp(a_paramName, 'PSAL'))
         o_paramResolution = '0.001';
         fprintf('INFO: ''%s'' PARAMETER_RESOLUTION is missing - set to ''%s''\n', a_paramName, o_paramResolution);
      elseif (strcmp(a_paramName, 'DOXY'))
         o_paramResolution = '0.001';
         fprintf('INFO: ''%s'' PARAMETER_RESOLUTION is missing - set to ''%s''\n', a_paramName, o_paramResolution);
      elseif (strcmp(a_paramName, 'NITRATE'))
         o_paramResolution = '0.01';
         fprintf('INFO: ''%s'' PARAMETER_RESOLUTION is missing - set to ''%s''\n', a_paramName, o_paramResolution);
      end
   end
   
end

return

% ------------------------------------------------------------------------------
function [o_vectorShowMode, o_sensorShowMode] = get_show_mode(a_showModeData, a_floatNum)

o_vectorShowMode = [];
o_sensorShowMode = [];

idF = find((strcmp(a_showModeData(:, 1), num2str(a_floatNum)) == 1) & ...
   (strcmp(a_showModeData(:, 2), 'CONFIG_VectorBoardShowModeOn_LOGICAL') == 1));
if (~isempty(idF))
   o_vectorShowMode = str2num(a_showModeData{idF, 3});
else
   fprintf('ERROR: Vector show mode is missing for float #%d\n', a_floatNum);
end

idF = find((strcmp(a_showModeData(:, 1), num2str(a_floatNum)) == 1) & ...
   (strcmp(a_showModeData(:, 2), 'CONFIG_SensorBoardShowModeOn_LOGICAL') == 1));
if (~isempty(idF))
   o_sensorShowMode = str2num(a_showModeData{idF, 3});
else
   fprintf('ERROR: Sensor show mode is missing for float #%d\n', a_floatNum);
end

return

% ------------------------------------------------------------------------------
function [o_pixelBegin, o_pixelEnd] = get_output_pixel(a_outputPixelData, a_floatNum)

o_pixelBegin = [];
o_pixelEnd = [];

idF = find((strcmp(a_outputPixelData(:, 1), num2str(a_floatNum)) == 1) & ...
   (strcmp(a_outputPixelData(:, 2), 'CONFIG_SunaApfFrameOutputPixelBegin_NUMBER') == 1));
if (~isempty(idF))
   o_pixelBegin = str2num(a_outputPixelData{idF, 3});
else
   fprintf('ERROR: SUNA output pixel begin number is missing for float #%d\n', a_floatNum);
end

idF = find((strcmp(a_outputPixelData(:, 1), num2str(a_floatNum)) == 1) & ...
   (strcmp(a_outputPixelData(:, 2), 'CONFIG_SunaApfFrameOutputPixelEnd_NUMBER') == 1));
if (~isempty(idF))
   o_pixelEnd = str2num(a_outputPixelData{idF, 3});
else
   fprintf('ERROR: SUNA output pixel end number is missing for float #%d\n', a_floatNum);
end

return
