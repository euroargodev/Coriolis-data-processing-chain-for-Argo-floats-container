% ------------------------------------------------------------------------------
% Process meta-data exported from Coriolis data base and save it in individual
% json files.
%
% SYNTAX :
%  generate_json_float_meta_nva_( ...
%    a_floatMetaFileName, a_floatListFileName, a_outputDirName)
%
% INPUT PARAMETERS :
%   a_floatMetaFileName : meta-data file exported from Coriolis data base
%   a_floatListFileName : list of concerned floats
%   a_outputDirName     : directory of individual json float meta-data files
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/26/2016 - RNU - creation
%   09/01/2017 - RNU - RT version added
% ------------------------------------------------------------------------------
function generate_json_float_meta_nva_( ...
   a_floatMetaFileName, a_floatListFileName, a_outputDirName)

% report information structure
global g_cogj_reportData;


% check inputs
fprintf('Generating json meta-data files from input file: \n FLOAT_META_FILE_NAME = %s\n', a_floatMetaFileName);

if ~(exist(a_floatMetaFileName, 'file') == 2)
   fprintf('ERROR: Meta-data file not found: %s\n', a_floatMetaFileName);
   return
end

fprintf('Generating json meta-data files for floats of the list: \n FLOAT_LIST_FILE_NAME = %s\n', a_floatListFileName);

if ~(exist(a_floatListFileName, 'file') == 2)
   fprintf('ERROR: Float file list not found: %s\n', a_floatListFileName);
   return
end

fprintf('Output directory of json meta-data files: \n OUTPUT_DIR_NAME = %s\n', a_outputDirName);

% lists of mandatory meta-data
% FLOAT_SERIAL_NO and SENSOR_SERIAL_NO should not be in the following list
% (only the database can set these mandatory values to 'n/a')
mandatoryList1 = [ ...
   {'BATTERY_TYPE'} ...
   {'CONTROLLER_BOARD_SERIAL_NO_PRIMARY'} ...
   {'CONTROLLER_BOARD_TYPE_PRIMARY'} ...
   {'DAC_FORMAT_ID'} ...
   {'FIRMWARE_VERSION'} ...
   {'MANUAL_VERSION'} ...
   {'PI_NAME'} ...
   {'PREDEPLOYMENT_CALIB_COEFFICIENT'} ...
   {'PREDEPLOYMENT_CALIB_EQUATION'} ...
   {'PTT'} ...
   {'PARAMETER_UNITS'} ...
   {'PARAMETER_SENSOR'} ...
   {'STANDARD_FORMAT_ID'} ...
   {'TRANS_FREQUENCY'} ...
   {'TRANS_SYSTEM_ID'} ...
   {'WMO_INST_TYPE'} ...
   ];
mandatoryList2 = [ ...
   {'SENSOR_MAKER'} ...
   {'SENSOR_MODEL'} ...
   ];

% get DB meta-data
fId = fopen(a_floatMetaFileName, 'r');
if (fId == -1)
   fprintf('ERROR: Unable to open file: %s\n', a_floatMetaFileName);
   return
end
fileContents = textscan(fId, '%s', 'delimiter', '\t');
fileContents = fileContents{:};
fclose(fId);

fileContents = regexprep(fileContents, '"', '');

metaData = reshape(fileContents, 5, size(fileContents, 1)/5)';
metaData(:,4)=(cellfun(@strtrim, metaData(:, 4), 'UniformOutput', 0))';

% get the mapping structure
metaBddStruct = get_meta_bdd_struct();
metaBddStructNames = fieldnames(metaBddStruct);

% process the meta-data to fill the structure
% wmoList = str2num(cell2mat(metaData(:, 1))); % works only if all raws have the sme number of digits
% dimLevlist = str2num(cell2mat(metaData(:, 3))); % works only if all raws have the sme number of digits
wmoList = metaData(:, 1);
for id = 1:length(wmoList)
   if (isempty(str2num(wmoList{id})))
      fprintf('%s is not a valid WMO number\n', wmoList{id});
      return
   end
end
S = sprintf('%s*', wmoList{:});
wmoList = sscanf(S, '%f*');
dimLevlist = metaData(:, 3);
S = sprintf('%s*', dimLevlist{:});
dimLevlist = sscanf(S, '%f*');
floatList = unique(wmoList);

