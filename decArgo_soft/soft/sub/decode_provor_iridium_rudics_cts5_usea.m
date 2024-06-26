% ------------------------------------------------------------------------------
% Decode PROVOR CTS5-USEA floats.
%
% SYNTAX :
%  [o_tabProfiles, ...
%    o_tabTrajNMeas, o_tabTrajNCycle, ...
%    o_tabNcTechIndex, o_tabNcTechVal, o_tabTechNMeas, ...
%    o_structConfig] = ...
%    decode_provor_iridium_rudics_cts5_usea( ...
%    a_floatNum, a_decoderId, a_floatLoginName, a_launchDate)
%
% INPUT PARAMETERS :
%   a_floatNum       : float WMO number
%   a_decoderId      : float decoder Id
%   a_floatLoginName : float name
%   a_launchDate     : launch date
%
% OUTPUT PARAMETERS :
%   o_tabProfiles    : decoded profiles
%   o_tabTrajNMeas   : decoded trajectory N_MEASUREMENT data
%   o_tabTrajNCycle  : decoded trajectory N_CYCLE data
%   o_tabNcTechIndex : decoded technical index information
%   o_tabNcTechVal   : decoded technical data
%   o_tabTechNMeas   : decoded technical N_MEASUREMENT data
%   o_structConfig   : NetCDF float configuration
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   09/22/2020 - RNU - creation
% ------------------------------------------------------------------------------
function [o_tabProfiles, ...
   o_tabTrajNMeas, o_tabTrajNCycle, ...
   o_tabNcTechIndex, o_tabNcTechVal, o_tabTechNMeas, ...
   o_structConfig] = ...
   decode_provor_iridium_rudics_cts5_usea( ...
   a_floatNum, a_decoderId, a_floatLoginName, a_launchDate)

% output parameters initialization
o_tabProfiles = [];
o_tabTrajNMeas = [];
o_tabTrajNCycle = [];
o_tabNcTechIndex = [];
o_tabNcTechVal = [];
o_tabTechNMeas = [];
o_structConfig = [];

% current float WMO number
global g_decArgo_floatNum;
g_decArgo_floatNum = a_floatNum;

% number used to group traj information
global g_decArgo_trajItemGroupNum;
g_decArgo_trajItemGroupNum = 1;

% number used to group tech PARAM information
global g_decArgo_techItemGroupNum;
g_decArgo_techItemGroupNum = 1;

% output CSV file Id
global g_decArgo_outputCsvFileId;

% output NetCDF technical parameter index information
global g_decArgo_outputNcParamIndex;

% output NetCDF technical parameter values
global g_decArgo_outputNcParamValue;

% output NetCDF technical parameter labels
global g_decArgo_outputNcParamLabelBis;

% decoder configuration values
global g_decArgo_iridiumDataDirectory;

% SBD sub-directories
global g_decArgo_archiveDirectory;
global g_decArgo_historyDirectory;
global g_decArgo_updatedDirectory;
global g_decArgo_unusedDirectory;

% arrays to store decoded calibration coefficient
global g_decArgo_calibInfo;
g_decArgo_calibInfo = [];

% decoder configuration values
global g_decArgo_dirInputRsyncData;

% rsync information
global g_decArgo_rsyncFloatWmoList;
global g_decArgo_rsyncFloatSbdFileList;

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

% report information structure
global g_decArgo_reportStruct;

% already processed rsync log information
global g_decArgo_rsyncLogFileUnderProcessList;
global g_decArgo_rsyncLogFileUsedList;

% generate nc flag
global g_decArgo_generateNcFlag;
g_decArgo_generateNcFlag = 0;

% array to store GPS data
global g_decArgo_gpsData;

% no sampled data mode
global g_decArgo_noDataFlag;
g_decArgo_noDataFlag = 0;

% array to store ko sensor states
global g_decArgo_koSensorState;
g_decArgo_koSensorState = [];

% configuration values
global g_decArgo_applyRtqc;

% prefix of data file names
global g_decArgo_filePrefixCts5;

% number of the first cycle to process
global g_decArgo_firstCycleNumCts5;

% variable to store all useful event data
global g_decArgo_eventData;
g_decArgo_eventData = [];

% decoded event data
global g_decArgo_eventDataTech;
global g_decArgo_eventDataParamTech;
global g_decArgo_eventDataTraj;
global g_decArgo_eventDataMeta;
global g_decArgo_eventDataTime;

% existing cycle and pattern numbers
global g_decArgo_cyclePatternNumFloat;

% current cycle and pattern number
global g_decArgo_cycleNumFloat;
global g_decArgo_cycleNumFloatStr;
global g_decArgo_patternNumFloat;
global g_decArgo_patternNumFloatStr;

% current cycle number
global g_decArgo_cycleNum;

% first float cycle number to consider
global g_decArgo_firstCycleNumFloat;
global g_decArgo_firstCycleNumFloatNew;
global g_decArgo_argoCycleNumForFirstCycleNumFloatNew;
g_decArgo_argoCycleNumForFirstCycleNumFloatNew = [];

% meta-data retrieved from APMT tech files
global g_decArgo_apmtMetaFromTech;
g_decArgo_apmtMetaFromTech = [];

% time data retrieved from APMT tech files
global g_decArgo_apmtTimeFromTech;
g_decArgo_apmtTimeFromTech = [];

% float configuration
global g_decArgo_floatConfig;

% type of files to consider
global g_decArgo_provorCts5UseaFileTypeListAll;
global g_decArgo_fileTypeListCts5;
g_decArgo_fileTypeListCts5 = g_decArgo_provorCts5UseaFileTypeListAll;

% TRAJ 3.2 file generation flag
global g_decArgo_generateNcTraj32;


% create the float directory
floatIriDirName = [g_decArgo_iridiumDataDirectory '/' a_floatLoginName '_' num2str(a_floatNum) '/'];
if ~(exist(floatIriDirName, 'dir') == 7)
   mkdir(floatIriDirName);
end

% create sub-directories:
% - a 'archive' directory used to store the received SBD files
% - a 'updated_files' directory used to store old versions of files that have been updated in the rudics server
% - a 'unused_files' directory used to store files that shold not be used (they need to be deleted from the rudics server)
% IN RT MODE:
% - a 'history_of_processed_data' directory used to store the information on
% previous processings
g_decArgo_archiveDirectory = [floatIriDirName 'archive/'];
if ~(exist(g_decArgo_archiveDirectory, 'dir') == 7)
   mkdir(g_decArgo_archiveDirectory);
end
g_decArgo_updatedDirectory = [g_decArgo_archiveDirectory '/updated_files/']; % to store old versions of files that have been updated in the rudics server
if ~(exist(g_decArgo_updatedDirectory, 'dir') == 7)
   mkdir(g_decArgo_updatedDirectory);
end
g_decArgo_unusedDirectory = [g_decArgo_archiveDirectory '/unused_files/']; % to store files that shold not be used (they need to be deleted from the rudics server)
if ~(exist(g_decArgo_unusedDirectory, 'dir') == 7)
   mkdir(g_decArgo_unusedDirectory);
end
if (g_decArgo_realtimeFlag)
   g_decArgo_historyDirectory = [floatIriDirName 'history_of_processed_data/'];
   if ~(exist(g_decArgo_historyDirectory, 'dir') == 7)
      mkdir(g_decArgo_historyDirectory);
   end
end

% create temporary directory to store concatenated files
floatTmpDirName = [g_decArgo_archiveDirectory '/tmp/'];
if (exist(floatTmpDirName, 'dir') == 7)
   rmdir(floatTmpDirName, 's');
end
mkdir(floatTmpDirName);

