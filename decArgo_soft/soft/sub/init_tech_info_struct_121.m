% ------------------------------------------------------------------------------
% Get the basic structure to read APMT technical data.
%
% SYNTAX :
%  [o_techSectionList, o_techInfoStruct] = init_tech_info_struct_121
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%   o_techSectionList : list of sections
%   o_techInfoStruct  : information on each section
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/21/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_techSectionList, o_techInfoStruct] = init_tech_info_struct_121

% output parameters initialization
o_techSectionList = [];
o_techInfoStruct = [];

% number used to group traj information
global g_decArgo_trajItemGroupNum;

% global measurement codes
global g_MC_CycleStart;
global g_MC_DST;
global g_MC_FST;
global g_MC_PST;
global g_MC_MinPresInDriftAtPark;
global g_MC_MaxPresInDriftAtPark;
global g_MC_PET;
global g_MC_MaxPresInDescToProf;
global g_MC_AST;
global g_MC_AET;
global g_MC_Surface;
global g_MC_InAirSingleMeasRelativeToTET;
global g_MC_Grounded;

% list of expected sections
o_techSectionList = [ ...
   {'SYSTEM'} ...
   {'GPS'} ...
   {'USER'} ...
   {'PROFILE'} ...
   {'DATA'} ...
   {'POWER'} ...
   {'ALARM'} ...
   ];

presOffset = init_basic_struct;
presOffset.pattern = 'Pe offset=%f dbar';
presOffset.count = 1;
presOffset.id{end+1} = 1;
presOffset.name{end+1} = 'pressure offset (dbar)';
presOffset.fmt{end+1} = '%g';
presOffset.tech{end+1} = get_cts5_tech_data_init_struct(102, 'Pressure offset (dbar)');

intPres = init_basic_struct;
intPres.pattern = 'Pi=%f mbar';
intPres.count = 1;
intPres.id{end+1} = 1;
intPres.name{end+1} = 'internal pressure (mbar)';
intPres.fmt{end+1} = '%g';
intPres.tech{end+1} = get_cts5_tech_data_init_struct(103, 'Internal pressure (mbar)');

battVolt = init_basic_struct;
battVolt.pattern = 'Vbatt=%f V';
battVolt.count = 1;
battVolt.id{end+1} = 1;
battVolt.name{end+1} = 'battery voltage (V)';
battVolt.fmt{end+1} = '%g';
battVolt.tech{end+1} = get_cts5_tech_data_init_struct(104, 'Battery voltage (V)');

minBattVolt = init_basic_struct;
minBattVolt.pattern = 'Vbatt peak min=%f V';
minBattVolt.count = 1;
minBattVolt.id{end+1} = 1;
minBattVolt.name{end+1} = 'min peak battery voltage (V)';
minBattVolt.fmt{end+1} = '%g';
minBattVolt.tech{end+1} = get_cts5_tech_data_init_struct(105, 'Min peak battery voltage (V)');

externalTemp = init_basic_struct;
externalTemp.pattern = 'Te=%f degC';
externalTemp.count = 1;
externalTemp.id{end+1} = 1;
externalTemp.name{end+1} = 'external temperature (air) (degC)';
externalTemp.fmt{end+1} = '%g';
externalTemp.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_InAirSingleMeasRelativeToTET, 'TEMP', ...
   'External temperature (air) (degC)');

o_techInfoStruct.SYSTEM = [];
o_techInfoStruct.SYSTEM{end+1} = presOffset;
o_techInfoStruct.SYSTEM{end+1} = intPres;
o_techInfoStruct.SYSTEM{end+1} = battVolt;
o_techInfoStruct.SYSTEM{end+1} = minBattVolt;
o_techInfoStruct.SYSTEM{end+1} = externalTemp;

gpsLoc = init_basic_struct;
gpsLoc.pattern = 'UTC=%u-%u-%u %u:%u:%u Lat=%f%c Long=%f%c';
gpsLoc.count = 10;
gpsLoc.id{end+1} = 1:6;
gpsLoc.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
gpsLoc.func1{end+1} = '@(x) adjust_time_cts5(x)';
gpsLoc.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
gpsLoc.name{end+1} = 'GPS location date';
gpsLoc.fmt{end+1} = '%g';
gpsLoc.time{end+1} = get_cts5_time_data_init_struct(...
   'GPS LOCATION TIME', 'JULD');
gpsLoc.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Surface, 'JULD', ...
   'GPS location date');
gpsLoc.traj{end}.group = g_decArgo_trajItemGroupNum;

gpsLoc.id{end+1} = 7:8;
gpsLoc.func{end+1} = '@(x) compute_latitude(x(1), x(2))';
gpsLoc.func1{end+1} = [];
gpsLoc.func2{end+1} = [];
gpsLoc.name{end+1} = 'GPS location latitude';
gpsLoc.fmt{end+1} = '%g';
gpsLoc.time{end+1} = [];
gpsLoc.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Surface, 'LATITUDE', ...
   'GPS location latitude');
gpsLoc.traj{end}.group = g_decArgo_trajItemGroupNum;

gpsLoc.id{end+1} = 9:10;
gpsLoc.func{end+1} = '@(x) compute_longitude(x(1), x(2))';
gpsLoc.func1{end+1} = [];
gpsLoc.func2{end+1} = [];
gpsLoc.name{end+1} = 'GPS location longitude';
gpsLoc.fmt{end+1} = '%g';
gpsLoc.time{end+1} = [];
gpsLoc.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Surface, 'LONGITUDE', ...
   'GPS location longitude');
gpsLoc.traj{end}.group = g_decArgo_trajItemGroupNum;
g_decArgo_trajItemGroupNum = g_decArgo_trajItemGroupNum + 1;

gpsLocObsolete = init_basic_struct;
gpsLocObsolete.pattern = 'UTC=%u/%u/%u %u:%u:%u Lat=%f%c Long=%f%c';
gpsLocObsolete.count = 10;
gpsLocObsolete.id{end+1} = 1:6;
gpsLocObsolete.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
gpsLocObsolete.func1{end+1} = '@(x) adjust_time_cts5(x)';
gpsLocObsolete.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
gpsLocObsolete.name{end+1} = 'GPS location date';
gpsLocObsolete.fmt{end+1} = '%g';
gpsLocObsolete.time{end+1} = get_cts5_time_data_init_struct(...
   'GPS LOCATION TIME', 'JULD');
gpsLocObsolete.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Surface, 'JULD', ...
   'GPS location date');
gpsLocObsolete.traj{end}.group = g_decArgo_trajItemGroupNum;

gpsLocObsolete.id{end+1} = 7:8;
gpsLocObsolete.func{end+1} = '@(x) compute_latitude(x(1), x(2))';
gpsLocObsolete.func1{end+1} = [];
gpsLocObsolete.func2{end+1} = [];
gpsLocObsolete.name{end+1} = 'GPS location latitude';
gpsLocObsolete.fmt{end+1} = '%g';
gpsLocObsolete.time{end+1} = [];
gpsLocObsolete.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Surface, 'LATITUDE', ...
   'GPS location latitude');
gpsLocObsolete.traj{end}.group = g_decArgo_trajItemGroupNum;

gpsLocObsolete.id{end+1} = 9:10;
gpsLocObsolete.func{end+1} = '@(x) compute_longitude(x(1), x(2))';
gpsLocObsolete.func1{end+1} = [];
gpsLocObsolete.func2{end+1} = [];
gpsLocObsolete.name{end+1} = 'GPS location longitude';
gpsLocObsolete.fmt{end+1} = '%g';
gpsLocObsolete.time{end+1} = [];
gpsLocObsolete.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Surface, 'LONGITUDE', ...
   'GPS location longitude');
gpsLocObsolete.traj{end}.group = g_decArgo_trajItemGroupNum;
g_decArgo_trajItemGroupNum = g_decArgo_trajItemGroupNum + 1;

