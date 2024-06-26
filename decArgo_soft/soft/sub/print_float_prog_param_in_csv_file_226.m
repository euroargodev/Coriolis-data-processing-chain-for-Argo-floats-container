% ------------------------------------------------------------------------------
% Print parameter message data in output CSV file.
%
% SYNTAX :
%  print_float_prog_param_in_csv_file_226(a_floatParam1, a_floatParam2)
%
% INPUT PARAMETERS :
%   a_floatParam1 : parameter message #1 data
%   a_floatParam2 : parameter message #2 data
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   03/14/2023 - RNU - creation
% ------------------------------------------------------------------------------
function print_float_prog_param_in_csv_file_226(a_floatParam1, a_floatParam2)

% current float WMO number
global g_decArgo_floatNum;

% current cycle number
global g_decArgo_cycleNum;

% output CSV file Id
global g_decArgo_outputCsvFileId;


if (isempty(a_floatParam1) && isempty(a_floatParam2))
   return
end

ID_OFFSET = 1;

if (size(a_floatParam1, 1) > 1)
   fprintf('ERROR: Float #%d cycle #%d: BUFFER anomaly (%d param messages #1 in the buffer)\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, ...
      size(a_floatParam1, 1));
elseif (size(a_floatParam1, 1) == 1)
   id = 1;
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; PARAMETERS #1 PACKET (#%d)\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), id);
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Transmission time of parameters #1 packet; %s\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), julian_2_gregorian_dec_argo(a_floatParam1(id, end)));
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; PARAM #1: MISCELLANEOUS\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Cycle number; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 1+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Iridium session indicator (0=first session, 1=second session); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float time hour; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 3+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float time minute; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 4+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float time second; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 5+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float time gregorian day; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 6+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float time gregorian month; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 7+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float time gregorian year; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 8+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; => Float time; %s\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), julian_2_gregorian_dec_argo(a_floatParam1(id, end-1)));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; Float serial number; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 9+ID_OFFSET));
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; PARAM #1: MISSION PARAMETERS\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC0: Total number of cycles; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 10+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC1: Number of cycles with cycle duration #1; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 11+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC2: Cycle duration #1; %d; hours\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 12+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC3: Cycle duration #2; %d; hours\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 13+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC4: Float reference day; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 14+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC5: Expected surface time (hour); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 15+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC6: Delay before mission; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 16+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC7: CTD sensor acquisition mode; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 17+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC8: Descent to park sampling time; %d; seconds\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 18+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC9: Drift at park sampling time; %d; hours\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 19+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC10: Ascent sampling time; %d; seconds\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 20+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC11: Park pressure for the MC1 first cycles; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 21+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC12: Profile pressure for the MC1 first cycles; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 22+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC13: Park pressure after the MC1 first cycles; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 23+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC14: Profile pressure after the MC1 first cycles; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 24+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC15: Second profile pressure repetition rate (not used if = 1); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 25+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC16: Second profile pressure; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 26+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC17: Threshold for shallow to intermediate depth zone; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 27+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC18: Threshold for intermediate to deep depth zone; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 28+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC19: Slice thickness in surface depth zone; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 29+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC20: Slice thickness in intermediate depth zone; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 30+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC21: Slice thickness in deep depth zone; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 31+ID_OFFSET));   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC22: Iridium EOL transmission period; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 32+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC23: Iridium second session waiting time; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 33+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC24: Grounding mode (1=stay grounded, 0=pressure switch); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 34+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC25: Grounding switch pressure adjustment; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 35+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC26: Delay after grounding at surface; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 36+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC27: Optode type; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 37+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC28: CTD pump cut-off pressure; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 38+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC29: In air acquisition periodicity; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 39+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC30: In air acquisition sampling time; %d; seconds\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 40+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC31: In air acquisition phase duration; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 41+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC32: Ascent treatment type in zone 1-Surface (0:average, 1:raw); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 42+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC33: Ascent treatment type in zone 2-Intermediate (0:average, 1:raw); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 43+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; MC34: Ascent treatment type in zone 3-Deep (0:average, 1:raw); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 44+ID_OFFSET));
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; PARAM #1: TECHNICAL PARAMETERS\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC0: EV max duration on surface; %d; csec\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 45+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC1: EV max volume during descent and repositioning; %d; cm3\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 46+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC2: Pump max duration during repositioning; %d; csec\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 47+ID_OFFSET)*10);
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC3: Pump max duration during ascent; %d; csec\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 48+ID_OFFSET)*10);
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC4: Pump duration during buoyancy acquisition; %d;csec\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 49+ID_OFFSET)*1000);
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC5: Pressure target tolerance for stabilization; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 50+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC6: Max pressure before emergency ascent; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 51+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC7: Buoyancy reduction first threshold; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 52+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC8: Buoyancy reduction second threshold; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 53+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC9: Number of out of tolerance pressures before repositioning; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 54+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC10: Min oil volume for grounding detection; %d; cm3\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 55+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC11: Min pressure threshold to switch pressure (in grounding mode 0); %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 56+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC12: Pressure target tolerance during drift; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 57+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC13: Average descent speed; %d; mm/s\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 58+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC14: Park pressure increment between cycles; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 59+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC15: End of ascent pressure; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 60+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC16: Average ascent speed; %d; mm/s\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 61+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC17: Pressure check period during ascent; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 62+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC18: Min vertical displacement to detect a stabilization during ascent; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 63+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC19: GPS session duration time-out; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 64+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC20: Hydraulic packets transmission flag; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 65+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC21: Delay before reset-offset command; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 66+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC22: Pump duration during buoyancy acquisition for in air; %d; csec\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 67+ID_OFFSET)*1000);
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC23: Iridium timeout; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 68+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC24: Pressure check period during descent; %d; min\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 69+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC25: Min vertical displacement to detect a stabilization during descent; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 70+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC26: Self test internal vacuum offset; %d; mbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 71+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC27: TEMP_CNDC transmission flag; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 72+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC28: Internal pressure calibration coeficient #1; %.3f\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 73+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog1_%d; TC29: Internal pressure calibration coeficient #2; %f\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam1(id, 2+ID_OFFSET), a_floatParam1(id, 74+ID_OFFSET));
end