% check needed floats against DB contents
refFloatList = load(a_floatListFileName);

floatList = sort(intersect(floatList, refFloatList));
% floatList = [6903178];

notFoundFloat = setdiff(refFloatList, floatList);
if (~isempty(notFoundFloat))
   fprintf('WARNING: Meta-data not found for float: %d\n', notFoundFloat);
end

% process floats
for idFloat = 1:length(floatList)
   
   skipFloat = 0;
   floatNum = floatList(idFloat);
   
   fprintf('%3d/%3d %d\n', idFloat, length(floatList), floatNum);
   
   % initialize the structure to be filled
   metaStruct = get_meta_init_struct();
   
   metaStruct.PLATFORM_NUMBER = num2str(floatNum);
   metaStruct.ARGO_USER_MANUAL_VERSION = '3.1';
   
   % direct conversion data
   idForWmo = find(wmoList == floatNum);
   for idBSN = 1:length(metaBddStructNames)
      metaBddStructField = metaBddStructNames{idBSN};
      metaBddStructValue = metaBddStruct.(metaBddStructField);
      if (~isempty(metaBddStructValue))
         idF = find(strcmp(metaData(idForWmo, 5), metaBddStructValue) == 1, 1);
         if (~isempty(idF))
            metaStruct.(metaBddStructField) = metaData{idForWmo(idF), 4};
         else
            if (~isempty(find(strcmp(mandatoryList1, metaBddStructField) == 1, 1)))
               metaStruct.(metaBddStructField) = 'n/a';
               %                fprintf('Empty mandatory meta-data ''%s'' set to ''n/a''\n', metaBddStructValue);
            elseif (~isempty(find(strcmp(mandatoryList2, metaBddStructField) == 1, 1)))
               metaStruct.(metaBddStructField) = 'UNKNOWN';
            end
            if (strcmp(metaBddStructField, 'FLOAT_SERIAL_NO'))
               fprintf('ERROR: Float #%d: FLOAT_SERIAL_NO (''%s'') is mandatory - no json file generated\n', ...
                  floatNum, metaBddStructValue);
               skipFloat = 1;
            end
         end
      end
   end
   
   % retrieve DAC_FORMAT_ID
   dacFormatId = metaStruct.DAC_FORMAT_ID;
   if (isempty(dacFormatId))
      fprintf('ERROR: DAC_FORMAT_ID (from PR_VERSION) is missing for float %d - no json file generated\n', ...
         floatNum);
      continue
   end
   
   % check if the float version is concerned by this tool
   if (~ismember(dacFormatId, [{'1.0'} {'2.0'} {'0.9'}]))
      fprintf('INFO: Float %d is not managed by this tool (DAC_FORMAT_ID (from PR_VERSION) : ''%s'')\n', ...
         floatNum, dacFormatId);
      continue
   end
   
   % multi dim data
   itemList = [ ...
      {'TRANS_SYSTEM'} ...
      {'TRANS_SYSTEM_ID'} ...
      {'TRANS_FREQUENCY'} ...
      ];
   [metaStruct] = add_multi_dim_data( ...
      itemList, ...
      metaData, idForWmo, dimLevlist, ...
      metaStruct, mandatoryList1, mandatoryList2);
   
   [metaStruct] = add_multi_dim_data( ...
      {'POSITIONING_SYSTEM'}, ...
      metaData, idForWmo, dimLevlist, ...
      metaStruct, mandatoryList1, mandatoryList2);
   
   itemList = [ ...
      {'SENSOR'} ...
      {'SENSOR_MAKER'} ...
      {'SENSOR_MODEL'} ...
      {'SENSOR_SERIAL_NO'} ...
      ];
   [metaStruct] = add_multi_dim_data( ...
      itemList, ...
      metaData, idForWmo, dimLevlist, ...
      metaStruct, mandatoryList1, mandatoryList2);
   
   % check that SENSOR_SERIAL_NO is set
   if (~isempty(metaStruct.SENSOR_SERIAL_NO))
      for idS = 1:length(metaStruct.SENSOR_SERIAL_NO)
         if (isempty(metaStruct.SENSOR_SERIAL_NO{idS}))
            fprintf('ERROR: Float #%d: SENSOR_SERIAL_NO is mandatory (for SENSOR=''%s'' SENSOR_MODEL=''%s'' SENSOR_MAKER=''%s'') - no json file generated\n', ...
               floatNum, ...
               metaStruct.SENSOR{idS}, ...
               metaStruct.SENSOR_MODEL{idS}, ...
               metaStruct.SENSOR_MAKER{idS});
            skipFloat = 1;
         end
      end
   else
      fprintf('ERROR: Float #%d: SENSOR_SERIAL_NO is mandatory - no json file generated\n', ...
         floatNum);
      skipFloat = 1;
   end
   
   itemList = [ ...
      {'PARAMETER'} ...
      {'PARAMETER_SENSOR'} ...
      {'PARAMETER_UNITS'} ...
      {'PARAMETER_ACCURACY'} ...
      {'PARAMETER_RESOLUTION'} ...
      {'PREDEPLOYMENT_CALIB_EQUATION'} ...
      {'PREDEPLOYMENT_CALIB_COEFFICIENT'} ...
      {'PREDEPLOYMENT_CALIB_COMMENT'} ...
      ];
   [metaStruct] = add_multi_dim_data( ...
      itemList, ...
      metaData, idForWmo, dimLevlist, ...
      metaStruct, mandatoryList1, mandatoryList2);
   
   itemList = [ ...
      {'CALIB_RT_PARAMETER'} ...
      {'CALIB_RT_EQUATION'} ...
      {'CALIB_RT_COEFFICIENT'} ...
      {'CALIB_RT_COMMENT'} ...
      {'CALIB_RT_DATE'} ...
      {'CALIB_RT_DATE_APPLY'} ...
      {'CALIB_RT_ADJUSTED_ERROR'} ...
      {'CALIB_RT_ADJ_ERROR_METHOD'} ...
      ];
   [metaStruct] = add_multi_dim_data( ...
      itemList, ...
      metaData, idForWmo, dimLevlist, ...
      metaStruct, mandatoryList1, mandatoryList2);

   % IMEI / PTT specific processing
   if (~isempty(metaStruct.IMEI))
      if (length(metaStruct.IMEI) ~= 15)
         fprintf('ERROR: Float #%d: inconsistent IMEI number (''%s''); 15 digits expected\n', ...
            floatNum, metaStruct.IMEI);
      else
         if (~strcmp(metaStruct.PTT, 'n/a'))
            if (length(metaStruct.PTT) ~= 6)
               fprintf('ERROR: Float #%d: inconsistent PTT number (''%s''); 6 digits expected\n', ...
                  floatNum, metaStruct.PTT);
            else
               if (~strcmp(metaStruct.IMEI(end-6:end-1), metaStruct.PTT))
                  fprintf('ERROR: Float #%d: inconsistent IMEI number (''%s'') VS PTT number (''%s'')\n', ...
                     floatNum, metaStruct.IMEI, metaStruct.PTT);
               end
            end
         else
            metaStruct.PTT = metaStruct.IMEI(end-6:end-1);
            fprintf('INFO: Float #%d: PTT number (''%s'') set from IMEI number (''%s'')\n', ...
               floatNum, metaStruct.PTT, metaStruct.IMEI);
         end
      end
   elseif (~strcmp(metaStruct.PTT, 'n/a'))
      fprintf('WARNING: Float #%d: PTT number (''%s'') is set but IMEI number is unknown\n', ...
         floatNum, metaStruct.PTT);
   end   
   
   % configuration parameters

   % CONFIG_PARAMETER_NAME
   configStruct = get_config_init_struct(dacFormatId);
   if (isempty(configStruct))
      continue
   end
   configStructNames = fieldnames(configStruct);
   metaStruct.CONFIG_PARAMETER_NAME = configStructNames;
   
   % CONFIG_PARAMETER_VALUE
   configBddStruct = get_config_bdd_struct(dacFormatId);
   if (isempty(configBddStruct))
      continue
   end
   configBddStructNames = fieldnames(configBddStruct);
   
   nbConfig = 1;
   configParamVal = cell(length(configStructNames), nbConfig);
   for idConf = 1:nbConfig
      for idBSN = 1:length(configBddStructNames)
         configBddStructName = configBddStructNames{idBSN};
         configBddStructValue = configBddStruct.(configBddStructName);
         if (~isempty(configBddStructValue))
            idF = find(strcmp(metaData(idForWmo, 5), configBddStructValue) == 1);
            if (~isempty(idF))
               dimLev = dimLevlist(idForWmo(idF));
               idDim = find(dimLev == idConf, 1);
               if ((isempty(idDim)) && (idConf > 1))
                  idDim = 1;
               elseif ((isempty(idDim)) && (idConf == 1))
                  fprintf('ERROR\n');
               end
               
               if ((strcmp(configBddStructValue, 'DIRECTION') == 0) && ...
                     (strcmp(configBddStructValue, 'CYCLE_TIME') == 0) && ...
                     (strcmp(configBddStructValue, 'PR_IMMERSION_DRIFT_PERIOD') == 0) && ...
                     (strncmp(configBddStructValue, 'SBE_OPTODE_COEF_', length('SBE_OPTODE_COEF_')) == 0))
                  configParamVal{idBSN, idConf} = metaData{idForWmo(idF(idDim)), 4};
               else
                  if (strcmp(configBddStructValue, 'DIRECTION') == 1)
                     configParamVal{idBSN, idConf} = '1';
                  elseif (strcmp(configBddStructValue, 'CYCLE_TIME') == 1)
                     configParamVal{idBSN, idConf} = num2str(str2num(metaData{idForWmo(idF(idDim)), 4})/24);
                  elseif (strcmp(configBddStructValue, 'PR_IMMERSION_DRIFT_PERIOD') == 1)
                     configParamVal{idBSN, idConf} = num2str(str2num(metaData{idForWmo(idF(idDim)), 4})/60);
                  elseif (strncmp(configBddStructValue, 'SBE_OPTODE_COEF_', length('SBE_OPTODE_COEF_')) == 1)
                     % processed below
                  end
               end
            end
         else
            % if we want to use default values if the information is
            % missing in the database
            %                      configParamVal{idBSN, idConf} = configStruct.(configBddStructName);
         end
         
      end
   end
   
   % CONFIG_PARAMETER_VALUE
   metaStruct.CONFIG_PARAMETER_VALUE = configParamVal;
   
   metaStruct.CONFIG_MISSION_NUMBER = {'0'};
   
   % CALIBRATION_COEFFICIENT
   switch (dacFormatId)
      case {'2.0'}
         calibData = [];
         idF = find(strncmp(metaData(idForWmo, 5), 'SBE_OPTODE_COEF_', length('SBE_OPTODE_COEF_')) == 1);
         for id = 1:length(idF)
            calibName = metaData{idForWmo(idF(id)), 5};
            idFUs = strfind(calibName, '_');
            if (length(idFUs) > 2)
               fieldName = ['SBEOptode' calibName(idFUs(3)+1:end)];
               calibData.(fieldName) = metaData{idForWmo(idF(id)), 4};
            end
         end
         if (~isempty(calibData))
            calibrationCoefficient = [];
            calibrationCoefficient.OPTODE = calibData;
            
            metaStruct.CALIBRATION_COEFFICIENT = calibrationCoefficient;
         else
            fprintf('WARNING: DOXY calibration information is missing for float %d\n', ...
               floatNum);
         end
   end
   
   % RT_OFFSET
   if (any(strcmp(metaData(idForWmo, 5), 'CALIB_RT_PARAMETER')))
      metaStruct.RT_OFFSET = get_rt_offset(metaData, idForWmo);
   end
   
   if (~check_json_meta_data(metaStruct, floatNum))
      skipFloat = 1;
   end
   
   if (~check_json_meta_data(metaStruct, floatNum))
      skipFloat = 1;
   end
   
   if (skipFloat)
      continue
   end
   
   % create the directory of json output files
   if ~(exist(a_outputDirName, 'dir') == 7)
      mkdir(a_outputDirName);
   end
   
   % create json output file
   outputFileName = [a_outputDirName '/' sprintf('%d_meta.json', floatNum)];
   ok = generate_json_file(outputFileName, metaStruct);
   if (~ok)
      return
   end
   g_cogj_reportData{end+1} = outputFileName;