o_techInfoStruct.GPS = [];
o_techInfoStruct.GPS{end+1} = gpsLoc;
o_techInfoStruct.GPS{end+1} = gpsLocObsolete;

apmtVersion = init_basic_struct;
apmtVersion.pattern = 'APMT=%s';
apmtVersion.count = 1;
apmtVersion.id{end+1} = 1;
apmtVersion.name{end+1} = 'APMT version';
apmtVersion.fmt{end+1} = '%s';
apmtVersion.meta{end+1} = get_cts5_meta_data_init_struct(300, 'APMT version');

payloadVersion = init_basic_struct;
payloadVersion.pattern = 'Payload=%s';
payloadVersion.count = 1;
payloadVersion.id{end+1} = 1;
payloadVersion.name{end+1} = 'payload version';
payloadVersion.fmt{end+1} = '%s';
payloadVersion.meta{end+1} = get_cts5_meta_data_init_struct(301, 'Payload version');

simCardId = init_basic_struct;
simCardId.pattern = 'CID=%s';
simCardId.count = 1;
simCardId.id{end+1} = 1;
simCardId.name{end+1} = 'SIM card Id';
simCardId.fmt{end+1} = '%s';
simCardId.meta{end+1} = get_cts5_meta_data_init_struct(302, 'SIM card Id');

o_techInfoStruct.USER = [];
o_techInfoStruct.USER{end+1} = apmtVersion;
o_techInfoStruct.USER{end+1} = payloadVersion;
o_techInfoStruct.USER{end+1} = simCardId;

buoyancyReduction = init_basic_struct;
buoyancyReduction.pattern = 'UTC=%u-%u-%u %u:%u:%u Flotation=%f cm3 (%u) down to %u dbar';
buoyancyReduction.count = 9;
buoyancyReduction.id{end+1} = 1:6;
buoyancyReduction.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
buoyancyReduction.func1{end+1} = '@(x) adjust_time_cts5(x)';
buoyancyReduction.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
buoyancyReduction.name{end+1} = 'buoyancy reduction start date';
buoyancyReduction.fmt{end+1} = '%g';
buoyancyReduction.tech{end+1} = [];
buoyancyReduction.time{end+1} = get_cts5_time_data_init_struct(...
   'CYCLE START TIME', 'JULD');
buoyancyReduction.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_CycleStart, 'JULD', ...
   'Buoyancy reduction start date');

buoyancyReduction.id{end+1} = 7;
buoyancyReduction.func{end+1} = [];
buoyancyReduction.func1{end+1} = [];
buoyancyReduction.func2{end+1} = [];
buoyancyReduction.name{end+1} = 'volume of transfered oil during buoyancy reduction (cm3)';
buoyancyReduction.fmt{end+1} = '%g';
buoyancyReduction.tech{end+1} = get_cts5_tech_data_init_struct(106, 'Volume of transfered oil during buoyancy reduction (cm3)');
buoyancyReduction.time{end+1} = [];
buoyancyReduction.traj{end+1} = [];

buoyancyReduction.id{end+1} = 8;
buoyancyReduction.func{end+1} = [];
buoyancyReduction.func1{end+1} = [];
buoyancyReduction.func2{end+1} = [];
buoyancyReduction.name{end+1} = 'number of valve actions during buoyancy reduction';
buoyancyReduction.fmt{end+1} = '%d';
buoyancyReduction.tech{end+1} = get_cts5_tech_data_init_struct(107, 'Number of valve actions during buoyancy reduction');
buoyancyReduction.time{end+1} = [];
buoyancyReduction.traj{end+1} = [];

buoyancyReduction.id{end+1} = 9;
buoyancyReduction.func{end+1} = [];
buoyancyReduction.func1{end+1} = [];
buoyancyReduction.func2{end+1} = [];
buoyancyReduction.name{end+1} = 'stabilization pressure after buoyancy reduction (dbar)';
buoyancyReduction.fmt{end+1} = '%d';
buoyancyReduction.tech{end+1} = [];
buoyancyReduction.time{end+1} = [];
buoyancyReduction.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_FST, 'PRES', ...
   'Stabilization pressure after buoyancy reduction (dbar)');

descentToParkingDepth = init_basic_struct;
descentToParkingDepth.pattern = 'UTC=%u-%u-%u %u:%u:%u Descent=%f cm3 (%u)';
descentToParkingDepth.count = 8;
descentToParkingDepth.id{end+1} = 1:6;
descentToParkingDepth.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
descentToParkingDepth.func1{end+1} = '@(x) adjust_time_cts5(x)';
descentToParkingDepth.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
descentToParkingDepth.name{end+1} = 'descent to parking depth start date';
descentToParkingDepth.fmt{end+1} = '%g';
descentToParkingDepth.tech{end+1} = [];
descentToParkingDepth.time{end+1} = get_cts5_time_data_init_struct(...
   'DESCENT TO PARK START TIME', 'JULD');
descentToParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_DST, 'JULD', ...
   'Descent to parking depth start date');

descentToParkingDepth.id{end+1} = 7;
descentToParkingDepth.func{end+1} = [];
descentToParkingDepth.func1{end+1} = [];
descentToParkingDepth.func2{end+1} = [];
descentToParkingDepth.name{end+1} = 'volume of transfered oil during descent to parking depth (cm3)';
descentToParkingDepth.fmt{end+1} = '%g';
descentToParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(108, 'Volume of transfered oil during descent to parking depth (cm3)');
descentToParkingDepth.time{end+1} = [];
descentToParkingDepth.traj{end+1} = [];

descentToParkingDepth.id{end+1} = 8;
descentToParkingDepth.func{end+1} = [];
descentToParkingDepth.func1{end+1} = [];
descentToParkingDepth.func2{end+1} = [];
descentToParkingDepth.name{end+1} = 'number of valve actions during descent to parking depth';
descentToParkingDepth.fmt{end+1} = '%d';
descentToParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(109, 'Number of valve actions during descent to parking depth');
descentToParkingDepth.time{end+1} = [];
descentToParkingDepth.traj{end+1} = [];

grounding = init_basic_struct;
grounding.pattern = 'UTC=%u-%u-%u %u:%u:%u Grounding escape=%f cm3';
grounding.count = 7;
grounding.id{end+1} = 1:6;
grounding.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
grounding.func1{end+1} = '@(x) adjust_time_cts5(x)';
grounding.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
grounding.name{end+1} = 'grounding escape date';
grounding.fmt{end+1} = '%g';
grounding.tech{end+1} = get_cts5_tech_data_init_struct(110, 'End grounding time');
grounding.tech{end}.func = '@(x) format_date_yyyymmddhhmiss_dec_argo(x)';
grounding.tech{end}.func1 = '@(x) adjust_time_cts5(x)';

grounding.id{end+1} = 7;
grounding.func{end+1} = [];
grounding.func1{end+1} = [];
grounding.func2{end+1} = [];
grounding.name{end+1} = 'volume of transfered oil to escape from grounding (cm3)';
grounding.fmt{end+1} = '%g';
grounding.tech{end+1} = get_cts5_tech_data_init_struct(111, 'Volume of transfered oil to escape from grounding (cm3)');

driftAtParkingDepth = init_basic_struct;
driftAtParkingDepth.pattern = 'UTC=%u-%u-%u %u:%u:%u Park=%u/%u dbar (%u/%u) stability=%u/%u';
driftAtParkingDepth.count = 12;
driftAtParkingDepth.id{end+1} = 1:6;
driftAtParkingDepth.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
driftAtParkingDepth.func1{end+1} = '@(x) adjust_time_cts5(x)';
driftAtParkingDepth.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
driftAtParkingDepth.name{end+1} = 'drift at parking depth start date';
driftAtParkingDepth.fmt{end+1} = '%g';
driftAtParkingDepth.tech{end+1} = [];
driftAtParkingDepth.time{end+1} = get_cts5_time_data_init_struct(...
   'PARK START TIME', 'JULD');
driftAtParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_PST, 'JULD', ...
   'Drift at parking depth start date');

driftAtParkingDepth.id{end+1} = 7;
driftAtParkingDepth.func{end+1} = [];
driftAtParkingDepth.func1{end+1} = [];
driftAtParkingDepth.func2{end+1} = [];
driftAtParkingDepth.name{end+1} = 'min pressure during drift at parking depth (dbar)';
driftAtParkingDepth.fmt{end+1} = '%d';
driftAtParkingDepth.tech{end+1} = [];
driftAtParkingDepth.time{end+1} = [];
driftAtParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_MinPresInDriftAtPark, 'PRES', ...
   'Min pressure during drift at parking depth (dbar)');

driftAtParkingDepth.id{end+1} = 8;
driftAtParkingDepth.func{end+1} = [];
driftAtParkingDepth.func1{end+1} = [];
driftAtParkingDepth.func2{end+1} = [];
driftAtParkingDepth.name{end+1} = 'max pressure during drift at parking depth (dbar)';
driftAtParkingDepth.fmt{end+1} = '%d';
driftAtParkingDepth.tech{end+1} = [];
driftAtParkingDepth.time{end+1} = [];
driftAtParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_MaxPresInDriftAtPark, 'PRES', ...
   'Max pressure during drift at parking depth (dbar)');

driftAtParkingDepth.id{end+1} = 9;
driftAtParkingDepth.func{end+1} = [];
driftAtParkingDepth.func1{end+1} = [];
driftAtParkingDepth.func2{end+1} = [];
driftAtParkingDepth.name{end+1} = 'number of valve actions during drift at parking depth';
driftAtParkingDepth.fmt{end+1} = '%d';
driftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(112, 'Number of valve actions during drift at parking depth');
driftAtParkingDepth.time{end+1} = [];
driftAtParkingDepth.traj{end+1} = [];

driftAtParkingDepth.id{end+1} = 10;
driftAtParkingDepth.func{end+1} = [];
driftAtParkingDepth.func1{end+1} = [];
driftAtParkingDepth.func2{end+1} = [];
driftAtParkingDepth.name{end+1} = 'number of pump actions during drift at parking depth';
driftAtParkingDepth.fmt{end+1} = '%d';
driftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(113, 'Number of pump actions during drift at parking depth');
driftAtParkingDepth.time{end+1} = [];
driftAtParkingDepth.traj{end+1} = [];

driftAtParkingDepth.id{end+1} = 11;
driftAtParkingDepth.func{end+1} = [];
driftAtParkingDepth.func1{end+1} = [];
driftAtParkingDepth.func2{end+1} = [];
driftAtParkingDepth.name{end+1} = 'number of entries in park margin during drift at parking depth';
driftAtParkingDepth.fmt{end+1} = '%d';
driftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(114, 'Number of entries in park margin during drift at parking depth');
driftAtParkingDepth.time{end+1} = [];
driftAtParkingDepth.traj{end+1} = [];

driftAtParkingDepth.id{end+1} = 12;
driftAtParkingDepth.func{end+1} = [];
driftAtParkingDepth.func1{end+1} = [];
driftAtParkingDepth.func2{end+1} = [];
driftAtParkingDepth.name{end+1} = 'number of exit from park margin during drift at parking depth';
driftAtParkingDepth.fmt{end+1} = '%d';
driftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(115, 'Number of exit from park margin during drift at parking depth');
driftAtParkingDepth.time{end+1} = [];
driftAtParkingDepth.traj{end+1} = [];

stabilizedDriftAtParkingDepth = init_basic_struct;
stabilizedDriftAtParkingDepth.pattern = 'UTC=%u-%u-%u %u:%u:%u Park stablization=%u dbar';
stabilizedDriftAtParkingDepth.count = 7;
stabilizedDriftAtParkingDepth.id{end+1} = 1:6;
stabilizedDriftAtParkingDepth.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
stabilizedDriftAtParkingDepth.func1{end+1} = '@(x) adjust_time_cts5(x)';
stabilizedDriftAtParkingDepth.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
stabilizedDriftAtParkingDepth.name{end+1} = 'stabilized drift at parking depth start date';
stabilizedDriftAtParkingDepth.fmt{end+1} = '%g';
stabilizedDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(184, 'Stabilized park start time');
stabilizedDriftAtParkingDepth.tech{end}.func = '@(x) format_date_yyyymmddhhmiss_dec_argo(x)';
stabilizedDriftAtParkingDepth.tech{end}.func1 = '@(x) adjust_time_cts5(x)';
stabilizedDriftAtParkingDepth.time{end+1} = get_cts5_time_data_init_struct(...
   'STABILIZED PARK START TIME', 'JULD');
stabilizedDriftAtParkingDepth.traj{end+1} = [];

stabilizedDriftAtParkingDepth.id{end+1} = 7;
stabilizedDriftAtParkingDepth.func{end+1} = [];
stabilizedDriftAtParkingDepth.func1{end+1} = [];
stabilizedDriftAtParkingDepth.func2{end+1} = [];
stabilizedDriftAtParkingDepth.name{end+1} = 'stabilized pressure during drift at parking depth (dbar)';
stabilizedDriftAtParkingDepth.fmt{end+1} = '%d';
stabilizedDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(185, 'Stabilized park pressure (dbar)');
stabilizedDriftAtParkingDepth.time{end+1} = [];
stabilizedDriftAtParkingDepth.traj{end+1} = [];

descentToProfileDepth = init_basic_struct;
descentToProfileDepth.pattern = 'UTC=%u-%u-%u %u:%u:%u Deep profile=%f cm3 (%u)';
descentToProfileDepth.count = 8;
descentToProfileDepth.id{end+1} = 1:6;
descentToProfileDepth.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
descentToProfileDepth.func1{end+1} = '@(x) adjust_time_cts5(x)';
descentToProfileDepth.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
descentToProfileDepth.name{end+1} = 'descent to profile depth start date';
descentToProfileDepth.fmt{end+1} = '%g';
descentToProfileDepth.tech{end+1} = [];
descentToProfileDepth.time{end+1} = get_cts5_time_data_init_struct(...
   'PARK END TIME', 'JULD');
descentToProfileDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_PET, 'JULD', ...
   'Descent to profile depth start date');

descentToProfileDepth.id{end+1} = 7;
descentToProfileDepth.func{end+1} = [];
descentToProfileDepth.func1{end+1} = [];
descentToProfileDepth.func2{end+1} = [];
descentToProfileDepth.name{end+1} = 'volume of transfered oil during descent to profile depth (cm3)';
descentToProfileDepth.fmt{end+1} = '%g';
descentToProfileDepth.tech{end+1} = get_cts5_tech_data_init_struct(116, 'Volume of transfered oil during descent to profile depth (cm3)');
descentToProfileDepth.time{end+1} = [];
descentToProfileDepth.traj{end+1} = [];

descentToProfileDepth.id{end+1} = 8;
descentToProfileDepth.func{end+1} = [];
descentToProfileDepth.func1{end+1} = [];
descentToProfileDepth.func2{end+1} = [];
descentToProfileDepth.name{end+1} = 'number of valve actions during descent to profile depth';
descentToProfileDepth.fmt{end+1} = '%d';
descentToProfileDepth.tech{end+1} = get_cts5_tech_data_init_struct(117, 'Number of valve actions during descent to profile depth');
descentToProfileDepth.time{end+1} = [];
descentToProfileDepth.traj{end+1} = [];

