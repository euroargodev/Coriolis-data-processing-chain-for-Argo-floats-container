% ------------------------------------------------------------------------------
% Print one packet of float technical data in output CSV file.
%
% SYNTAX :
%  print_float_tech_data_in_csv_file_ir_sbd2_one( ...
%    a_cycleNum, a_profNum, a_phaseNum, a_dataIndex, ...
%    a_tabTech)
%
% INPUT PARAMETERS :
%   a_cycleNum  : cycle number of the packet
%   a_profNum   : profile number of the packet
%   a_phaseNum  : phase number of the packet
%   a_dataIndex : index of the packet
%   a_tabTech   : float technical data
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   12/01/2014 - RNU - creation
% ------------------------------------------------------------------------------
function print_float_tech_data_in_csv_file_ir_sbd2_one( ...
   a_cycleNum, a_profNum, a_phaseNum, a_dataIndex, ...
   a_tabTech)

% current float WMO number
global g_decArgo_floatNum;

% output CSV file Id
global g_decArgo_outputCsvFileId;

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: GENERAL INFORMATION\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Packet time; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   julian_2_gregorian_dec_argo(a_tabTech(a_dataIndex, 1)));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Float serial number; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 2));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Total number of profiles done; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 3));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Cycle #; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 4));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Profile #; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 5));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Cycle start day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 6));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Cycle start hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 7), format_time_dec_argo(a_tabTech(a_dataIndex, 7)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Phase #; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 8));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Sensor board dialog error; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 9));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; FP timeout; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 10));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Internal vacuum (5 mbar resolution); %d; mbar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 11));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Battery voltage (voltage dropout from 15V, resolution 0.1V); %d; =>; %.1f\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 12), 15-a_tabTech(a_dataIndex, 12)/10);
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Real Time Clock state; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 13));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: BUOYANCY REDUCTION\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Buoyancy reduction start day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 14));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Buoyancy reduction start hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 15), format_time_dec_argo(a_tabTech(a_dataIndex, 15)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; EV timing opening; %d; min\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 16));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of valve actions at the surface; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 17));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: DESCENT TO PARK PRES\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to park start day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 18));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to park start hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 19), format_time_dec_argo(a_tabTech(a_dataIndex, 19)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; First stabilization day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 20));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; First stabilization hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 21), format_time_dec_argo(a_tabTech(a_dataIndex, 21)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; First stabilization pressure; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 26));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to park end day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 22));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to park end hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 23), format_time_dec_argo(a_tabTech(a_dataIndex, 23)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of valve actions during descent to park; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 24));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of pump actions during descent to park; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 25));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Max pressure during descent to park; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 27));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: DRIFT AT PARK PRES\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of entrance in drift target range (end of descent); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 28));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of repositions during drift at park; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 29));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Min pressure during drift at park; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 30));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Max pressure during drift at park; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 31));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of EV actions during drift at park; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 32));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of pump actions during drift at park; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 33));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: DESCENT TO PROF PRES\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to prof start day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 34));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to prof start hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 35), format_time_dec_argo(a_tabTech(a_dataIndex, 35)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to prof end day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 36));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Descent to prof end hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 37), format_time_dec_argo(a_tabTech(a_dataIndex, 37)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of valve actions during descent to prof; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 38));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of pump actions during descent to prof; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 39));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Max pressure during descent to prof; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 40));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: DRIFT AT PROF PRES\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of entrance in prof target range (end of descent); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 41));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of repositions during drift at prof; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 42));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of valve actions during drift at prof; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 43));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of pump actions during drift at prof; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 44));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Min pressure during drift at prof; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 45));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Max pressure during drift at prof; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 46));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: ASCENT TO SURFACE\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Ascent start day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 47));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Ascent start hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 48), format_time_dec_argo(a_tabTech(a_dataIndex, 48)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Ascent end day (in mission day); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 49));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Ascent end hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 50), format_time_dec_argo(a_tabTech(a_dataIndex, 50)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of pump actions during ascent; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 51));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: GROUNDING\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Grounding detected (0=N, 1=Y); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 52));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Grounding pressure; %d; bar\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 53));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Grounding day (relative to the beginning of current cycle); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 54));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Grounding hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 55), format_time_dec_argo(a_tabTech(a_dataIndex, 55)/60));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: EMERGENCY ASCENT\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of emergency ascent; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 56));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; First emergency ascent day (relative to the beginning of current cycle); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; First emergency ascent hour (minutes in day); %d; =>; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 57), format_time_dec_argo(a_tabTech(a_dataIndex, 57)/60));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; First emergency ascent pressure; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 58));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of pump actions during the first emergency ascent; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 59));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: RECEIVED REMOTE CONTROL\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of received remote control; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 61));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Number of rejected remote control; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 62));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: GPS DATA\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS latitude in degrees; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 63));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS latitude in minutes; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 64));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS latitude in fractions of minutes (4th decimal); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 65));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS latitude direction (0=North 1=South); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 66));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS longitude in degrees; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 67));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS longitude in minutes; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 68));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS longitude in fractions of minutes (4th decimal); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 69));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS longitude direction (0=East 1=West); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 70));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; GPS valid fix (1=Valid, 0=Not valid); %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 71));
[lonStr, latStr] = format_position(a_tabTech(a_dataIndex, 76), a_tabTech(a_dataIndex, 77));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; => GPS position (lon, lat); %.4f; %.4f; =>; %s; %s\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 76), a_tabTech(a_dataIndex, 77), lonStr, latStr);

% janFirst1950InMatlab = datenum('1950-01-01 00:00:00', 'yyyy-mm-dd HH:MM:SS');
% fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; => GPS position (lon, lat); %s; %.4f; %.4f\n', ...
%    g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
%    datestr(a_tabTech(a_dataIndex, 1)+janFirst1950InMatlab, 'dd/mm/yyyy HH:MM:SS'), ...
%    a_tabTech(a_dataIndex, 76), a_tabTech(a_dataIndex, 77));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; TECH: MISCELLANEOUS\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum));

fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; State of the show mode vector board; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 72));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; State of the show mode sensor board; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 73));
fprintf(g_decArgo_outputCsvFileId, '%d; %d; %d; %s; float tech; Sensor board status; %d\n', ...
   g_decArgo_floatNum, a_cycleNum, a_profNum, get_phase_name(a_phaseNum), ...
   a_tabTech(a_dataIndex, 74));

return