end

return

% ------------------------------------------------------------------------------
% Get the list of configuration parameters for a given float version.
%
% SYNTAX :
%  [o_configStruct] = get_config_init_struct(a_dacFormatId)
%
% INPUT PARAMETERS :
%   a_dacFormatId : float DAC version
%
% OUTPUT PARAMETERS :
%   o_configStruct : list of configuration parameters
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/26/2016 - RNU - creation
%   09/01/2017 - RNU - RT version added
% ------------------------------------------------------------------------------
function [o_configStruct] = get_config_init_struct(a_dacFormatId)

% output parameters initialization
o_configStruct = [];

switch (a_dacFormatId)
   case {'1.0', '2.0', '0.9'}
      o_configStruct = struct( ...
         'CONFIG_PM00_CyclePeriod', '10', ...
         'CONFIG_PM01_NumberOfCycles', '255', ...
         'CONFIG_PM02_AscentStartTime', '23', ...
         'CONFIG_PM03_AscentSamplingPeriod', '10', ...
         'CONFIG_PM04_DescentSamplingPeriod', '0', ...
         'CONFIG_PM05_DriftSamplingPeriod', '24', ...
         'CONFIG_PM06_DriftDepth', '1000', ...
         'CONFIG_PM07_ProfileDepth', '2000', ...
         'CONFIG_PM08_DelayBeforeProfile', '6', ...
         'CONFIG_PM09_DepthIntervalSpotSampling', '5', ...
         'CONFIG_PM12_DelayBeforeMission', '15', ...
         'CONFIG_PM13_IridiumEOLTransmissionPeriod', '30', ...
         'CONFIG_PM14_ReferenceDay', '0', ...
         'CONFIG_PH01_SurfaceValveMaxTimeAdditionalActions', '200', ...
         'CONFIG_PH02__OilVolumeMaxPerValveAction', '15', ...
         'CONFIG_PH03__OilVolumeMinPerValveAction', '1', ...
         'CONFIG_PH04_PumpActionMaxTimeReposition', '100', ...
         'CONFIG_PH05_PumpActionMaxTimeAscent', '200', ...
         'CONFIG_PH06_PumpActionTimeBuoyancyAcquisition', '600', ...
         'CONFIG_PH07_TimeDelayAfterEndOfAscentPressureThreshold', '3', ...
         'CONFIG_PH08_MaxPumpActionTimeBuoyancyAcquisition', '9000', ...
         'CONFIG_PH09_PressureCheckPeriodDuringAscent', '1', ...
         'CONFIG_PH10_PressureCheckTimeBuoyancyReductionPhase', '1', ...
         'CONFIG_PH11_PressureCheckPeriodDuringDescent', '5', ...
         'CONFIG_PH12_PressureCheckPeriodDuringParking', '10', ...
         'CONFIG_PH13_PressureCheckPeriodDuringStabilization', '0', ...
         'CONFIG_PH14_PressureTargetToleranceForStabAtParkingDepth', '25', ...
         'CONFIG_PH15_NumberOfOutOfTolerancePresBeforeReposition', '1', ...
         'CONFIG_PH16_PressureTargetToleranceDuringDriftAtParkingDepth', '100', ...
         'CONFIG_PH17_PressureMaxBeforeEmergencyAscent', '2100', ...
         'CONFIG_PH18_BuoyancyReductionSecondThreshold', '8', ...
         'CONFIG_PH19_GroundingMode', '0', ...
         'CONFIG_PH20_MinValveActionForSurfaceGroundingDetection', '300', ...
         'CONFIG_PH21_OilVolumeMinForGroundingDetection', '100', ...
         'CONFIG_PH22_GroundingModeMinPresThreshold', '200', ...
         'CONFIG_PH23_GroundingModePresAdjustment', '50', ...
         'CONFIG_PH25_GPSTimeout', '900', ...
         'CONFIG_PH26_PressureTargetToleranceForStabAtProfileDepth', '20', ...
         'CONFIG_PH27_PressureTargetToleranceDuringDriftAtProfileDepth', '20', ...
         'CONFIG_PH29_ProfileSurfaceBinInterval', '10', ...
         'CONFIG_PH30_ThicknessOfTheSurfaceSlices', '980', ...
         'CONFIG_PH31_ThresholdSurfaceMiddlePressure', '1000', ...
         'CONFIG_PH32_ProfileIntermediateBinInterval', '25', ...
         'CONFIG_PH33_ThicknessOfTheMiddleSlices', '3975', ...
         'CONFIG_PH34_ThresholdMiddleBottomPressure', '5000', ...
         'CONFIG_PH35_ProfileBottomBinInterval', '50', ...
         'CONFIG_PH36_ThicknessOfTheBottomSlices', '14950', ...
         'CONFIG_PH37_ProfileIncludeTransitionBin', '0', ...
         'CONFIG_PH38_ProfileSamplingMethod', '0', ...
         'CONFIG_PX00_Direction', '3');        
   otherwise
      fprintf('WARNING: Nothing done yet in generate_json_float_meta_nva_ for dacFormatId %s\n', a_dacFormatId);
