% ------------------------------------------------------------------------------
% Decode NOVA data.
%
% SYNTAX :
%  decode_nova(a_floatList)
%
% INPUT PARAMETERS :
%   a_floatList : list of float to decode
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   03/04/2016 - RNU - creation
% ------------------------------------------------------------------------------
function decode_nova(a_floatList)

% current float WMO number
global g_decArgo_floatNum;

% output CSV file Id
global g_decArgo_outputCsvFileId;

% output NetCDF technical parameter Ids
global g_decArgo_outputNcParamId;

% output NetCDF technical parameter labels
global g_decArgo_outputNcParamLabel;
global g_decArgo_outputNcParamDescription;

% output NetCDF technical parameter names additional information
global g_decArgo_outputNcParamLabelInfo;
global g_decArgo_outputNcParamLabelInfoCounter;

% output NetCDF configuration parameter Ids
global g_decArgo_outputNcConfParamId;

% output NetCDF configuration parameter labels
global g_decArgo_outputNcConfParamLabel;

% output NetCDF configuration parameter descriptions
global g_decArgo_outputNcConfParamDescription;

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

% report information structure
global g_decArgo_reportData;
global g_decArgo_reportStruct;

% configuration values
global g_decArgo_floatInformationFileName;
global g_decArgo_dirInputJsonTechLabelFile;
global g_decArgo_dirInputJsonConfLabelFile;
global g_decArgo_generateNcTraj31;
global g_decArgo_generateNcTraj32;
global g_decArgo_generateNcMultiProf;
global g_decArgo_generateNcMonoProf;
global g_decArgo_generateNcTech;
global g_decArgo_generateNcMeta;
global g_decArgo_applyRtqc;

% Argos (1), Iridium RUDICS (2), Iridium SBD (3) or Iridium SBD2 (4) float
global g_decArgo_floatTransType;

% array to store surface data of Argos floats
global g_decArgo_floatSurfData;

% array to store GPS data
global g_decArgo_gpsData;

% array to store Iridium mail contents
global g_decArgo_iridiumMailData;

% global default values
global g_decArgo_dateDef;
global g_decArgo_argosLonDef;
global g_decArgo_janFirst1950InMatlab;

% for virtual buffers management
global g_decArgo_spoolFileList;
global g_decArgo_bufFileList;

% float launch information
global g_decArgo_floatLaunchDate;
global g_decArgo_floatLaunchLon;
global g_decArgo_floatLaunchLat;

% to store information parameter RT adjustment
global g_decArgo_paramProfAdjInfo;
global g_decArgo_paramProfAdjId;
global g_decArgo_paramTrajAdjInfo;
global g_decArgo_paramTrajAdjId;
global g_decArgo_juldTrajAdjInfo;
global g_decArgo_juldTrajAdjId;

% parameter added "on the fly" to meta-data file
global g_decArgo_addParamListCtd;
global g_decArgo_addParamListOxygen;
global g_decArgo_addParamListPh;
global g_decArgo_addParamListChla;
global g_decArgo_addParamListBackscattering;
global g_decArgo_addParamListCdom;
global g_decArgo_addParamListRadiometry;
global g_decArgo_addParamListCp;
global g_decArgo_addParamListTurbidity;

% directory of json meta-data files
global g_decArgo_dirInputJsonFloatMetaDataFile;

% json meta-data
global g_decArgo_jsonMetaData;


% get floats information
if ((g_decArgo_realtimeFlag == 0) && (g_decArgo_delayedModeFlag == 0))
   [listWmoNum, listDecId, listArgosId, listFrameLen, ...
      listCycleTime, listDriftSamplingPeriod, listDelay, ...
      listLaunchDate, listLaunchLon, listLaunchLat, ...
      listRefDay, listEndDate, listDmFlag] = get_floats_info(g_decArgo_floatInformationFileName);
end