% inits for output NetCDF file
if (isempty(g_decArgo_outputCsvFileId))
   g_decArgo_outputNcParamIndex = [];
   g_decArgo_outputNcParamValue = [];
   g_decArgo_outputNcParamLabelBis = [];
end

% inits for output CSV file
if (~isempty(g_decArgo_outputCsvFileId))
   % print CSV header
   header = 'WMO #; Cycle #; Pattern #; File type; Section; Info type';
   fprintf(g_decArgo_outputCsvFileId, '%s\n', header);
end

% add launch position and time in the TRAJ NetCDF file
if (isempty(g_decArgo_outputCsvFileId))
   o_tabTrajNMeas = add_launch_data_ir_rudics;
end

if (g_decArgo_delayedModeFlag)

   fprintf('ERROR: Float #%d is expected to be processed in Real Time Mode\n', ...
      a_floatNum);
   o_tabProfiles = [];
   o_tabTrajNMeas = [];
   o_tabTrajNCycle = [];
   o_tabNcTechIndex = [];
   o_tabNcTechVal = [];
   o_structConfig = [];
   return

end

if (g_decArgo_realtimeFlag)

   % new files have been collected with rsync, we are going to decode
   % all (archived and newly received) files

   % duplicate the files colleted with rsync into the archive directory
   fileIdList = find(g_decArgo_rsyncFloatWmoList == a_floatNum);

   nbFilesTot = 0;
   for idF = 1:length(fileIdList)

      sbdFilePathName = [g_decArgo_dirInputRsyncData '/' ...
         g_decArgo_rsyncFloatSbdFileList{fileIdList(idF)}];
      [pathstr, sbdFileName, ext] = fileparts(sbdFilePathName);
      nbFiles = duplicate_files_ir_cts5({[sbdFileName ext]}, pathstr, g_decArgo_archiveDirectory, a_floatNum);
      nbFilesTot = nbFilesTot + nbFiles;
   end

   fprintf('RSYNC_INFO: Duplicated %d files from rsync dir to float archive dir\n', ...
      nbFilesTot);

   % set file prefix
   g_decArgo_filePrefixCts5 = get_file_prefix_cts5(g_decArgo_archiveDirectory);
end

% initialize float configuration
init_float_config_prv_ir_rudics_cts5_usea(a_decoderId);
if (isempty(g_decArgo_floatConfig))
   return
end

g_decArgo_firstCycleNumFloat = g_decArgo_firstCycleNumCts5;
g_decArgo_firstCycleNumFloatNew = g_decArgo_firstCycleNumCts5;

% print launch configuration in CSV file
if (~isempty(g_decArgo_outputCsvFileId))
   g_decArgo_cycleNumFloatStr = '-';
   g_decArgo_patternNumFloatStr = '-';
   print_config_in_csv_file_ir_rudics_cts5('Launch_config');
end

if ((g_decArgo_realtimeFlag) || (g_decArgo_delayedModeFlag) || ...
      (isempty(g_decArgo_outputCsvFileId) && (g_decArgo_applyRtqc)))
   % initialize data structure to store report information
   g_decArgo_reportStruct = get_report_init_struct(a_floatNum, '');
end

% find cycle and (cycle,ptn) from available files
% get payload configuration files
[floatCycleList, g_decArgo_cyclePatternNumFloat] = get_cycle_ptn_cts5_usea;

% read and store clock offset information from technical data (in g_decArgo_useaTechData)
read_apmt_technical_data(floatCycleList, g_decArgo_cyclePatternNumFloat, g_decArgo_filePrefixCts5, a_decoderId, 1);

% retrieve event data
ok = get_event_data_cts5(g_decArgo_cyclePatternNumFloat, a_launchDate, a_decoderId);
if (~ok)
   return
end

% read and store technical data (in g_decArgo_useaTechData)
read_apmt_technical_data(floatCycleList, g_decArgo_cyclePatternNumFloat, g_decArgo_filePrefixCts5, a_decoderId, 0);

% few floats are located with Iridium system
% store Iridium locations information in g_decArgo_iridiumMailData
% specific
if (ismember(g_decArgo_floatNum, [ ...
      5906972, 6903093]))
   collect_iridium_locations_cs5;
end