standardAscent = init_basic_struct;
standardAscent.pattern = 'UTC=%u-%u-%u %u:%u:%u Ascent=%f cm3 (%u/%u) from %u dbar';
standardAscent.count = 10;
standardAscent.id{end+1} = 1:6;
standardAscent.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
standardAscent.func1{end+1} = '@(x) adjust_time_cts5(x)';
standardAscent.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
standardAscent.name{end+1} = 'standard ascent start date';
standardAscent.fmt{end+1} = '%g';
standardAscent.tech{end+1} = [];
standardAscent.time{end+1} = get_cts5_time_data_init_struct(...
   'ASCENT START TIME', 'JULD');
standardAscent.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_AST, 'JULD', ...
   'Standard ascent start date');

standardAscent.id{end+1} = 7;
standardAscent.func{end+1} = [];
standardAscent.func1{end+1} = [];
standardAscent.func2{end+1} = [];
standardAscent.name{end+1} = 'volume of transfered oil during standard ascent (cm3)';
standardAscent.fmt{end+1} = '%g';
standardAscent.tech{end+1} = get_cts5_tech_data_init_struct(118, 'Volume of transfered oil during standard ascent (cm3)');
standardAscent.time{end+1} = [];
standardAscent.traj{end+1} = [];

standardAscent.id{end+1} = 8;
standardAscent.func{end+1} = [];
standardAscent.func1{end+1} = [];
standardAscent.func2{end+1} = [];
standardAscent.name{end+1} = 'total number of pump actions during standard ascent';
standardAscent.fmt{end+1} = '%d';
standardAscent.tech{end+1} = get_cts5_tech_data_init_struct(119, 'Total number of pump actions during standard ascent');
standardAscent.time{end+1} = [];
standardAscent.traj{end+1} = [];

standardAscent.id{end+1} = 9;
standardAscent.func{end+1} = [];
standardAscent.func1{end+1} = [];
standardAscent.func2{end+1} = [];
standardAscent.name{end+1} = 'number of pump actions to initiate standard ascent';
standardAscent.fmt{end+1} = '%d';
standardAscent.tech{end+1} = get_cts5_tech_data_init_struct(120, 'Number of pump actions to initiate standard ascent');
standardAscent.time{end+1} = [];
standardAscent.traj{end+1} = [];

standardAscent.id{end+1} = 10;
standardAscent.func{end+1} = [];
standardAscent.func1{end+1} = [];
standardAscent.func2{end+1} = [];
standardAscent.name{end+1} = 'max pressure sampled during standard ascent';
standardAscent.fmt{end+1} = '%d';
standardAscent.tech{end+1} = [];
standardAscent.time{end+1} = [];
standardAscent.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_MaxPresInDescToProf, 'PRES', ...
   'Max pressure sampled during standard ascent');

slowAscent = init_basic_struct;
slowAscent.pattern = 'UTC=%u-%u-%u %u:%u:%u Ascent (slowly)=%f cm3 (%u)';
slowAscent.count = 8;
slowAscent.id{end+1} = 1:6;
slowAscent.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
slowAscent.func1{end+1} = '@(x) adjust_time_cts5(x)';
slowAscent.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
slowAscent.name{end+1} = 'slow ascent start date';
slowAscent.fmt{end+1} = '%g';
slowAscent.tech{end+1} = get_cts5_tech_data_init_struct(121, 'Slow ascent start date');
slowAscent.tech{end}.func = '@(x) format_date_yyyymmddhhmiss_dec_argo(x)';
slowAscent.tech{end}.func1 = '@(x) adjust_time_cts5(x)';
slowAscent.time{end+1} = get_cts5_time_data_init_struct(...
   'SLOW ASCENT START TIME', 'JULD');

slowAscent.id{end+1} = 7;
slowAscent.func{end+1} = [];
slowAscent.func1{end+1} = [];
slowAscent.func2{end+1} = [];
slowAscent.name{end+1} = 'volume of transfered oil during slow ascent (cm3)';
slowAscent.fmt{end+1} = '%g';
slowAscent.tech{end+1} = get_cts5_tech_data_init_struct(122, 'Volume of transfered oil during slow ascent (cm3)');
slowAscent.time{end+1} = [];

slowAscent.id{end+1} = 8;
slowAscent.func{end+1} = [];
slowAscent.func1{end+1} = [];
slowAscent.func2{end+1} = [];
slowAscent.name{end+1} = 'total number of valve actions during slow ascent';
slowAscent.fmt{end+1} = '%d';
slowAscent.tech{end+1} = get_cts5_tech_data_init_struct(123, 'Total number of valve actions during slow ascent');
slowAscent.time{end+1} = [];

resumedAscent = init_basic_struct;
resumedAscent.pattern = 'UTC=%u-%u-%u %u:%u:%u Ascent (resume)=%f cm3 (%u)';
resumedAscent.count = 8;
resumedAscent.id{end+1} = 1:6;
resumedAscent.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
resumedAscent.func1{end+1} = '@(x) adjust_time_cts5(x)';
resumedAscent.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
resumedAscent.name{end+1} = 'resumed ascent start date';
resumedAscent.fmt{end+1} = '%g';
resumedAscent.tech{end+1} = get_cts5_tech_data_init_struct(124, 'Resumed ascent start date');
resumedAscent.tech{end}.func = '@(x) format_date_yyyymmddhhmiss_dec_argo(x)';
resumedAscent.tech{end}.func1 = '@(x) adjust_time_cts5(x)';
resumedAscent.time{end+1} = get_cts5_time_data_init_struct(...
   'RESUMED ASCENT START TIME', 'JULD');

resumedAscent.id{end+1} = 7;
resumedAscent.func{end+1} = [];
resumedAscent.func1{end+1} = [];
resumedAscent.func2{end+1} = [];
resumedAscent.name{end+1} = 'volume of transfered oil during resumed ascent (cm3)';
resumedAscent.fmt{end+1} = '%g';
resumedAscent.tech{end+1} = get_cts5_tech_data_init_struct(125, 'Volume of transfered oil during resumed ascent (cm3)');
resumedAscent.time{end+1} = [];

resumedAscent.id{end+1} = 8;
resumedAscent.func{end+1} = [];
resumedAscent.func1{end+1} = [];
resumedAscent.func2{end+1} = [];
resumedAscent.name{end+1} = 'total number of valve actions during resumed ascent';
resumedAscent.fmt{end+1} = '%d';
resumedAscent.tech{end+1} = get_cts5_tech_data_init_struct(126, 'Total number of valve actions during resumed ascent');
resumedAscent.time{end+1} = [];

endAscent = init_basic_struct;
endAscent.pattern = 'UTC=%u-%u-%u %u:%u:%u Ascent end';
endAscent.count = 6;
endAscent.id{end+1} = 1:6;
endAscent.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
endAscent.func1{end+1} = '@(x) adjust_time_cts5(x)';
endAscent.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
endAscent.name{end+1} = 'ascent end date';
endAscent.fmt{end+1} = '%g';
endAscent.time{end+1} = get_cts5_time_data_init_struct(...
   'ASCENT END TIME', 'JULD');
endAscent.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_AET, 'JULD', ...
   'Ascent end date');

iceDriftAtParkingDepth = init_basic_struct;
iceDriftAtParkingDepth.pattern = 'UTC=%u-%u-%u %u:%u:%u Ice Park=%u/%u dbar (%u/%u) stability=%u/%u';
iceDriftAtParkingDepth.count = 12;
iceDriftAtParkingDepth.id{end+1} = 1:6;
iceDriftAtParkingDepth.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
iceDriftAtParkingDepth.func1{end+1} = '@(x) adjust_time_cts5(x)';
iceDriftAtParkingDepth.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
iceDriftAtParkingDepth.name{end+1} = 'drift at parking depth start date (ice mode)';
iceDriftAtParkingDepth.fmt{end+1} = '%g';
iceDriftAtParkingDepth.tech{end+1} = [];
iceDriftAtParkingDepth.time{end+1} = get_cts5_time_data_init_struct(...
   'PARK START TIME', 'JULD');
iceDriftAtParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_PST, 'JULD', ...
   'Drift at parking depth start date (ice mode)');