% decode the floats of the "a_floatList" list
nbFloats = length(a_floatList);
for idFloat = 1:nbFloats
   
   % initialized whatever the float transmission type is
   % (will be used in get_meas_location)
   g_decArgo_floatSurfData = [];
   g_decArgo_gpsData = [];
   g_decArgo_iridiumMailData = [];
   
   g_decArgo_spoolFileList = [];
   g_decArgo_bufFileList = [];
   g_decArgo_floatLaunchDate = '';
   g_decArgo_floatLaunchLon = '';
   g_decArgo_floatLaunchLat = '';
   
   g_decArgo_paramProfAdjInfo = [];
   g_decArgo_paramProfAdjId = 1;
   g_decArgo_paramTrajAdjInfo = [];
   g_decArgo_paramTrajAdjId = 1;
   g_decArgo_juldTrajAdjInfo = [];
   g_decArgo_juldTrajAdjId = 1;
   
   g_decArgo_addParamListCtd = [];
   g_decArgo_addParamListOxygen = [];
   g_decArgo_addParamListPh = [];
   g_decArgo_addParamListChla = [];
   g_decArgo_addParamListBackscattering = [];
   g_decArgo_addParamListCdom = [];
   g_decArgo_addParamListRadiometry = [];
   g_decArgo_addParamListCp = [];
   g_decArgo_addParamListTurbidity = [];
   
   floatNum = a_floatList(idFloat);
   g_decArgo_floatNum = floatNum;

   if (g_decArgo_realtimeFlag == 0)
      fprintf('\n%03d/%03d %d\n', idFloat, nbFloats, floatNum);
   end
   
   % find current float information
   if ((g_decArgo_realtimeFlag == 0) && (g_decArgo_delayedModeFlag == 0))
      idF = find(listWmoNum == floatNum, 1);
      if (isempty(idF))
         fprintf('ERROR: No information on float #%d - nothing done\n', floatNum);
         continue
      end
      
      floatArgosId = char(listArgosId(idF));
      floatDecId = listDecId(idF);
      floatFrameLen = listFrameLen(idF);
      floatCycleTime = double(listCycleTime(idF));
      floatDriftSamplingPeriod = double(listDriftSamplingPeriod(idF));
      floatDelay = double(listDelay(idF));
      floatLaunchDate = listLaunchDate(idF);
      floatLaunchLon = listLaunchLon(idF);
      floatLaunchLat = listLaunchLat(idF);
      floatRefDay = listRefDay(idF);
      floatDmFlag = listDmFlag(idF);
      
      g_decArgo_floatLaunchDate = floatLaunchDate;
      g_decArgo_floatLaunchLon = floatLaunchLon;
      g_decArgo_floatLaunchLat = floatLaunchLat;
   else
      
      [floatNum, floatArgosId, ...
         floatDecVersion, floatDecId, ...
         floatFrameLen, ...
         floatCycleTime, floatDriftSamplingPeriod, floatDelay, ...
         floatLaunchDate, floatLaunchLon, floatLaunchLat, ...
         floatRefDay, floatDmFlag] = get_one_float_info(floatNum, []);
      
      if (isempty(floatArgosId))
         fprintf('ERROR: No information on float #%d - nothing done\n', floatNum);
         continue
      end
      
      g_decArgo_floatLaunchDate = floatLaunchDate;
      g_decArgo_floatLaunchLon = floatLaunchLon;
      g_decArgo_floatLaunchLat = floatLaunchLat;
   end
   
   % check that it is a NOVA float
   if ~((floatDecId > 2000) && (floatDecId < 3000))
      fprintf('ERROR: Float #%d is not a Nova float - not decoded\n', floatNum);
      continue
   end
   
   % read the json meta-data file for this float
   jsonInputFileName = [g_decArgo_dirInputJsonFloatMetaDataFile '/' sprintf('%d_meta.json', g_decArgo_floatNum)];

   if ~(exist(jsonInputFileName, 'file') == 2)
      fprintf('ERROR: Json meta-data file not found: %s - nothing done\n', jsonInputFileName);
      continue
   end

   % read meta-data file
   g_decArgo_jsonMetaData = loadjson(jsonInputFileName);
   
   % set END_DECODING_DATE
   floatEndDate = g_decArgo_dateDef;
   if (isfield(g_decArgo_jsonMetaData, 'END_DECODING_DATE'))
      if (~isempty(g_decArgo_jsonMetaData.END_DECODING_DATE))
         floatEndDate = datenum(g_decArgo_jsonMetaData.END_DECODING_DATE, 'dd/mm/YYYY HH:MM:SS') - g_decArgo_janFirst1950InMatlab;
      end
   end
   
   % read the NetCDF TECH parameter names
   if (isempty(g_decArgo_outputCsvFileId))
      
      % get NetCDF technical parameter list
      [g_decArgo_outputNcParamId, g_decArgo_outputNcParamLabel, g_decArgo_outputNcParamDescription] = ...
         get_nc_tech_parameters_json(g_decArgo_dirInputJsonTechLabelFile, floatDecId);
      
      g_decArgo_outputNcParamLabelInfo = [];
      g_decArgo_outputNcParamLabelInfoCounter = 2;
      
      % get NetCDF configuration parameter list
      [g_decArgo_outputNcConfParamId, g_decArgo_outputNcConfParamLabel, g_decArgo_outputNcConfParamDescription] = ...
         get_nc_config_parameters_json(g_decArgo_dirInputJsonConfLabelFile, floatDecId);
   end
   
   % create list of cycles to decode
   [floatCycleList, floatExcludedCycleList] = ...
      get_float_cycle_list(floatNum, floatArgosId, floatLaunchDate, floatDecId);
   
   % decode float cycles
   tabTechAuxNMeas = [];
   if (g_decArgo_floatTransType == 3)
      
      % Iridium SBD floats
      
      % update GPS data global variable
      if (floatLaunchLon ~= g_decArgo_argosLonDef)
         g_decArgo_gpsData{1} = -1;
         g_decArgo_gpsData{2} = -1;
         g_decArgo_gpsData{3} = -1;
         g_decArgo_gpsData{4} = floatLaunchDate;
         g_decArgo_gpsData{5} = floatLaunchLon;
         g_decArgo_gpsData{6} = floatLaunchLat;
         g_decArgo_gpsData{7} = 0;
         g_decArgo_gpsData{8} = ' ';
         g_decArgo_gpsData{9} = g_decArgo_dateDef;
      end
      
      [tabProfiles, ...
         tabTrajNMeas, tabTrajNCycle, ...
         tabNcTechIndex, tabNcTechVal, tabTechAuxNMeas, ...
         structConfig] = decode_nova_iridium_sbd( ...
         floatNum, floatCycleList, ...
         floatDecId, str2num(floatArgosId), ...
         floatLaunchDate, floatRefDay, floatEndDate);

   else
      fprintf('ERROR: Nothing implemented yet for NOVA non Iridium floats\n');
   end
   
   if (isempty(g_decArgo_outputCsvFileId))
      
      % check consistency of PROF an TRAJ_NMEAS structures
      check_prof_and_traj_struct_consistency(tabProfiles, tabTrajNMeas)

      if (g_decArgo_applyRtqc == 0)
         % remove Qc values set by the decoder
         [tabProfiles, tabTrajNMeas] = remove_data_qc(tabProfiles, tabTrajNMeas);
      end
      
      % save decoded data in NetCDF files
      
      % meta-data used in TRAJ, PROF and TECH NetCDF files
      % when creating the META NetcCDF file the JSON meta-data file is opened
      % and all needed information are copied
      wantedMetaNames = [ ...
         {'PROJECT_NAME'} ...
         {'DATA_CENTRE'} ...
         {'PI_NAME'} ...
         {'FLOAT_SERIAL_NO'} ...
         {'FIRMWARE_VERSION'} ...
         ];
      
      % retrieve information from json meta-data file
      [additionalMetaData] = get_meta_data_from_json_file(floatNum, wantedMetaNames);
      
      % NetCDF MONO-PROFILE files
      if (g_decArgo_generateNcMonoProf ~= 0)
         create_nc_mono_prof_files(floatDecId, ...
            tabProfiles, additionalMetaData);
      end
      
      % NetCDF MULTI-PROFILE files
      if (g_decArgo_generateNcMultiProf ~= 0)
         create_nc_multi_prof_file(floatDecId, ...
            tabProfiles, additionalMetaData);
      end
      
      % NetCDF TRAJ file
      if ((g_decArgo_generateNcTraj31 ~= 0) || (g_decArgo_generateNcTraj32 ~= 0))
         create_nc_traj_file(floatDecId, ...
            tabTrajNMeas, tabTrajNCycle, additionalMetaData);
      end
      
      % NetCDF TECHNICAL file
      if (g_decArgo_generateNcTech ~= 0)
         create_nc_tech_file(floatDecId, ...
            tabNcTechIndex, tabNcTechVal, [], tabTechAuxNMeas, ...
            g_decArgo_outputNcParamLabelInfo, additionalMetaData);
      end
      
      % NetCDF META-DATA file
      if (g_decArgo_generateNcMeta ~= 0)
         create_nc_meta_file(floatDecId, structConfig);
      end
   end
   
   if (isempty(g_decArgo_outputCsvFileId) && (g_decArgo_applyRtqc == 1))
         % apply RTQC to NetCDF profile files
         add_rtqc_flags_to_netcdf_profile_and_trajectory_data( ...
            g_decArgo_reportStruct, floatDecId);
   end
   
   % store the information for the XML report
   if ((g_decArgo_realtimeFlag == 1) || (g_decArgo_delayedModeFlag == 1))
      g_decArgo_reportData = [g_decArgo_reportData g_decArgo_reportStruct];
   end
   
end

return