% process available files
stop = 0;
for idFlCy = 1:length(floatCycleList)
   floatCyNum = floatCycleList(idFlCy);

   if (floatCyNum < g_decArgo_firstCycleNumFloat)
      continue
   end

   if (floatCyNum == g_decArgo_firstCycleNumFloat)
      g_decArgo_cycleNum = 0;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % get files (without pattern #) to process

   fileToProcess = get_received_file_list_usea(floatCyNum, [], g_decArgo_filePrefixCts5);

   if (~isempty(fileToProcess))
      fprintf('\nDEC_INFO: Float #%d: Processing cycle #%d (float cycle #%d)\n', ...
         g_decArgo_floatNum, g_decArgo_cycleNum, floatCyNum);

      if (g_decArgo_realtimeFlag == 1)
         % update the reports structure cycle list
         g_decArgo_reportStruct = add_cycle_number_in_report_struct(g_decArgo_reportStruct, g_decArgo_cycleNum);
      end
   end

   if (~stop)

      g_decArgo_eventDataTech = [];
      g_decArgo_eventDataParamTech = [];
      g_decArgo_eventDataTraj = [];
      g_decArgo_eventDataMeta = [];
      g_decArgo_eventDataTime = [];

      g_decArgo_cycleNumFloat = floatCyNum;
      g_decArgo_cycleNumFloatStr = num2str(floatCyNum);
      g_decArgo_patternNumFloat = [];
      g_decArgo_patternNumFloatStr = '-';

      [tabProfiles, ...
         tabDrift, tabDesc2Prof, tabDeepDrift, tabSurf, subSurfaceMeas, trajDataFromApmtTech, ...
         tabNcTechIndex, tabNcTechVal, tabTechNMeas] = ...
         decode_files(fileToProcess, a_decoderId);

      if (isempty(g_decArgo_outputCsvFileId))

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % ADJUST BGC TIMES

         if (ismember(a_decoderId, [126:128])) % not done for tabDeepDrift (firts data of this phase with decId #129)
            [tabProfiles, tabDrift, tabSurf, tabNcTechIndex2, tabNcTechVal2] = ...
               adjust_bgc_time_cts5_usea(tabProfiles, tabDrift, tabSurf, trajDataFromApmtTech);
            if (~isempty(tabNcTechIndex2))
               tabNcTechIndex = [tabNcTechIndex; tabNcTechIndex2];
               tabNcTechVal = [tabNcTechVal; tabNcTechVal2];
            end
         end

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % ADJUST BGC PRES

         % adjust BGC pressures sampled during drift phase
         % and SUNA profile pressures
         if (ismember(a_decoderId, [126:133]))
            [tabProfiles, tabDrift, tabDeepDrift] = adjust_bgc_pres_cts5_usea(tabProfiles, tabDrift, tabDeepDrift);
         end

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % TRAJ NetCDF file

         % collect trajectory data for TRAJ NetCDF file
         [tabTrajIndex, tabTrajData] = collect_trajectory_data_cts5_usea( ...
            tabProfiles, tabDrift, tabDesc2Prof, tabDeepDrift, tabSurf, trajDataFromApmtTech, subSurfaceMeas);

         % process trajectory data for TRAJ NetCDF file
         [tabTrajNMeas, tabTrajNCycle] = process_trajectory_data_cts5_usea( ...
            tabTrajIndex, tabTrajData, g_decArgo_firstCycleNumFloat);

         % sort trajectory data structures according to the predefined
         % measurement code order
         %    [tabTrajNMeas] = sort_trajectory_data_cyprofnum(tabTrajNMeas, a_decoderId);
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         if (~isempty(tabProfiles))
            o_tabProfiles = [o_tabProfiles tabProfiles];
         end
         if (~isempty(tabTrajNMeas))
            o_tabTrajNMeas = [o_tabTrajNMeas tabTrajNMeas];
         end
         if (~isempty(tabTrajNCycle))
            o_tabTrajNCycle = [o_tabTrajNCycle tabTrajNCycle];
         end
         if (~isempty(tabNcTechIndex))
            o_tabNcTechIndex = [o_tabNcTechIndex; tabNcTechIndex];
            o_tabNcTechVal = [o_tabNcTechVal; tabNcTechVal];
         end
         if (~isempty(tabTechNMeas))
            o_tabTechNMeas = [o_tabTechNMeas tabTechNMeas];
         end
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % get files (with pattern #) to process
      idF = find(g_decArgo_cyclePatternNumFloat(:, 1) == floatCyNum);
      for idFlCyPtn = 1:length(idF)
         floatPtnNum = g_decArgo_cyclePatternNumFloat(idF(idFlCyPtn), 2);

         % retrieve useful information from event data
         decode_event_data_cts5(floatCyNum, floatPtnNum);

         % get files to process
         fileToProcess = get_received_file_list_usea(floatCyNum, floatPtnNum, g_decArgo_filePrefixCts5);

         if (~stop)

            if (floatPtnNum > 0)
               g_decArgo_cycleNum = g_decArgo_cycleNum + 1;

               fprintf('\nDEC_INFO: Float #%d: Processing cycle #%d (float cycle #%d)\n', ...
                  g_decArgo_floatNum, g_decArgo_cycleNum, floatCyNum);

               if (g_decArgo_realtimeFlag == 1)
                  % update the reports structure cycle list
                  g_decArgo_reportStruct = add_cycle_number_in_report_struct(g_decArgo_reportStruct, g_decArgo_cycleNum);
               end
            end
            g_decArgo_patternNumFloat = floatPtnNum;
            g_decArgo_patternNumFloatStr = num2str(floatPtnNum);

            [tabProfiles, ...
               tabDrift, tabDesc2Prof, tabDeepDrift, tabSurf, subSurfaceMeas, trajDataFromApmtTech, ...
               tabNcTechIndex, tabNcTechVal, tabTechNMeas] = ...
               decode_files(fileToProcess, a_decoderId);

            if (isempty(g_decArgo_outputCsvFileId))

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % ADJUST BGC TIMES

               if (ismember(a_decoderId, [126:128])) % not done for tabDeepDrift (firts data of this phase with decId #129)
                  [tabProfiles, tabDrift, tabSurf, tabNcTechIndex2, tabNcTechVal2] = ...
                     adjust_bgc_time_cts5_usea(tabProfiles, tabDrift, tabSurf, trajDataFromApmtTech);
                  if (~isempty(tabNcTechIndex2))
                     tabNcTechIndex = [tabNcTechIndex; tabNcTechIndex2];
                     tabNcTechVal = [tabNcTechVal; tabNcTechVal2];
                  end
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % ADJUST BGC PRES

               % adjust BGC pressures sampled during drift phase
               % and SUNA profile pressures
               if (ismember(a_decoderId, [126:133]))
                  [tabProfiles, tabDrift, tabDeepDrift] = adjust_bgc_pres_cts5_usea(tabProfiles, tabDrift, tabDeepDrift);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % TRAJ NetCDF file

               % collect trajectory data for TRAJ NetCDF file
               [tabTrajIndex, tabTrajData] = collect_trajectory_data_cts5_usea( ...
                  tabProfiles, tabDrift, tabDesc2Prof, tabDeepDrift, tabSurf, trajDataFromApmtTech, subSurfaceMeas);

               % process trajectory data for TRAJ NetCDF file
               [tabTrajNMeas, tabTrajNCycle] = process_trajectory_data_cts5_usea( ...
                  tabTrajIndex, tabTrajData, g_decArgo_firstCycleNumFloat);

               % sort trajectory data structures according to the predefined
               % measurement code order
               %    [tabTrajNMeas] = sort_trajectory_data_cyprofnum(tabTrajNMeas, a_decoderId);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

               if (~isempty(tabProfiles))
                  o_tabProfiles = [o_tabProfiles tabProfiles];
               end
               if (~isempty(tabTrajNMeas))
                  o_tabTrajNMeas = [o_tabTrajNMeas tabTrajNMeas];
               end
               if (~isempty(tabTrajNCycle))
                  o_tabTrajNCycle = [o_tabTrajNCycle tabTrajNCycle];
               end
               if (~isempty(tabNcTechIndex))
                  o_tabNcTechIndex = [o_tabNcTechIndex; tabNcTechIndex];
                  o_tabNcTechVal = [o_tabNcTechVal; tabNcTechVal];
               end
               if (~isempty(tabTechNMeas))
                  o_tabTechNMeas = [o_tabTechNMeas tabTechNMeas];
               end
            end
         end
      end
   end
end

if (isempty(g_decArgo_outputCsvFileId))

   % output NetCDF files

   % add interpolated/extrapolated profile locations
   [o_tabProfiles] = fill_empty_profile_locations_cts5_ir_rudics(o_tabProfiles, g_decArgo_gpsData, ...
      o_tabTrajNMeas, o_tabTrajNCycle);

   % cut CTD profile at the cut-off pressure of the CTD pump
   [o_tabProfiles] = cut_ctd_profile_ir_rudics(o_tabProfiles);

   % create output float configuration
   [o_structConfig] = create_output_float_config_ir_rudics_cts5_usea(a_decoderId);

   % add configuration number and output cycle number
   [o_tabProfiles, o_tabTrajNMeas, o_tabTrajNCycle, o_tabTechNMeas] = ...
      add_configuration_number_ir_rudics_cts5( ...
      o_tabProfiles, o_tabTrajNMeas, o_tabTrajNCycle, o_tabTechNMeas);

   % add MTIME to profiles
   o_tabProfiles = finalize_profile_ir_rudics_cts5(o_tabProfiles);

   % merge multiple N_CYCLE and N_MEAS records for a given output cycle number
   % and add not present (but expected for this float family) Measurement Codes
   [o_tabTrajNMeas, o_tabTrajNCycle] = finalize_trajectory_data_ir_rudics_cts5( ...
      o_tabTrajNMeas, o_tabTrajNCycle);

   % update N_CYCLE arrays so that N_CYCLE and N_MEASUREMENT arrays are
   % consistent
   [o_tabTrajNMeas, o_tabTrajNCycle] = set_n_cycle_vs_n_meas_consistency(o_tabTrajNMeas, o_tabTrajNCycle);

   % perform PARAMETER adjustment
   [o_tabProfiles, o_tabTrajNMeas, o_tabTrajNCycle] = ...
      compute_rt_adjusted_param(o_tabProfiles, o_tabTrajNMeas, o_tabTrajNCycle, a_launchDate, 1, a_decoderId);

   if (g_decArgo_generateNcTraj32 ~= 0)
      % report profile PARAMETER adjustments in TRAJ data
      [o_tabTrajNMeas, o_tabTrajNCycle] = report_rt_adjusted_profile_data_in_trajectory( ...
         o_tabTrajNMeas, o_tabTrajNCycle, o_tabProfiles);
   end

   if (g_decArgo_realtimeFlag == 1)

      % save the list of already processed rsync log files in the history
      % directory of the float
      write_processed_rsync_log_file_ir_rudics_sbd_sbd2(a_floatNum, 'processed', ...
         g_decArgo_rsyncLogFileUnderProcessList);

      % save the list of used rsync log files in the history directory of the float
      write_processed_rsync_log_file_ir_rudics_sbd_sbd2(a_floatNum, 'used', ...
         unique(g_decArgo_rsyncLogFileUsedList));
   end

   % add float cycle and pattern number + Ice detected bit to the NetCDF
   % technical data
   [o_tabNcTechIndex, o_tabNcTechVal] = ...
      update_technical_data_ir_rudics_cts5( ...
      o_tabNcTechIndex, o_tabNcTechVal, g_decArgo_firstCycleNumCts5);
end

return

% ------------------------------------------------------------------------------
% Decode a set of PROVOR CTS5-USEA files.
%
% SYNTAX :
% [o_tabProfiles, ...
%   o_tabDrift, o_tabDesc2Prof, o_tabDeepDrift, o_tabSurf, o_subSurfaceMeas, ...
%   o_trajDataFromApmtTech, ...
%   o_tabNcTechIndex, o_tabNcTechVal, o_tabTechNMeas] = ...
%   decode_files(a_fileNameList, a_decoderId)
%
% INPUT PARAMETERS :
%   a_fileNameList  : list of files to decode
%   a_decoderId     : float decoder Id
%
% OUTPUT PARAMETERS :
%   o_tabProfiles          : decoded profiles
%   o_tabDrift             : decoded drift measurement data
%   o_tabDesc2Prof         : decoded descent 2 prof measurement data
%   o_tabDeepDrift         : decoded deep drift measurement data
%   o_tabSurf              : decoded surface measurement data
%   o_subSurfaceMeas       : decoded unique sub surface measurement
%   o_trajDataFromApmtTech : decoded TRAJ relevent technical data
%   o_tabNcTechIndex       : decoded technical index information
%   o_tabNcTechVal         : decoded technical data
%   o_tabTechNMeas         : decoded technical N_MEASUREMENT data
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   09/22/2020 - RNU - creation
% ------------------------------------------------------------------------------
function [o_tabProfiles, ...
   o_tabDrift, o_tabDesc2Prof, o_tabDeepDrift, o_tabSurf, o_subSurfaceMeas, ...
   o_trajDataFromApmtTech, ...
   o_tabNcTechIndex, o_tabNcTechVal, o_tabTechNMeas] = ...
   decode_files(a_fileNameList, a_decoderId)

% output parameters initialization
o_tabProfiles = [];
o_tabDrift = [];
o_tabDesc2Prof = [];
o_tabDeepDrift = [];
o_tabSurf = [];
o_subSurfaceMeas = [];
o_trajDataFromApmtTech = [];
o_tabNcTechIndex = [];
o_tabNcTechVal = [];
o_tabTechNMeas = [];

% current float WMO number
global g_decArgo_floatNum;

% current cycle number
global g_decArgo_cycleNum;

% output CSV file Id
global g_decArgo_outputCsvFileId;

% SBD sub-directories
global g_decArgo_archiveDirectory;

% generate nc flag
global g_decArgo_generateNcFlag;

% array to store GPS data
global g_decArgo_gpsData;

% cycle phases
global g_decArgo_phasePreMission;
global g_decArgo_phaseSatTrans;
global g_decArgo_phaseEndOfLife;

% current cycle and pattern number
global g_decArgo_cycleNumFloat;
global g_decArgo_cycleNumFloatStr;
global g_decArgo_patternNumFloat;
global g_decArgo_patternNumFloatStr;

% prefix of data file names
global g_decArgo_filePrefixCts5;

% type of files to consider
global g_decArgo_fileTypeListCts5;

% meta-data retrieved from APMT tech files
global g_decArgo_apmtMetaFromTech;

% time data retrieved from APMT tech files
global g_decArgo_apmtTimeFromTech;

% array to store Iridium mail contents
global g_decArgo_iridiumMailData;


if (isempty(a_fileNameList))
   return
end

% set the type of each file
fileNames = a_fileNameList;
fileTypes = zeros(size(fileNames));
for idF = 1:length(fileNames)
   fileName = fileNames{idF};
   if (~isempty(g_decArgo_patternNumFloat))
      typeList = fliplr([1 2 4:24]); % types with pattern # (fliplr so that ramses2 is checked before ramses)
      for idType = typeList
         idFL = find([g_decArgo_fileTypeListCts5{:, 1}] == idType);
         if (length(fileName) > g_decArgo_fileTypeListCts5{idFL, 4})
            [val, count, errmsg, nextindex] = sscanf( ...
               fileName(1:g_decArgo_fileTypeListCts5{idFL, 4}), ...
               [g_decArgo_filePrefixCts5 g_decArgo_fileTypeListCts5{idFL, 3}]);
            if (isempty(errmsg) && (count == 2))
               if (strcmp(fileName(end-3:end), g_decArgo_fileTypeListCts5{idFL, 2}(end-3:end)))
                  fileTypes(idF) = idType;
                  break
               end
            end
         end
      end
   else
      if (strncmp(fileName, g_decArgo_filePrefixCts5, length(g_decArgo_filePrefixCts5)))
         typeList = [3]; % types without pattern #
         for idType = typeList
            idFL = find([g_decArgo_fileTypeListCts5{:, 1}] == idType);
            if (length(fileName) > g_decArgo_fileTypeListCts5{idFL, 4})
               [val, count, errmsg, nextindex] = sscanf( ...
                  fileName(1:g_decArgo_fileTypeListCts5{idFL, 4}), ...
                  [g_decArgo_filePrefixCts5 g_decArgo_fileTypeListCts5{idFL, 3}]);
               if (isempty(errmsg) && (count == 1))
                  fileTypes(idF) = idType;
                  break
               end
            end
         end
      end
   end
end

% do not consider metadata.xml (already used at float declaration)
idXmlFile = find(fileTypes == 2);
fileNames(idXmlFile) = [];
fileTypes(idXmlFile) = [];

% set the configuration only if data has been received
if (~isempty(intersect(fileTypes, 6:24)))
   % we should set the configuration before decoding apmt configuration
   % (which concerns the next cycle and pattern)
   set_float_config_ir_rudics_cts5_usea(g_decArgo_cycleNumFloat, g_decArgo_patternNumFloat);
end

% the files should be processed in the following order
typeOrderList = [3 4 6:24 5 1];
% 3, 4, 6 to 24, 5: usual order i.e. tech first, data after and EOL at the end
% 1: last the apmt configuration because it concerns the next cycle and pattern

% process the files
fprintf('DEC_INFO: decoding files:\n');
apmtCtd = [];
apmtDo = [];
apmtEco = [];
apmtOcr = [];
apmtUvpLpm = [];
apmtUvpLpmV2 = [];
apmtUvpBlack = [];
apmtUvpBlackV2 = [];
apmtUvpTaxoV2 = [];
apmtSbeph = [];
apmtCrover = [];
apmtSuna = [];
apmtOpusLight = [];
apmtOpusBlack = [];
apmtRamses = [];
apmtRamses2 = [];
apmtMpe = [];
apmtHydrocM = [];
apmtHydrocC = [];
apmtImuRaw = [];
apmtImuTiltHeading = [];
apmtImuWave = [];

apmtTimeFromTech = [];
techDataFromApmtTech = [];
timeDataFromApmtTech = [];
for typeNum = typeOrderList

   idFileForType = find(fileTypes == typeNum);
   if (~isempty(idFileForType))

      fileNamesForType = fileNames(idFileForType);
      for idFile = 1:length(fileNamesForType)

         % manage split files
         [~, fileName, fileExtension] = fileparts(fileNamesForType{idFile});
         fileNameInfo = manage_split_files({g_decArgo_archiveDirectory}, ...
            {[fileName '*' fileExtension]}, a_decoderId);

         % decode files
         switch (typeNum)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 1
               % '*_apmt*.ini'

               % apmt configuration file

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));

               % read apmt configuration
               apmtConfig = read_apmt_config([fileNameInfo{4} fileNameInfo{1}], a_decoderId);

               % update current configuration
               update_float_config_ir_rudics_cts5_usea(apmtConfig);

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  % print apmt configuration in CSV file
                  print_apmt_config_in_csv_file_ir_rudics_cts5(apmtConfig);

                  % print updated configuration in CSV file
                  print_config_in_csv_file_ir_rudics_cts5('Updated_config');
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {3, 4, 5}
               % '*_autotest_*.txt'
               % '*_technical*.txt'
               % '*_default_*.txt'

               % apmt technical information

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));

               [apmtTech, apmtTimeFromTech, ...
                  ncApmtTech, apmtTrajFromTech, apmtMetaFromTech] = ...
                  get_apmt_technical_file(fileNameInfo{1});
               g_decArgo_apmtMetaFromTech = [g_decArgo_apmtMetaFromTech apmtMetaFromTech];
               if (~isempty(g_decArgo_patternNumFloat))
                  g_decArgo_apmtTimeFromTech = cat(1, g_decArgo_apmtTimeFromTech, ...
                     [g_decArgo_cycleNumFloat g_decArgo_patternNumFloat {apmtTimeFromTech}]);
               end

               % store GPS data
               store_gps_data_ir_rudics_cts5(apmtTech, typeNum);

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_apmt_tech_in_csv_file_ir_rudics_cts5(apmtTech, typeNum);

                  if (~isempty(g_decArgo_iridiumMailData))
                     print_iridium_locations_in_csv_file_ir_rudics_cts5(g_decArgo_cycleNumFloat, g_decArgo_patternNumFloat);
                  end

                  % store TIME information
                  if (~isempty(apmtTimeFromTech))
                     cycleNumFloat = g_decArgo_cycleNumFloat;
                     patternNumFloat = g_decArgo_patternNumFloat;
                     if (isempty(patternNumFloat))
                        patternNumFloat = 0;
                     end
                     timeDataFromApmtTech = [timeDataFromApmtTech;
                        [cycleNumFloat patternNumFloat {apmtTimeFromTech}]];
                  end

               else

                  % store TECH and TRAJ information
                  if (~isempty(apmtTrajFromTech) || ~isempty(ncApmtTech))
                     cycleNumFloat = g_decArgo_cycleNumFloat;
                     patternNumFloat = g_decArgo_patternNumFloat;
                     if (isempty(patternNumFloat))
                        patternNumFloat = 0;
                     end
                     if (typeNum == 3)
                        cyclePhase = g_decArgo_phasePreMission;
                     elseif (typeNum == 4)
                        cyclePhase = g_decArgo_phaseSatTrans;
                     elseif (typeNum == 5)
                        cyclePhase = g_decArgo_phaseEndOfLife;
                     end
                     if (~isempty(ncApmtTech))
                        techDataFromApmtTech = [techDataFromApmtTech;
                           [cycleNumFloat patternNumFloat cyclePhase {ncApmtTech}]];
                     end
                     if (~isempty(apmtTrajFromTech))
                        o_trajDataFromApmtTech = [o_trajDataFromApmtTech;
                           [cycleNumFloat patternNumFloat cyclePhase {apmtTrajFromTech}]];
                     end
                  end
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 6
               % '*_sbe41*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtCtd = decode_apmt_ctd(fileNameInfo, a_decoderId);
               if (isempty(apmtCtd))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_CTD(apmtCtd);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 7
               % '*_do*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtDo = decode_apmt_do(fileNameInfo);
               if (isempty(apmtDo))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_DO(apmtDo);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 8
               % '*_eco*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtEco = decode_apmt_eco(fileNameInfo);
               if (isempty(apmtEco))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_ECO(apmtEco, a_decoderId);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 9
               % '*_ocr*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtOcr = decode_apmt_ocr(fileNameInfo);
               if (isempty(apmtOcr))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_OCR(apmtOcr, a_decoderId);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {10, 11, 21}
               % '*_uvp6_blk*.hex'
               % '*_uvp6_lpm*.hex'
               % '*_uvp6_txo*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               [apmtUvpLpmDec, apmtUvpLpmV2Dec, ...
                  apmtUvpBlackDec, apmtUvpBlackV2Dec, ...
                  apmtUvpTaxoV2Dec] = decode_apmt_uvp(fileNameInfo);
               if (isempty(apmtUvpLpmDec) && isempty(apmtUvpLpmV2Dec) && ...
                     isempty(apmtUvpBlackDec) && isempty(apmtUvpBlackV2Dec) && ...
                     isempty(apmtUvpTaxoV2Dec))
                  continue
               end

               if (~isempty(apmtUvpLpmDec))
                  apmtUvpLpm = apmtUvpLpmDec;
               end
               if (~isempty(apmtUvpLpmV2Dec))
                  apmtUvpLpmV2 = apmtUvpLpmV2Dec;
               end
               if (~isempty(apmtUvpBlackDec))
                  apmtUvpBlack = apmtUvpBlackDec;
               end
               if (~isempty(apmtUvpBlackV2Dec))
                  apmtUvpBlackV2 = apmtUvpBlackV2Dec;
               end
               if (~isempty(apmtUvpTaxoV2Dec))
                  apmtUvpTaxoV2 = apmtUvpTaxoV2Dec;
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_UVP( ...
                     apmtUvpLpmDec, apmtUvpLpmV2Dec, ...
                     apmtUvpBlackDec, apmtUvpBlackV2Dec, ...
                     apmtUvpTaxoV2Dec);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 12
               % '*_crover*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtCrover = decode_apmt_crover(fileNameInfo);
               if (isempty(apmtCrover))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_CROVER(apmtCrover);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 13
               % '*_sbeph*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtSbeph = decode_apmt_sbeph(fileNameInfo);
               if (isempty(apmtSbeph))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_SBEPH(apmtSbeph);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 14
               % '*_suna*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtSuna = decode_apmt_suna(fileNameInfo);
               if (isempty(apmtSuna))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_SUNA(apmtSuna);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {15, 16}
               % '*_opus_blk*.hex'
               % '*_opus_lgt*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               [apmtOpusLightDec, apmtOpusBlackDec] = decode_apmt_opus(fileNameInfo);
               if (isempty(apmtOpusLightDec) && isempty(apmtOpusBlackDec))
                  continue
               end

               if (~isempty(apmtOpusLightDec))
                  apmtOpusLight = apmtOpusLightDec;
               end
               if (~isempty(apmtOpusBlackDec))
                  apmtOpusBlack = apmtOpusBlackDec;
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end
                  print_data_in_csv_file_ir_rudics_cts5_OPUS(apmtOpusLightDec, apmtOpusBlackDec);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {17, 22}
               % '*_ramses*.hex'
               % '*_ramses2*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               [apmtRamsesDec, apmtRamses2Dec] = decode_apmt_ramses(fileNameInfo);
               if (isempty(apmtRamsesDec) && isempty(apmtRamses2Dec))
                  continue
               end

               if (~isempty(apmtRamsesDec))
                  apmtRamses = apmtRamsesDec;
               end
               if (~isempty(apmtRamses2Dec))
                  apmtRamses2 = apmtRamses2Dec;
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_RAMSES(apmtRamsesDec, apmtRamses2Dec);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 18
               % '*_mpe*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               apmtMpe = decode_apmt_mpe(fileNameInfo);
               if (isempty(apmtMpe))
                  continue
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end

                  print_data_in_csv_file_ir_rudics_cts5_MPE(apmtMpe);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {19, 20}
               % '*_hydroc_c*.hex'
               % '*_hydroc_m*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               [apmtHydrocMDec, apmtHydrocCDec] = decode_apmt_hydroc(fileNameInfo);
               if (isempty(apmtHydrocMDec) && isempty(apmtHydrocCDec))
                  continue
               end

               if (~isempty(apmtHydrocMDec))
                  apmtHydrocM = apmtHydrocMDec;
               end
               if (~isempty(apmtHydrocCDec))
                  apmtHydrocC = apmtHydrocCDec;
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end
                  print_data_in_csv_file_ir_rudics_cts5_HYDROC(apmtHydrocMDec, apmtHydrocCDec);
               end

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {23, 24}
               % '*_imu*.hex'
               % '*_wave*.hex'

               fprintf('   - %s (%d)\n', fileNamesForType{idFile}, length(fileNameInfo{2}));
               [apmtImuRawDec, apmtImuTiltHeadingDec, ...
                  apmtImuWaveDec] = decode_apmt_imu(fileNameInfo);
               if (isempty(apmtImuRawDec) && isempty(apmtImuTiltHeadingDec) && ...
                     isempty(apmtImuWaveDec))
                  continue
               end

               if (~isempty(apmtImuRawDec))
                  apmtImuRaw = apmtImuRawDec;
               end
               if (~isempty(apmtImuTiltHeadingDec))
                  apmtImuTiltHeading = apmtImuTiltHeadingDec;
               end
               if (~isempty(apmtImuWaveDec))
                  apmtImuWave = apmtImuWaveDec;
               end

               if (~isempty(g_decArgo_outputCsvFileId))

                  for idFile2 = 1:length(fileNameInfo{2})
                     fprintf(g_decArgo_outputCsvFileId, '%d; %s; %s; File name; -; %s\n', ...
                        g_decArgo_floatNum, g_decArgo_cycleNumFloatStr, g_decArgo_patternNumFloatStr, ...
                        fileNameInfo{2}{idFile2});
                  end
                  print_data_in_csv_file_ir_rudics_cts5_IMU(apmtImuRawDec, apmtImuTiltHeadingDec, apmtImuWaveDec);
               end

            otherwise
               fprintf('WARNING: Nothing define yet to process file: %s\n', ...
                  fileNamesForType{idFile});
         end
      end

      fileNames(idFileForType) = [];
      fileTypes(idFileForType) = [];

      if (isempty(fileNames))
         break
      end
   end