iceDriftAtParkingDepth.id{end+1} = 7;
iceDriftAtParkingDepth.func{end+1} = [];
iceDriftAtParkingDepth.func1{end+1} = [];
iceDriftAtParkingDepth.func2{end+1} = [];
iceDriftAtParkingDepth.name{end+1} = 'min pressure during drift at parking depth (ice mode) (dbar)';
iceDriftAtParkingDepth.fmt{end+1} = '%d';
iceDriftAtParkingDepth.tech{end+1} = [];
iceDriftAtParkingDepth.time{end+1} = [];
iceDriftAtParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_MinPresInDriftAtPark, 'PRES', ...
   'Min pressure during drift at parking depth (ice mode) (dbar)');

iceDriftAtParkingDepth.id{end+1} = 8;
iceDriftAtParkingDepth.func{end+1} = [];
iceDriftAtParkingDepth.func1{end+1} = [];
iceDriftAtParkingDepth.func2{end+1} = [];
iceDriftAtParkingDepth.name{end+1} = 'max pressure during drift at parking depth (ice mode) (dbar)';
iceDriftAtParkingDepth.fmt{end+1} = '%d';
iceDriftAtParkingDepth.tech{end+1} = [];
iceDriftAtParkingDepth.time{end+1} = [];
iceDriftAtParkingDepth.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_MaxPresInDriftAtPark, 'PRES', ...
   'Max pressure during drift at parking depth (ice mode) (dbar)');

iceDriftAtParkingDepth.id{end+1} = 9;
iceDriftAtParkingDepth.func{end+1} = [];
iceDriftAtParkingDepth.func1{end+1} = [];
iceDriftAtParkingDepth.func2{end+1} = [];
iceDriftAtParkingDepth.name{end+1} = 'number of valve actions during drift at parking depth (ice mode)';
iceDriftAtParkingDepth.fmt{end+1} = '%d';
iceDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(127, 'Number of valve actions during drift at parking depth (ice mode)');
iceDriftAtParkingDepth.time{end+1} = [];
iceDriftAtParkingDepth.traj{end+1} = [];

iceDriftAtParkingDepth.id{end+1} = 10;
iceDriftAtParkingDepth.func{end+1} = [];
iceDriftAtParkingDepth.func1{end+1} = [];
iceDriftAtParkingDepth.func2{end+1} = [];
iceDriftAtParkingDepth.name{end+1} = 'number of pump actions during drift at parking depth (ice mode)';
iceDriftAtParkingDepth.fmt{end+1} = '%d';
iceDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(128, 'Number of pump actions during drift at parking depth (ice mode)');
iceDriftAtParkingDepth.time{end+1} = [];
iceDriftAtParkingDepth.traj{end+1} = [];

iceDriftAtParkingDepth.id{end+1} = 11;
iceDriftAtParkingDepth.func{end+1} = [];
iceDriftAtParkingDepth.func1{end+1} = [];
iceDriftAtParkingDepth.func2{end+1} = [];
iceDriftAtParkingDepth.name{end+1} = 'number of entries in park margin during drift at parking depth (ice mode)';
iceDriftAtParkingDepth.fmt{end+1} = '%d';
iceDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(129, 'Number of entries in park margin during drift at parking depth (ice mode)');
iceDriftAtParkingDepth.time{end+1} = [];
iceDriftAtParkingDepth.traj{end+1} = [];

iceDriftAtParkingDepth.id{end+1} = 12;
iceDriftAtParkingDepth.func{end+1} = [];
iceDriftAtParkingDepth.func1{end+1} = [];
iceDriftAtParkingDepth.func2{end+1} = [];
iceDriftAtParkingDepth.name{end+1} = 'number of exit from park margin during drift at parking depth (ice mode)';
iceDriftAtParkingDepth.fmt{end+1} = '%d';
iceDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(130, 'Number of exit from park margin during drift at parking depth (ice mode)');
iceDriftAtParkingDepth.time{end+1} = [];
iceDriftAtParkingDepth.traj{end+1} = [];

iceStabilizedDriftAtParkingDepth = init_basic_struct;
iceStabilizedDriftAtParkingDepth.pattern = 'UTC=%u-%u-%u %u:%u:%u Ice Park stabilization=%u dbar';
iceStabilizedDriftAtParkingDepth.count = 7;
iceStabilizedDriftAtParkingDepth.id{end+1} = 1:6;
iceStabilizedDriftAtParkingDepth.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
iceStabilizedDriftAtParkingDepth.func1{end+1} = '@(x) adjust_time_cts5(x)';
iceStabilizedDriftAtParkingDepth.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
iceStabilizedDriftAtParkingDepth.name{end+1} = 'stabilized drift at parking depth start date (ice mode)';
iceStabilizedDriftAtParkingDepth.fmt{end+1} = '%g';
iceStabilizedDriftAtParkingDepth.time{end+1} = get_cts5_time_data_init_struct(...
   'STABILIZED PARK START TIME', 'JULD');
iceStabilizedDriftAtParkingDepth.traj{end+1} = [];

iceStabilizedDriftAtParkingDepth.id{end+1} = 7;
iceStabilizedDriftAtParkingDepth.func{end+1} = [];
iceStabilizedDriftAtParkingDepth.func1{end+1} = [];
iceStabilizedDriftAtParkingDepth.func2{end+1} = [];
iceStabilizedDriftAtParkingDepth.name{end+1} = 'stabilized pressure during drift at parking depth (ice mode) (dbar)';
iceStabilizedDriftAtParkingDepth.fmt{end+1} = '%d';
iceStabilizedDriftAtParkingDepth.tech{end+1} = get_cts5_tech_data_init_struct(185, 'Stabilized park pressure (dbar)');
iceStabilizedDriftAtParkingDepth.time{end+1} = [];
iceStabilizedDriftAtParkingDepth.traj{end+1} = [];

presSwitchAct = init_basic_struct;
presSwitchAct.pattern = 'UTC=%u-%u-%u %u:%u:%u Pressure switch activation';
presSwitchAct.count = 6;
presSwitchAct.id{end+1} = 1:6;
presSwitchAct.func{end+1} = '@(x) datenum(sprintf(''%02d%02d%02d%02d%02d%02d'', x(1), x(2), x(3), x(4), x(5), x(6)), ''yymmddHHMMSS'') - g_decArgo_janFirst1950InMatlab';
presSwitchAct.func1{end+1} = '@(x) adjust_time_cts5(x)';
presSwitchAct.func2{end+1} = '@(x) julian_2_gregorian_dec_argo(x)';
presSwitchAct.name{end+1} = 'pressure switch activation';
presSwitchAct.fmt{end+1} = '%g';
presSwitchAct.tech{end+1} = get_cts5_tech_data_init_struct(131, 'Pressure switch activation');
presSwitchAct.tech{end}.func = '@(x) format_date_yyyymmddhhmiss_dec_argo(x)';
presSwitchAct.tech{end}.func1 = '@(x) adjust_time_cts5(x)';

o_techInfoStruct.PROFILE = [];
o_techInfoStruct.PROFILE{end+1} = buoyancyReduction;
o_techInfoStruct.PROFILE{end+1} = descentToParkingDepth;
o_techInfoStruct.PROFILE{end+1} = grounding;
o_techInfoStruct.PROFILE{end+1} = driftAtParkingDepth;
o_techInfoStruct.PROFILE{end+1} = stabilizedDriftAtParkingDepth;
o_techInfoStruct.PROFILE{end+1} = descentToProfileDepth;
o_techInfoStruct.PROFILE{end+1} = standardAscent;
o_techInfoStruct.PROFILE{end+1} = slowAscent;
o_techInfoStruct.PROFILE{end+1} = resumedAscent;
o_techInfoStruct.PROFILE{end+1} = endAscent;
o_techInfoStruct.PROFILE{end+1} = iceDriftAtParkingDepth;
o_techInfoStruct.PROFILE{end+1} = iceStabilizedDriftAtParkingDepth;
o_techInfoStruct.PROFILE{end+1} = presSwitchAct;