if (size(a_floatParam2, 1) > 1)
   fprintf('ERROR: Float #%d cycle #%d: BUFFER anomaly (%d param messages #2 in the buffer)\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, ...
      size(a_floatParam2, 1));
elseif (size(a_floatParam2, 1) == 1)
   id = 1;
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; PARAMETERS #2 PACKET (#%d)\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), id);
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Transmission time of parameters #2 packet; %s\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), julian_2_gregorian_dec_argo(a_floatParam2(id, end)));
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; PARAM #2: MISCELLANEOUS\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Cycle number; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 1+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Iridium session indicator (0=first session, 1=second session); %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float time hour; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 3+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float time minute; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 4+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float time second; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 5+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float time gregorian day; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 6+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float time gregorian month; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 7+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float time gregorian year; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 8+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; => Float time; %s\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), julian_2_gregorian_dec_argo(a_floatParam2(id, end-1)));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; Float serial number; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 9+ID_OFFSET));
   
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; PARAM #2: ICE DETECTION PARAMETERS\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC0: Nb of day without ascent if Ice detected; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 10+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC1: Nb of day before ascent even with ice detected; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 11+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC2: Nb of detection to confirm Ice at surface; %d\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 12+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC3: Start pressure detection; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 13+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC4: Stop pressure detection; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 14+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC5: Temperature threshold; %.3f; degC\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 15+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC6: Slowdown pressure threshold; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 16+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC7: Pressure acquisition period during ascent (slow speed), once P < IC6; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 17+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC8: Pressure delta min before pump action; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 18+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC9: Pump action duration; %d; csec\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 19+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC10: GPS timeout; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 20+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC11: First Iridium lock timetout; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 21+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC12: Delay before ascent blocking detection; %d; minutes\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 22+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC13: Pressure offset; %d; dbar\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 23+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC14: Valve action volume; %d; cm3\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 24+ID_OFFSET));
   fprintf(g_decArgo_outputCsvFileId, '%d; %d; Prog2_%d; IC15: Max valve volume to detect grounding; %d; cm3\n', ...
      g_decArgo_floatNum, g_decArgo_cycleNum, a_floatParam2(id, 2+ID_OFFSET), a_floatParam2(id, 25+ID_OFFSET));
end

return