end

return

% ------------------------------------------------------------------------------
% Get the list of BDD variables associated to configuration parameters for a
% given float version.
%
% SYNTAX :
%  [o_configStruct] = get_config_bdd_struct(a_dacFormatId)
%
% INPUT PARAMETERS :
%   a_dacFormatId : float DAC version
%
% OUTPUT PARAMETERS :
%   o_configStruct : list of BDD variables
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/26/2016 - RNU - creation
%   09/01/2017 - RNU - RT version added
% ------------------------------------------------------------------------------
function [o_configStruct] = get_config_bdd_struct(a_dacFormatId)

% output parameters initialization
o_configStruct = [];

switch (a_dacFormatId)
   case {'1.0', '2.0', '0.9'}
      o_configStruct = struct( ...
         'CONFIG_PM00_CyclePeriod', 'CYCLE_TIME', ...
         'CONFIG_PM01_NumberOfCycles', 'CONFIG_MaxCycles_NUMBER', ...
         'CONFIG_PM02_AscentStartTime', 'PRCFG_Start_time', ...
         'CONFIG_PM03_AscentSamplingPeriod', 'ASC_PROFILE_PERIOD', ...
         'CONFIG_PM04_DescentSamplingPeriod', 'DESC_PROFILE_PERIOD', ...
         'CONFIG_PM05_DriftSamplingPeriod', 'PR_IMMERSION_DRIFT_PERIOD', ...
         'CONFIG_PM06_DriftDepth', 'PARKING_PRESSURE', ...
         'CONFIG_PM07_ProfileDepth', 'DEEPEST_PRESSURE', ...
         'CONFIG_PM08_DelayBeforeProfile', 'DEEP_PROFILE_DESCENT_DELAY', ...
         'CONFIG_PM09_DepthIntervalSpotSampling', 'ProfileDepthInterval', ...
         'CONFIG_PM12_DelayBeforeMission', 'DELAY_BEFORE_MISSION', ...
         'CONFIG_PM13_IridiumEOLTransmissionPeriod', 'EndOfLifeTransPeriod', ...
         'CONFIG_PM14_ReferenceDay', 'PRCFG_Reference_day', ...
         'CONFIG_PH01_SurfaceValveMaxTimeAdditionalActions', 'PRCFG_Surf_valve_max_duration', ...
         'CONFIG_PH02_OilVolumeMaxPerValveAction', 'PRCFG_Depth_valve_max_volume', ...
         'CONFIG_PH03_OilVolumeMinPerValveAction', 'PRCFG_Depth_valve_min_volume', ...
         'CONFIG_PH04_PumpActionMaxTimeReposition', 'PRCFG_Depth_pump_max_duration', ...
         'CONFIG_PH05_PumpActionMaxTimeAscent', 'PRCFG_Asc_pump_max_duration', ...
         'CONFIG_PH06_PumpActionTimeBuoyancyAcquisition', 'PRCFG_Surf_pump_duration', ...
         'CONFIG_PH07_TimeDelayAfterEndOfAscentPressureThreshold', 'TimeDelayAfterAET', ...
         'CONFIG_PH08_MaxPumpActionTimeBuoyancyAcquisition', 'PumpActionTimeEmptyReservoir', ...
         'CONFIG_PH09_PressureCheckPeriodDuringAscent', 'VECTOR_ASCEND_SAMPLING_PERIOD', ...
         'CONFIG_PH10_PressureCheckTimeBuoyancyReductionPhase', 'VECTOR_SURFACE_SAMPLING_PERIOD', ...
         'CONFIG_PH11_PressureCheckPeriodDuringDescent', 'VECTOR_DESCEND_SAMPLING_PERIOD', ...
         'CONFIG_PH12_PressureCheckPeriodDuringParking', 'VECTOR_PARK_SAMPLING_PERIOD', ...
         'CONFIG_PH13_PressureCheckPeriodDuringStabilization', 'VECTOR_STAB_SAMPLING_PERIOD', ...
         'CONFIG_PH14_PressureTargetToleranceForStabAtParkingDepth', 'TargetToleranceForStabParkDepth', ...
         'CONFIG_PH15_NumberOfOutOfTolerancePresBeforeReposition', 'PRCFG_Gap_order_delta_position', ...
         'CONFIG_PH16_PressureTargetToleranceDuringDriftAtParkingDepth', 'TargetToleranceForDriftParkDepth', ...
         'CONFIG_PH17_PressureMaxBeforeEmergencyAscent', 'PRCFG_Max_pressure', ...
         'CONFIG_PH18_BuoyancyReductionSecondThreshold', 'PRCFG_Descent_start_pressure', ...
         'CONFIG_PH19_GroundingMode', 'PRCFG_Grounded_mode', ...
         'CONFIG_PH20_MinValveActionForSurfaceGroundingDetection', 'ValveActionsForSurfaceGrounding', ...
         'CONFIG_PH21_OilVolumeMinForGroundingDetection', 'PRCFG_Grounded_volume', ...
         'CONFIG_PH22_GroundingModeMinPresThreshold', 'PRCFG_Grounded_waiting_pres', ...
         'CONFIG_PH23_GroundingModePresAdjustment', 'PRCFG_Grounded_reduction_pres', ...
         'CONFIG_PH25_GPSTimeout', 'GPSTimeout', ...
         'CONFIG_PH26_PressureTargetToleranceForStabAtProfileDepth', 'TargetToleranceForStabProfDepth', ...
         'CONFIG_PH27_PressureTargetToleranceDuringDriftAtProfileDepth', 'TargetToleranceForDriftProfDepth', ...
         'CONFIG_PH29_ProfileSurfaceBinInterval', 'ProfileSurfaceBinInterval', ...
         'CONFIG_PH30_ThicknessOfTheSurfaceSlices', 'SURF_SLICE_THICKNESS', ...
         'CONFIG_PH31_ThresholdSurfaceMiddlePressure', 'INT_SURF_THRESHOLD', ...
         'CONFIG_PH32_ProfileIntermediateBinInterval', 'ProfileMiddleBinInterval', ...
         'CONFIG_PH33_ThicknessOfTheMiddleSlices', 'INT_SLICE_THICKNESS', ...
         'CONFIG_PH34_ThresholdMiddleBottomPressure', 'DEPTH_INT_THRESHOLD', ...
         'CONFIG_PH35_ProfileBottomBinInterval', 'ProfileBottomBinInterval', ...
         'CONFIG_PH36_ThicknessOfTheBottomSlices', 'DEPTH_SLICE_THICKNESS', ...
         'CONFIG_PH37_ProfileIncludeTransitionBin', 'ProfileIncludeTransitionBins', ...
         'CONFIG_PH38_ProfileSamplingMethod', 'ProfileSamplingMethod', ...
         'CONFIG_PX00_Direction', 'DIRECTION');      
   otherwise
      fprintf('WARNING: Nothing done yet in generate_json_float_meta_nva_ for dacFormatId %s\n', a_dacFormatId);