dataTransmission = init_basic_struct;
dataTransmission.pattern = 'Upload=%f kB of %u file(s) at %f kB/min in %u session(s)';
dataTransmission.count = 4;
dataTransmission.id{end+1} = 1;
dataTransmission.name{end+1} = 'size of the transmitted data (kB) (for the previous pattern)';
dataTransmission.fmt{end+1} = '%g';
dataTransmission.tech{end+1} = get_cts5_tech_data_init_struct(132, 'Size of the transmitted data (kB) (for the previous pattern)');

dataTransmission.id{end+1} = 2;
dataTransmission.name{end+1} = 'number of transmitted files (for the previous pattern)';
dataTransmission.fmt{end+1} = '%d';
dataTransmission.tech{end+1} = get_cts5_tech_data_init_struct(133, 'Number of transmitted files (for the previous pattern)');

dataTransmission.id{end+1} = 3;
dataTransmission.name{end+1} = 'mean flow rate (kB/min) (for the previous pattern)';
dataTransmission.fmt{end+1} = '%d';
dataTransmission.tech{end+1} = get_cts5_tech_data_init_struct(134, 'Mean flow rate (kB/min) (for the previous pattern)');

dataTransmission.id{end+1} = 4;
dataTransmission.name{end+1} = 'number of transmission sessions (for the previous pattern)';
dataTransmission.fmt{end+1} = '%d';
dataTransmission.tech{end+1} = get_cts5_tech_data_init_struct(135, 'Number of transmission sessions (for the previous pattern)');

remoteControl = init_basic_struct;
remoteControl.pattern = 'Download=command file (%u accepted, %u refused, %u unknown)';
remoteControl.count = 3;
remoteControl.id{end+1} = 1;
remoteControl.name{end+1} = 'number of accepted remote commands (for the previous pattern)';
remoteControl.fmt{end+1} = '%d';
remoteControl.tech{end+1} = get_cts5_tech_data_init_struct(136, 'Number of accepted remote commands (for the previous pattern)');

remoteControl.id{end+1} = 2;
remoteControl.name{end+1} = 'number of refused remote commands (for the previous pattern)';
remoteControl.fmt{end+1} = '%d';
remoteControl.tech{end+1} = get_cts5_tech_data_init_struct(137, 'Number of refused remote commands (for the previous pattern)');

remoteControl.id{end+1} = 3;
remoteControl.name{end+1} = 'number of unknown remote commands (for the previous pattern)';
remoteControl.fmt{end+1} = '%d';
remoteControl.tech{end+1} = get_cts5_tech_data_init_struct(138, 'Number of unknown remote commands (for the previous pattern)');

payloadConfigFileReceived = init_basic_struct;
payloadConfigFileReceived.pattern = 'Download=payload file';
payloadConfigFileReceived.count = 0;
payloadConfigFileReceived.id{end+1} = 1;
payloadConfigFileReceived.name{end+1} = 'payload configuration file received';
payloadConfigFileReceived.tech{end+1} = get_cts5_tech_data_init_struct(139, 'Payload configuration file received');

scriptFileReceived = init_basic_struct;
scriptFileReceived.pattern = 'Download=script file';
scriptFileReceived.count = 0;
scriptFileReceived.id{end+1} = 1;
scriptFileReceived.name{end+1} = 'script file received';
scriptFileReceived.tech{end+1} = get_cts5_tech_data_init_struct(140, 'Script file received');

o_techInfoStruct.DATA = [];
o_techInfoStruct.DATA{end+1} = dataTransmission;
o_techInfoStruct.DATA{end+1} = remoteControl;
o_techInfoStruct.DATA{end+1} = payloadConfigFileReceived;
o_techInfoStruct.DATA{end+1} = scriptFileReceived;

patternDuration = init_basic_struct;
patternDuration.pattern = 'Pattern=%u min';
patternDuration.count = 1;
patternDuration.id{end+1} = 1;
patternDuration.name{end+1} = 'pattern duration (min)';
patternDuration.fmt{end+1} = '%d';
patternDuration.tech{end+1} = get_cts5_tech_data_init_struct(141, 'Pattern duration (min)');

processingVsStandbye = init_basic_struct;
processingVsStandbye.pattern = 'Treatment=%u %%';
processingVsStandbye.count = 1;
processingVsStandbye.id{end+1} = 1;
processingVsStandbye.name{end+1} = 'processing vs standbye ratio (%)';
processingVsStandbye.fmt{end+1} = '%d';
processingVsStandbye.tech{end+1} = get_cts5_tech_data_init_struct(142, 'Processing vs standbye ratio (%)');

hydraulicActions = init_basic_struct;
hydraulicActions.pattern = 'EV/Pump=%u/%u cs';
hydraulicActions.count = 2;
hydraulicActions.id{end+1} = 1;
hydraulicActions.name{end+1} = 'cumulated valve actions duration (csec)';
hydraulicActions.fmt{end+1} = '%d';
hydraulicActions.tech{end+1} = get_cts5_tech_data_init_struct(143, 'Cumulated valve actions duration (csec)');

hydraulicActions.id{end+1} = 2;
hydraulicActions.name{end+1} = 'cumulated pump actions duration (csec)';
hydraulicActions.fmt{end+1} = '%d';
hydraulicActions.tech{end+1} = get_cts5_tech_data_init_struct(144, 'Cumulated pump actions duration (csec)');

sbeActivation = init_basic_struct;
sbeActivation.pattern = 'SBE41=%u min';
sbeActivation.count = 1;
sbeActivation.id{end+1} = 1;
sbeActivation.name{end+1} = 'cumulated SBE activations duration (min)';
sbeActivation.fmt{end+1} = '%d';
sbeActivation.tech{end+1} = get_cts5_tech_data_init_struct(145, 'Cumulated SBE activations duration (min)');

modemActivation = init_basic_struct;
modemActivation.pattern = 'Transmission=%u min';
modemActivation.count = 1;
modemActivation.id{end+1} = 1;
modemActivation.name{end+1} = 'cumulated modem activations duration for the previous pattern (min)';
modemActivation.fmt{end+1} = '%d';
modemActivation.tech{end+1} = get_cts5_tech_data_init_struct(146, 'Cumulated modem activations duration for the previous pattern (min)');

gpsActivation = init_basic_struct;
gpsActivation.pattern = 'GPS=%u s';
gpsActivation.count = 1;
gpsActivation.id{end+1} = 1;
gpsActivation.name{end+1} = 'cumulated GPS activations duration (sec)';
gpsActivation.fmt{end+1} = '%d';
gpsActivation.tech{end+1} = get_cts5_tech_data_init_struct(147, 'Cumulated GPS activations duration (sec)');

o_techInfoStruct.POWER = [];
o_techInfoStruct.POWER{end+1} = patternDuration;
o_techInfoStruct.POWER{end+1} = processingVsStandbye;
o_techInfoStruct.POWER{end+1} = hydraulicActions;
o_techInfoStruct.POWER{end+1} = sbeActivation;
o_techInfoStruct.POWER{end+1} = modemActivation;
o_techInfoStruct.POWER{end+1} = gpsActivation;

alarmPowerOn = init_basic_struct;
alarmPowerOn.pattern = 'Power-on';
alarmPowerOn.count = 0;
alarmPowerOn.id{end+1} = 1;
alarmPowerOn.name{end+1} = 'power-on alarm received';
alarmPowerOn.tech{end+1} = get_cts5_tech_data_init_struct(148, 'Power-on alarm received');

alarmInvalidConfig = init_basic_struct;
alarmInvalidConfig.pattern = 'Bad configuration';
alarmInvalidConfig.count = 0;
alarmInvalidConfig.id{end+1} = 1;
alarmInvalidConfig.name{end+1} = 'invalid configuration alarm received';
alarmInvalidConfig.tech{end+1} = get_cts5_tech_data_init_struct(149, 'Invalid configuration alarm received');