end

if (~isempty(fileNames))
   fprintf('DEC_WARNING: %d files were not processed\n', ...
      length(fileNames));
end

if (~isempty(g_decArgo_outputCsvFileId))

   % print time data in csv file
   print_dates_in_csv_file_ir_rudics_cts5_usea( ...
      timeDataFromApmtTech, apmtCtd, apmtDo, apmtEco, apmtOcr, ...
      apmtUvpLpm, apmtUvpLpmV2, apmtUvpBlack, apmtUvpBlackV2, apmtUvpTaxoV2, ...
      apmtSbeph, apmtCrover, apmtSuna, apmtOpusLight, apmtOpusBlack, ...
      apmtRamses, apmtRamses2, apmtMpe, ...
      apmtHydrocM, apmtHydrocC, ...
      apmtImuRaw, apmtImuTiltHeading, apmtImuWave);
end

% output NetCDF data
if (isempty(g_decArgo_outputCsvFileId))

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtCtd))

      % create profiles (as they are transmitted)
      [tabProfilesCtd, tabDriftCtd, tabDesc2ProfCtd, tabDeepDriftCtd, tabSurfCtd, o_subSurfaceMeas] = ...
         process_profile_ir_rudics_cts5_usea_ctd(apmtCtd, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesCtd] = merge_profile_meas_ir_rudics_cts5_usea_ctd(tabProfilesCtd);

      % add the vertical sampling scheme from configuration information
      [tabProfilesCtd] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_ctd(tabProfilesCtd);

      o_tabProfiles = [o_tabProfiles tabProfilesCtd];
      o_tabDrift = [o_tabDrift tabDriftCtd];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfCtd];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftCtd];
      o_tabSurf = [o_tabSurf tabSurfCtd];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtDo))

      % create profiles (as they are transmitted)
      [tabProfilesDo, tabDriftDo, tabDesc2ProfDo, tabDeepDriftDo, tabSurfDo] = ...
         process_profile_ir_rudics_cts5_usea_do(apmtDo, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesDo] = merge_profile_meas_ir_rudics_cts5_usea_do(tabProfilesDo);

      % add the vertical sampling scheme from configuration information
      [tabProfilesDo] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesDo);

      o_tabProfiles = [o_tabProfiles tabProfilesDo];
      o_tabDrift = [o_tabDrift tabDriftDo];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfDo];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftDo];
      o_tabSurf = [o_tabSurf tabSurfDo];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtOcr))

      % create profiles (as they are transmitted)
      [tabProfilesOcr, tabDriftOcr, tabDesc2ProfOcr, tabDeepDriftOcr, tabSurfOcr] = ...
         process_profile_ir_rudics_cts5_usea_ocr(apmtOcr, apmtTimeFromTech, g_decArgo_gpsData, a_decoderId);

      % merge profiles (all data from a given sensor together)
      [tabProfilesOcr] = merge_profile_meas_ir_rudics_cts5_usea_ocr(tabProfilesOcr, a_decoderId);

      % add the vertical sampling scheme from configuration information
      [tabProfilesOcr] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesOcr);

      o_tabProfiles = [o_tabProfiles tabProfilesOcr];
      o_tabDrift = [o_tabDrift tabDriftOcr];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfOcr];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftOcr];
      o_tabSurf = [o_tabSurf tabSurfOcr];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtEco))

      % create profiles (as they are transmitted)
      [tabProfilesEco, tabDriftEco, tabDesc2ProfEco, tabDeepDriftEco, tabSurfEco] = ...
         process_profile_ir_rudics_cts5_usea_eco(apmtEco, apmtTimeFromTech, g_decArgo_gpsData, a_decoderId);

      % merge profiles (all data from a given sensor together)
      [tabProfilesEco] = merge_profile_meas_ir_rudics_cts5_usea_eco(tabProfilesEco, a_decoderId);

      % add the vertical sampling scheme from configuration information
      [tabProfilesEco] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesEco);

      o_tabProfiles = [o_tabProfiles tabProfilesEco];
      o_tabDrift = [o_tabDrift tabDriftEco];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfEco];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftEco];
      o_tabSurf = [o_tabSurf tabSurfEco];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtSbeph))

      % create profiles (as they are transmitted)
      [tabProfilesSbeph, tabDriftSbeph, tabDesc2ProfSbeph, tabDeepDriftSbeph, tabSurfSbeph] = ...
         process_profile_ir_rudics_cts5_usea_sbeph(apmtSbeph, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesSbeph] = merge_profile_meas_ir_rudics_cts5_usea_sbeph(tabProfilesSbeph);

      % add the vertical sampling scheme from configuration information
      [tabProfilesSbeph] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesSbeph);

      o_tabProfiles = [o_tabProfiles tabProfilesSbeph];
      o_tabDrift = [o_tabDrift tabDriftSbeph];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfSbeph];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftSbeph];
      o_tabSurf = [o_tabSurf tabSurfSbeph];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtCrover))

      % create profiles (as they are transmitted)
      [tabProfilesCrover, tabDriftCrover, tabDesc2ProfCrover, tabDeepDriftCrover, tabSurfCrover] = ...
         process_profile_ir_rudics_cts5_usea_crover(apmtCrover, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesCrover] = merge_profile_meas_ir_rudics_cts5_usea_crover(tabProfilesCrover);

      % add the vertical sampling scheme from configuration information
      [tabProfilesCrover] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesCrover);

      o_tabProfiles = [o_tabProfiles tabProfilesCrover];
      o_tabDrift = [o_tabDrift tabDriftCrover];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfCrover];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftCrover];
      o_tabSurf = [o_tabSurf tabSurfCrover];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtSuna))

      % create profiles (as they are transmitted)
      [tabProfilesSuna, tabDriftSuna, tabDesc2ProfSuna, tabDeepDriftSuna, tabSurfSuna] = ...
         process_profile_ir_rudics_cts5_usea_suna(apmtSuna, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesSuna] = merge_profile_meas_ir_rudics_cts5_usea_suna(tabProfilesSuna);

      % add the vertical sampling scheme from configuration information
      [tabProfilesSuna] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesSuna);

      o_tabProfiles = [o_tabProfiles tabProfilesSuna];
      o_tabDrift = [o_tabDrift tabDriftSuna];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfSuna];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftSuna];
      o_tabSurf = [o_tabSurf tabSurfSuna];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtUvpLpm))

      % create profiles (as they are transmitted)
      [tabProfilesUvpLpm, tabDriftUvpLpm, tabDesc2ProfUvpLpm, tabDeepDriftUvpLpm, tabSurfUvpLpm] = ...
         process_profile_ir_rudics_cts5_usea_uvp_lpm(apmtUvpLpm, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesUvpLpm] = merge_profile_meas_ir_rudics_cts5_usea_uvp_lpm(tabProfilesUvpLpm);

      % add the vertical sampling scheme from configuration information
      [tabProfilesUvpLpm] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesUvpLpm);

      o_tabProfiles = [o_tabProfiles tabProfilesUvpLpm];
      o_tabDrift = [o_tabDrift tabDriftUvpLpm];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfUvpLpm];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftUvpLpm];
      o_tabSurf = [o_tabSurf tabSurfUvpLpm];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtUvpLpmV2))

      % create profiles (as they are transmitted)
      [tabProfilesUvpLpmV2, tabDriftUvpLpmV2, tabDesc2ProfUvpLpmV2, tabDeepDriftUvpLpmV2, tabSurfUvpLpmV2] = ...
         process_profile_ir_rudics_cts5_usea_uvp_lpm_v2(apmtUvpLpmV2, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesUvpLpmV2] = merge_profile_meas_ir_rudics_cts5_usea_uvp_lpm_v2(tabProfilesUvpLpmV2);

      % add the vertical sampling scheme from configuration information
      [tabProfilesUvpLpmV2] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesUvpLpmV2);

      o_tabProfiles = [o_tabProfiles tabProfilesUvpLpmV2];
      o_tabDrift = [o_tabDrift tabDriftUvpLpmV2];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfUvpLpmV2];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftUvpLpmV2];
      o_tabSurf = [o_tabSurf tabSurfUvpLpmV2];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtUvpBlack))

      % create profiles (as they are transmitted)
      [tabProfilesUvpBlack, tabDriftUvpBlack, tabDesc2ProfUvpBlack, tabDeepDriftUvpBlack, tabSurfUvpBlack] = ...
         process_profile_ir_rudics_cts5_usea_uvp_black(apmtUvpBlack, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesUvpBlack] = merge_profile_meas_ir_rudics_cts5_usea_uvp_black(tabProfilesUvpBlack);

      % add the vertical sampling scheme from configuration information
      [tabProfilesUvpBlack] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesUvpBlack);

      o_tabProfiles = [o_tabProfiles tabProfilesUvpBlack];
      o_tabDrift = [o_tabDrift tabDriftUvpBlack];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfUvpBlack];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftUvpBlack];
      o_tabSurf = [o_tabSurf tabSurfUvpBlack];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtUvpBlackV2))

      % create profiles (as they are transmitted)
      [tabProfilesUvpBlackV2, tabDriftUvpBlackV2, tabDesc2ProfUvpBlackV2, tabDeepDriftUvpBlackV2, tabSurfUvpBlackV2] = ...
         process_profile_ir_rudics_cts5_usea_uvp_black_v2(apmtUvpBlackV2, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesUvpBlackV2] = merge_profile_meas_ir_rudics_cts5_usea_uvp_black_v2(tabProfilesUvpBlackV2);

      % add the vertical sampling scheme from configuration information
      [tabProfilesUvpBlackV2] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesUvpBlackV2);

      o_tabProfiles = [o_tabProfiles tabProfilesUvpBlackV2];
      o_tabDrift = [o_tabDrift tabDriftUvpBlackV2];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfUvpBlackV2];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftUvpBlackV2];
      o_tabSurf = [o_tabSurf tabSurfUvpBlackV2];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtUvpTaxoV2))

      % create profiles (as they are transmitted)
      [tabProfilesUvpTaxoV2, tabDriftUvpTaxoV2, tabDesc2ProfUvpTaxoV2, tabDeepDriftUvpTaxoV2, tabSurfUvpTaxoV2] = ...
         process_profile_ir_rudics_cts5_usea_uvp_taxo_v2(apmtUvpTaxoV2, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesUvpTaxoV2] = merge_profile_meas_ir_rudics_cts5_usea_uvp_taxo_v2(tabProfilesUvpTaxoV2);

      % add the vertical sampling scheme from configuration information
      [tabProfilesUvpTaxoV2] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesUvpTaxoV2);

      o_tabProfiles = [o_tabProfiles tabProfilesUvpTaxoV2];
      o_tabDrift = [o_tabDrift tabDriftUvpTaxoV2];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfUvpTaxoV2];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftUvpTaxoV2];
      o_tabSurf = [o_tabSurf tabSurfUvpTaxoV2];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtOpusLight))

      % create profiles (as they are transmitted)
      [tabProfilesOpusLight, tabDriftOpusLight, tabDesc2ProfOpusLight, tabDeepDriftOpusLight, tabSurfOpusLight] = ...
         process_profile_ir_rudics_cts5_usea_opus_light(apmtOpusLight, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesOpusLight] = merge_profile_meas_ir_rudics_cts5_usea_opus_light(tabProfilesOpusLight);

      % add the vertical sampling scheme from configuration information
      [tabProfilesOpusLight] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesOpusLight);

      o_tabProfiles = [o_tabProfiles tabProfilesOpusLight];
      o_tabDrift = [o_tabDrift tabDriftOpusLight];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfOpusLight];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftOpusLight];
      o_tabSurf = [o_tabSurf tabSurfOpusLight];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtOpusBlack))

      % create profiles (as they are transmitted)
      [tabProfilesOpusBlack, tabDriftOpusBlack, tabDesc2ProfOpusBlack, tabDeepDriftOpusBlack, tabSurfOpusBlack] = ...
         process_profile_ir_rudics_cts5_usea_opus_black(apmtOpusBlack, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesOpusBlack] = merge_profile_meas_ir_rudics_cts5_usea_opus_black(tabProfilesOpusBlack);

      % add the vertical sampling scheme from configuration information
      [tabProfilesOpusBlack] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesOpusBlack);

      o_tabProfiles = [o_tabProfiles tabProfilesOpusBlack];
      o_tabDrift = [o_tabDrift tabDriftOpusBlack];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfOpusBlack];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftOpusBlack];
      o_tabSurf = [o_tabSurf tabSurfOpusBlack];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtRamses))

      % create profiles (as they are transmitted)
      [tabProfilesRamses, tabDriftRamses, tabDesc2ProfRamses, tabDeepDriftRamses, tabSurfRamses] = ...
         process_profile_ir_rudics_cts5_usea_ramses(apmtRamses, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesRamses] = merge_profile_meas_ir_rudics_cts5_usea_ramses(tabProfilesRamses);

      % add the vertical sampling scheme from configuration information
      [tabProfilesRamses] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesRamses);

      o_tabProfiles = [o_tabProfiles tabProfilesRamses];
      o_tabDrift = [o_tabDrift tabDriftRamses];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfRamses];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftRamses];
      o_tabSurf = [o_tabSurf tabSurfRamses];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtRamses2))

      % create profiles (as they are transmitted)
      [tabProfilesRamses2, tabDriftRamses2, tabDesc2ProfRamses2, tabDeepDriftRamses2, tabSurfRamses2] = ...
         process_profile_ir_rudics_cts5_usea_ramses2(apmtRamses2, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesRamses2] = merge_profile_meas_ir_rudics_cts5_usea_ramses2(tabProfilesRamses2);

      % add the vertical sampling scheme from configuration information
      [tabProfilesRamses2] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesRamses2);

      o_tabProfiles = [o_tabProfiles tabProfilesRamses2];
      o_tabDrift = [o_tabDrift tabDriftRamses2];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfRamses2];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftRamses2];
      o_tabSurf = [o_tabSurf tabSurfRamses2];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtMpe))

      % create profiles (as they are transmitted)
      [tabProfilesMpe, tabDriftMpe, tabDesc2ProfMpe, tabDeepDriftMpe, tabSurfMpe] = ...
         process_profile_ir_rudics_cts5_usea_mpe(apmtMpe, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesMpe] = merge_profile_meas_ir_rudics_cts5_usea_mpe(tabProfilesMpe);

      % add the vertical sampling scheme from configuration information
      [tabProfilesMpe] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesMpe);

      o_tabProfiles = [o_tabProfiles tabProfilesMpe];
      o_tabDrift = [o_tabDrift tabDriftMpe];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfMpe];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftMpe];
      o_tabSurf = [o_tabSurf tabSurfMpe];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtHydrocM) || ~isempty(apmtHydrocC))

      % create profiles (as they are transmitted)
      [tabProfilesHydroc, tabDriftHydroc, tabDesc2ProfHydroc, tabDeepDriftHydroc, tabSurfHydroc] = ...
         process_profile_ir_rudics_cts5_usea_hydroc(apmtHydrocM, apmtHydrocC, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesHydroc] = merge_profile_meas_ir_rudics_cts5_usea_hydroc(tabProfilesHydroc);

      % add the vertical sampling scheme from configuration information
      [tabProfilesHydroc] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesHydroc);

      o_tabProfiles = [o_tabProfiles tabProfilesHydroc];
      o_tabDrift = [o_tabDrift tabDriftHydroc];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfHydroc];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftHydroc];
      o_tabSurf = [o_tabSurf tabSurfHydroc];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtImuRaw))

      % create profiles (as they are transmitted)
      [tabProfilesImuRaw, tabDriftImuRaw, tabDesc2ProfImuRaw, tabDeepDriftImuRaw, tabSurfImuRaw] = ...
         process_profile_ir_rudics_cts5_usea_imu_raw(apmtImuRaw, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesImuRaw] = merge_profile_meas_ir_rudics_cts5_usea_imu_raw(tabProfilesImuRaw);

      % add the vertical sampling scheme from configuration information
      [tabProfilesImuRaw] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesImuRaw);

      o_tabProfiles = [o_tabProfiles tabProfilesImuRaw];
      o_tabDrift = [o_tabDrift tabDriftImuRaw];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfImuRaw];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftImuRaw];
      o_tabSurf = [o_tabSurf tabSurfImuRaw];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtImuTiltHeading))

      % create profiles (as they are transmitted)
      [tabProfilesImuTiltHeading, tabDriftImuTiltHeading, tabDesc2ProfImuTiltHeading, tabDeepDriftImuTiltHeading, tabSurfImuTiltHeading] = ...
         process_profile_ir_rudics_cts5_usea_imu_tilt_heading(apmtImuTiltHeading, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesImuTiltHeading] = merge_profile_meas_ir_rudics_cts5_usea_imu_tilt_heading(tabProfilesImuTiltHeading);

      % add the vertical sampling scheme from configuration information
      [tabProfilesImuTiltHeading] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesImuTiltHeading);

      o_tabProfiles = [o_tabProfiles tabProfilesImuTiltHeading];
      o_tabDrift = [o_tabDrift tabDriftImuTiltHeading];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfImuTiltHeading];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftImuTiltHeading];
      o_tabSurf = [o_tabSurf tabSurfImuTiltHeading];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (~isempty(apmtImuWave))

      % create profiles (as they are transmitted)
      [tabProfilesImuWave, tabDriftImuWave, tabDesc2ProfImuWave, tabDeepDriftImuWave, tabSurfImuWave] = ...
         process_profile_ir_rudics_cts5_usea_imu_wave(apmtImuWave, apmtTimeFromTech, g_decArgo_gpsData);

      % merge profiles (all data from a given sensor together)
      [tabProfilesImuWave] = merge_profile_meas_ir_rudics_cts5_usea_imu_wave(tabProfilesImuWave);

      % add the vertical sampling scheme from configuration information
      [tabProfilesImuWave] = add_vertical_sampling_scheme_ir_rudics_cts5_usea_bgc(tabProfilesImuWave);

      o_tabProfiles = [o_tabProfiles tabProfilesImuWave];
      o_tabDrift = [o_tabDrift tabDriftImuWave];
      o_tabDesc2Prof = [o_tabDesc2Prof tabDesc2ProfImuWave];
      o_tabDeepDrift = [o_tabDeepDrift tabDeepDriftImuWave];
      o_tabSurf = [o_tabSurf tabSurfImuWave];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % compute derived parameters of the profiles
   [o_tabProfiles] = compute_profile_derived_parameters_ir_rudics(o_tabProfiles, a_decoderId);

   % compute derived parameters of the park phase
   [o_tabDrift] = compute_drift_derived_parameters_ir_rudics(o_tabDrift, a_decoderId);

   % compute derived parameters of the deep profiles
   [o_tabDesc2Prof] = compute_profile_derived_parameters_ir_rudics(o_tabDesc2Prof, a_decoderId);

   % compute derived parameters of the deep park phase
   [o_tabDeepDrift] = compute_drift_derived_parameters_ir_rudics(o_tabDeepDrift, a_decoderId);

   % compute derived parameters of the surface phase
   [o_tabSurf] = compute_surface_derived_parameters_ir_rudics_cts5(o_tabSurf, a_decoderId);

   print = 0;
   if (print == 1)
      if (~isempty(o_tabProfiles))
         fprintf('DEC_INFO: Float #%d Cycle #%d: (Cy,Ptn)=(%d,%d): %d profiles for NetCDF file\n', ...
            g_decArgo_floatNum, ...
            g_decArgo_cycleNum, ...
            g_decArgo_cycleNumFloat, ...
            g_decArgo_patternNumFloat, ...
            length(o_tabProfiles));
         for idP = 1:length(o_tabProfiles)
            prof = o_tabProfiles(idP);
            paramList = prof.paramList;
            paramList = sprintf('%s ', paramList.name);
            profLength = size(prof.data, 1);
            fprintf('   ->%2d: Profile #%d dir=%c length=%d param=(%s)\n', ...
               idP, prof.profileNumber, prof.direction, ...
               profLength, paramList(1:end-1));
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % TECH NetCDF file

   % collect technical data (and merge Tech and Event technical data)
   [o_tabNcTechIndex, o_tabNcTechVal, o_tabTechNMeas] = collect_technical_data_cts5_usea(techDataFromApmtTech);

end

if (~isempty(o_tabProfiles) || ~isempty(o_tabDrift) || ~isempty(o_tabDesc2Prof) || ...
      ~isempty(o_tabDeepDrift) || ~isempty(o_tabSurf) || ~isempty(o_tabNcTechIndex) || ...
      ~isempty(o_tabNcTechVal) || ~isempty(o_tabTechNMeas))
   g_decArgo_generateNcFlag = 1;
end

return