end

return

% ------------------------------------------------------------------------------
% Get the list of BDD variables associated to float meta-data.
%
% SYNTAX :
%  [o_metaStruct] = get_meta_bdd_struct()
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%   o_metaStruct : list of BDD variables
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/26/2016 - RNU - creation
%   09/01/2017 - RNU - RT version added
% ------------------------------------------------------------------------------
function [o_metaStruct] = get_meta_bdd_struct()

% output parameters initialization
o_metaStruct = struct( ...
   'ARGO_USER_MANUAL_VERSION', '', ...
   'PLATFORM_NUMBER', '', ...
   'PTT', 'PTT', ...
   'IMEI', 'IMEI', ...
   'TRANS_SYSTEM', 'TRANS_SYSTEM', ...
   'TRANS_SYSTEM_ID', 'TRANS_SYSTEM_ID', ...
   'TRANS_FREQUENCY', 'TRANS_FREQUENCY', ...
   'POSITIONING_SYSTEM', 'POSITIONING_SYSTEM', ...
   'PLATFORM_FAMILY', 'PLATFORM_FAMILY', ...
   'PLATFORM_TYPE', 'PLATFORM_TYPE', ...
   'PLATFORM_MAKER', 'PLATFORM_MAKER', ...
   'FIRMWARE_VERSION', 'FIRMWARE_VERSION', ...
   'MANUAL_VERSION', 'MANUAL_VERSION', ...
   'FLOAT_SERIAL_NO', 'INST_REFERENCE', ...
   'STANDARD_FORMAT_ID', 'STANDARD_FORMAT_ID', ...
   'DAC_FORMAT_ID', 'PR_VERSION', ...
   'WMO_INST_TYPE', 'PR_PROBE_CODE', ...
   'PROJECT_NAME', 'PR_EXPERIMENT_ID', ...
   'DATA_CENTRE', 'DATA_CENTRE', ...
   'PI_NAME', 'PI_NAME', ...
   'ANOMALY', 'ANOMALY', ...
   'BATTERY_TYPE', 'BATTERY_TYPE', ...
   'BATTERY_PACKS', 'BATTERY_PACKS', ...
   'CONTROLLER_BOARD_TYPE_PRIMARY', 'CONTROLLER_BOARD_TYPE_PRIMARY', ...
   'CONTROLLER_BOARD_TYPE_SECONDARY', 'CONTROLLER_BOARD_TYPE_SECONDARY', ...
   'CONTROLLER_BOARD_SERIAL_NO_PRIMARY', 'CONTROLLER_BOARD_SERIAL_NO_PRIMA', ...
   'CONTROLLER_BOARD_SERIAL_NO_SECONDARY', 'CONTROLLER_BOARD_SERIAL_NO_SECON', ...
   'SPECIAL_FEATURES', 'SPECIAL_FEATURES', ...
   'FLOAT_OWNER', 'FLOAT_OWNER', ...
   'OPERATING_INSTITUTION', 'OPERATING_INSTITUTION', ...
   'CUSTOMISATION', 'CUSTOMISATION', ...
   'LAUNCH_DATE', 'PR_LAUNCH_DATETIME', ...
   'LAUNCH_LATITUDE', 'PR_LAUNCH_LATITUDE', ...
   'LAUNCH_LONGITUDE', 'PR_LAUNCH_LONGITUDE', ...
   'LAUNCH_QC', 'LAUNCH_QC', ...
   'START_DATE', 'START_DATE', ...
   'START_DATE_QC', 'START_DATE_QC', ...
   'STARTUP_DATE', '', ...
   'STARTUP_DATE_QC', '', ...
   'DEPLOYMENT_PLATFORM', 'DEPLOY_PLATFORM', ...
   'DEPLOYMENT_CRUISE_ID', 'CRUISE_NAME', ...
   'DEPLOYMENT_REFERENCE_STATION_ID', 'DEPLOY_AVAILABLE_PROFILE_ID', ...
   'END_MISSION_DATE', 'END_MISSION_DATE', ...
   'END_MISSION_STATUS', 'END_MISSION_STATUS', ...
   'END_DECODING_DATE', 'END_DECODING_DATE', ...
   'PREDEPLOYMENT_CALIB_EQUATION', 'PREDEPLOYMENT_CALIB_EQUATION', ...
   'PREDEPLOYMENT_CALIB_COEFFICIENT', 'PREDEPLOYMENT_CALIB_COEFFICIENT', ...
   'PREDEPLOYMENT_CALIB_COMMENT', 'PREDEPLOYMENT_CALIB_COMMENT', ...
   'CALIB_RT_PARAMETER', 'CALIB_RT_PARAMETER', ...
   'CALIB_RT_EQUATION', 'CALIB_RT_EQUATION', ...
   'CALIB_RT_COEFFICIENT', 'CALIB_RT_COEFFICIENT', ...
   'CALIB_RT_COMMENT', 'CALIB_RT_COMMENT', ...
   'CALIB_RT_DATE', 'CALIB_RT_DATE', ...
   'CALIB_RT_ADJUSTED_ERROR', 'CALIB_RT_ADJUSTED_ERROR', ...
   'CALIB_RT_ADJ_ERROR_METHOD', 'CALIB_RT_ADJ_ERROR_METHOD');

return