alarmHeavyFloat = init_basic_struct;
alarmHeavyFloat.pattern = 'Flotation (heavy)';
alarmHeavyFloat.count = 0;
alarmHeavyFloat.id{end+1} = 1;
alarmHeavyFloat.name{end+1} = 'heavy float alarm received';
alarmHeavyFloat.tech{end+1} = get_cts5_tech_data_init_struct(150, 'Heavy float alarm received');

alarmLightFloat = init_basic_struct;
alarmLightFloat.pattern = 'Flotation (light)';
alarmLightFloat.count = 0;
alarmLightFloat.id{end+1} = 1;
alarmLightFloat.name{end+1} = 'light float alarm received';
alarmLightFloat.tech{end+1} = get_cts5_tech_data_init_struct(151, 'Light float alarm received');

alarmSelfTest = init_basic_struct;
alarmSelfTest.pattern = 'Autotest fail=%s';
alarmSelfTest.count = 1;
alarmSelfTest.id{end+1} = 1;
alarmSelfTest.name{end+1} = 'selft test alarm received';
alarmSelfTest.fmt{end+1} = '%s';
alarmSelfTest.tech{end+1} = get_cts5_tech_data_init_struct(152, 'Selft test alarm received');

alarmLowBatt = init_basic_struct;
alarmLowBatt.pattern = 'Vbatt low';
alarmLowBatt.count = 0;
alarmLowBatt.id{end+1} = 1;
alarmLowBatt.name{end+1} = 'low battery alarm received';
alarmLowBatt.tech{end+1} = get_cts5_tech_data_init_struct(154, 'Low battery alarm received');

alarmLowBattPeak = init_basic_struct;
alarmLowBattPeak.pattern = 'Vbatt peak low';
alarmLowBattPeak.count = 0;
alarmLowBattPeak.id{end+1} = 1;
alarmLowBattPeak.name{end+1} = 'low battery peak alarm received';
alarmLowBattPeak.tech{end+1} = get_cts5_tech_data_init_struct(155, 'Low battery peak alarm received');

alarmLowExternalPres = init_basic_struct;
alarmLowExternalPres.pattern = 'Pe low (%u dbar)';
alarmLowExternalPres.count = 1;
alarmLowExternalPres.id{end+1} = 1;
alarmLowExternalPres.name{end+1} = 'low external pressure alarm received (dbar)';
alarmLowExternalPres.fmt{end+1} = '%d';
alarmLowExternalPres.tech{end+1} = get_cts5_tech_data_init_struct(156, 'Low external pressure alarm received (dbar)');

alarmHighExternalPres = init_basic_struct;
alarmHighExternalPres.pattern = 'Pe high (%u dbar)';
alarmHighExternalPres.count = 1;
alarmHighExternalPres.id{end+1} = 1;
alarmHighExternalPres.name{end+1} = 'high external pressure alarm received (dbar)';
alarmHighExternalPres.fmt{end+1} = '%d';
alarmHighExternalPres.tech{end+1} = get_cts5_tech_data_init_struct(157, 'High external pressure alarm received (dbar)');

alarmExternalPresSensor = init_basic_struct;
alarmExternalPresSensor.pattern = 'Pe broken';
alarmExternalPresSensor.count = 0;
alarmExternalPresSensor.id{end+1} = 1;
alarmExternalPresSensor.name{end+1} = 'external pressure sensor alarm received';
alarmExternalPresSensor.tech{end+1} = get_cts5_tech_data_init_struct(158, 'External pressure sensor alarm received');

alarmHighInternalPres = init_basic_struct;
alarmHighInternalPres.pattern = 'Pi high';
alarmHighInternalPres.count = 0;
alarmHighInternalPres.id{end+1} = 1;
alarmHighInternalPres.name{end+1} = 'high internal pressure alarm received';
alarmHighInternalPres.tech{end+1} = get_cts5_tech_data_init_struct(159, 'High internal pressure alarm received');

alarmGrounding = init_basic_struct;
alarmGrounding.pattern = 'Grounding (%u dbar)';
alarmGrounding.count = 1;
alarmGrounding.id{end+1} = 1;
alarmGrounding.name{end+1} = 'grounding alarm received (dbar)';
alarmGrounding.fmt{end+1} = '%d';
alarmGrounding.traj{end+1} = get_cts5_traj_data_init_struct(...
   g_MC_Grounded, 'PRES', ...
   'Grounding alarm received (dbar)');

alarmHanging = init_basic_struct;
alarmHanging.pattern = 'Hanging (%u dbar)';
alarmHanging.count = 1;
alarmHanging.id{end+1} = 1;
alarmHanging.name{end+1} = 'hanging pressure alarm received (dbar)';
alarmHanging.fmt{end+1} = '%d';
alarmHanging.tech{end+1} = get_cts5_tech_data_init_struct(161, 'Hanging pressure alarm received (dbar)');

alarmBraking = init_basic_struct;
alarmBraking.pattern = 'Braking';
alarmBraking.count = 0;
alarmBraking.id{end+1} = 1;
alarmBraking.name{end+1} = 'braking during descent alarm received';
alarmBraking.tech{end+1} = get_cts5_tech_data_init_struct(162, 'Braking during descent alarm received');

alarmSystem = init_basic_struct;
alarmSystem.pattern = 'System';
alarmSystem.count = 0;
alarmSystem.id{end+1} = 1;
alarmSystem.name{end+1} = 'system alarm received';
alarmSystem.tech{end+1} = get_cts5_tech_data_init_struct(163, 'System alarm received');

alarmPayload = init_basic_struct;
alarmPayload.pattern = 'Payload';
alarmPayload.count = 0;
alarmPayload.id{end+1} = 1;
alarmPayload.name{end+1} = 'payload alarm received';
alarmPayload.tech{end+1} = get_cts5_tech_data_init_struct(164, 'Payload alarm received');

alarmGps = init_basic_struct;
alarmGps.pattern = 'GPS';
alarmGps.count = 0;
alarmGps.id{end+1} = 1;
alarmGps.name{end+1} = 'GPS alarm received';
alarmGps.tech{end+1} = get_cts5_tech_data_init_struct(165, 'GPS alarm received');

alarmHydraulic = init_basic_struct;
alarmHydraulic.pattern = 'Hydraulic';
alarmHydraulic.count = 0;
alarmHydraulic.id{end+1} = 1;
alarmHydraulic.name{end+1} = 'hydraulic alarm received';
alarmHydraulic.tech{end+1} = get_cts5_tech_data_init_struct(166, 'Hydraulic alarm received');

alarmADC = init_basic_struct;
alarmADC.pattern = 'ADC';
alarmADC.count = 0;
alarmADC.id{end+1} = 1;
alarmADC.name{end+1} = 'ADC alarm received';
alarmADC.tech{end+1} = get_cts5_tech_data_init_struct(167, 'ADC alarm received');

alarmFile = init_basic_struct;
alarmFile.pattern = 'File (skip)';
alarmFile.count = 0;
alarmFile.id{end+1} = 1;
alarmFile.name{end+1} = 'file (skip) alarm received';
alarmFile.tech{end+1} = get_cts5_tech_data_init_struct(168, 'File (skip) alarm received');

alarmRTC = init_basic_struct;
alarmRTC.pattern = 'RTC';
alarmRTC.count = 0;
alarmRTC.id{end+1} = 1;
alarmRTC.name{end+1} = 'RTC alarm received';
alarmRTC.tech{end+1} = get_cts5_tech_data_init_struct(169, 'RTC alarm received');

alarmPresSwitch = init_basic_struct;
alarmPresSwitch.pattern = 'Pressure switch';
alarmPresSwitch.count = 0;
alarmPresSwitch.id{end+1} = 1;
alarmPresSwitch.name{end+1} = 'pressure switch alarm received';
alarmPresSwitch.tech{end+1} = get_cts5_tech_data_init_struct(170, 'Pressure switch alarm received');

alarmEOL = init_basic_struct;
alarmEOL.pattern = 'End of life';
alarmEOL.count = 0;
alarmEOL.id{end+1} = 1;
alarmEOL.name{end+1} = 'EOL alarm received';
alarmEOL.tech{end+1} = get_cts5_tech_data_init_struct(171, 'EOL alarm received');

alarmRescue = init_basic_struct;
alarmRescue.pattern = 'Rescue';
alarmRescue.count = 0;
alarmRescue.id{end+1} = 1;
alarmRescue.name{end+1} = 'rescue alarm received';
alarmRescue.tech{end+1} = get_cts5_tech_data_init_struct(172, 'Rescue alarm received');

alarmFeedback = init_basic_struct;
alarmFeedback.pattern = 'Feedback';
alarmFeedback.count = 0;
alarmFeedback.id{end+1} = 1;
alarmFeedback.name{end+1} = 'feedback alarm received';
alarmFeedback.tech{end+1} = get_cts5_tech_data_init_struct(173, 'Feedback alarm received');

o_techInfoStruct.ALARM = [];
o_techInfoStruct.ALARM{end+1} = alarmPowerOn;
o_techInfoStruct.ALARM{end+1} = alarmInvalidConfig;
o_techInfoStruct.ALARM{end+1} = alarmHeavyFloat;
o_techInfoStruct.ALARM{end+1} = alarmLightFloat;
o_techInfoStruct.ALARM{end+1} = alarmSelfTest;
o_techInfoStruct.ALARM{end+1} = alarmLowBatt;
o_techInfoStruct.ALARM{end+1} = alarmLowBattPeak;
o_techInfoStruct.ALARM{end+1} = alarmLowExternalPres;
o_techInfoStruct.ALARM{end+1} = alarmHighExternalPres;
o_techInfoStruct.ALARM{end+1} = alarmExternalPresSensor;
o_techInfoStruct.ALARM{end+1} = alarmHighInternalPres;
o_techInfoStruct.ALARM{end+1} = alarmGrounding;
o_techInfoStruct.ALARM{end+1} = alarmHanging;
o_techInfoStruct.ALARM{end+1} = alarmBraking;
o_techInfoStruct.ALARM{end+1} = alarmSystem;
o_techInfoStruct.ALARM{end+1} = alarmPayload;
o_techInfoStruct.ALARM{end+1} = alarmGps;
o_techInfoStruct.ALARM{end+1} = alarmHydraulic;
o_techInfoStruct.ALARM{end+1} = alarmADC;
o_techInfoStruct.ALARM{end+1} = alarmFile;
o_techInfoStruct.ALARM{end+1} = alarmRTC;
o_techInfoStruct.ALARM{end+1} = alarmPresSwitch;
o_techInfoStruct.ALARM{end+1} = alarmEOL;
o_techInfoStruct.ALARM{end+1} = alarmRescue;
o_techInfoStruct.ALARM{end+1} = alarmFeedback;

return

% ------------------------------------------------------------------------------
% Get the basic structure to store information on each item of a section.
%
% SYNTAX :
%  [o_newStruct] = init_basic_struct
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%   o_newStruct : initializes new structure
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/21/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_newStruct] = init_basic_struct

o_newStruct = [];
o_newStruct.rawData = []; % data read in the input file
o_newStruct.patternStart = []; % start expected pattern (used to retrieve data between patternStart and patternEnd)
o_newStruct.patternEnd = []; % end expected pattern (used to retrieve data between patternStart and patternEnd)
o_newStruct.pattern = []; % expected pattern (used to retrieve data with sscanf function)
o_newStruct.count = 1; % number of expected outputs from sscanf function
o_newStruct.id = []; % ids of the sscanf output to be used as input parameters of the func function
o_newStruct.func = []; % function to be applied to ids of sscanf outputs to get the final information
o_newStruct.func1 = []; % function to be applied to final information to adjust it from clock offset (time adjustment)
o_newStruct.func2 = []; % function to be applied to final information to get understandable final output
o_newStruct.name = []; % name of the final information
o_newStruct.fmt = []; % format to be applied to the final information to be printed with a sprintf function
o_newStruct.tech = []; % to store collected information for the TECH (and TECH_AUX) nc file
o_newStruct.time = []; % to store collected time information
o_newStruct.traj = []; % to store collected information for the TRAJ nc file
o_newStruct.meta = []; % to store collected information for the META (and META_AUX) nc file

return

% ------------------------------------------------------------------------------
% Get the basic structure to store technical information.
%
% SYNTAX :
%  [o_dataStruct] = get_cts5_tech_data_init_struct(a_techId, a_label)
%
% INPUT PARAMETERS :
%   a_techId : technical item Id
%   a_label  : technical item label
%
% OUTPUT PARAMETERS :
%   o_dataStruct : technical data initialized structure
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/21/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_dataStruct] = get_cts5_tech_data_init_struct(a_techId, a_label)

% output parameters initialization
o_dataStruct = struct( ...
   'label', a_label, ...
   'techId', a_techId, ...
   'func', [], ...
   'valueRaw', [], ...
   'valueOutput', [], ...
   'source', 'T' ... % 'T': from tech data 'E': from event data
   );

return

% ------------------------------------------------------------------------------
% Get the basic structure to store trajectory information.
%
% SYNTAX :
%  [o_dataStruct] = get_cts5_traj_data_init_struct(a_measCode, a_paramName, a_label)
%
% INPUT PARAMETERS :
%   a_measCode  : trajectory item measurement code
%   a_paramName : trajectory item parameter name
%   a_label     : trajectory item label
%
% OUTPUT PARAMETERS :
%   o_dataStruct : trajectory data initialized structure
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/21/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_dataStruct] = get_cts5_traj_data_init_struct(a_measCode, a_paramName, a_label)

% output parameters initialization
o_dataStruct = struct( ...
   'label', a_label, ...
   'paramName', a_paramName, ...
   'measCode', a_measCode, ...
   'group', 0, ... % if different from 0: many items are linked to a same measCode
   'value', [], ...
   'valueAdj', [], ...
   'source', 'T' ... % 'T': from tech data 'E': from event data
   );

return

% ------------------------------------------------------------------------------
% Get the basic structure to store meta-data information.
%
% SYNTAX :
%  [o_dataStruct] = get_cts5_meta_data_init_struct(a_metaId, a_label)
%
% INPUT PARAMETERS :
%   a_metaId : meta-data item Id
%   a_label  : meta-data item label
%
% OUTPUT PARAMETERS :
%   o_dataStruct : meta-data data initialized structure
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/21/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_dataStruct] = get_cts5_meta_data_init_struct(a_metaId, a_label)

% output parameters initialization
o_dataStruct = struct( ...
   'label', a_label, ...
   'techId', a_metaId, ...
   'value', [], ...
   'source', 'T' ... % 'T': from tech data 'E': from event data
   );

return

% ------------------------------------------------------------------------------
% Get the basic structure to store time information.
%
% SYNTAX :
%  [o_dataStruct] = get_cts5_time_data_init_struct(a_label, a_paramName)
%
% INPUT PARAMETERS :
%   a_label     : time item label
%   a_paramName : time item parameter name
%
% OUTPUT PARAMETERS :
%   o_dataStruct : time data initialized structure
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/21/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_dataStruct] = get_cts5_time_data_init_struct(a_label, a_paramName)

% output parameters initialization
o_dataStruct = struct( ...
   'label', a_label, ...
   'paramName', a_paramName, ...
   'time', [], ...
   'timeAdj', [], ...
   'pres', [], ...
   'source', 'T' ... % 'T': from tech data 'E': from event data
   );

return
