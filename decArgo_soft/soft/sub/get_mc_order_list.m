% ------------------------------------------------------------------------------
% Retrieve MC measurements order assigned to a give decoder Id.
%
% SYNTAX :
%  [o_mcOrderList] = get_mc_order_list(a_decoderId)
%
% INPUT PARAMETERS :
%   a_decoderId : float decoder Id
%
% OUTPUT PARAMETERS :
%   o_mcOrderList : MCs ordering list
%
% EXAMPLES :
%
% SEE ALSO : 
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   11/02/2015 - RNU - creation
% ------------------------------------------------------------------------------
function [o_mcOrderList] = get_mc_order_list(a_decoderId)

% output parameters initialization
o_mcOrderList = [];

% current float WMO number
global g_decArgo_floatNum;

% global measurement codes
global g_MC_FillValue;
global g_MC_Launch;
global g_MC_CycleStart;
global g_MC_DST;
global g_MC_PressureOffset
global g_MC_MinPresInDriftAtParkSupportMeas;
global g_MC_MaxPresInDriftAtParkSupportMeas;
global g_MC_FST;
global g_MC_SpyInDescToPark;
global g_MC_DescProf;
global g_MC_MaxPresInDescToPark;
global g_MC_DET;
global g_MC_DescProfDeepestBin;
global g_MC_PST;
global g_MC_SpyAtPark;
global g_MC_DriftAtPark;
global g_MC_DriftAtParkStd;
global g_MC_DriftAtParkMeanOfDiff;
global g_MC_DriftAtParkMean;
global g_MC_MinPresInDriftAtPark;
global g_MC_MaxPresInDriftAtPark;
global g_MC_PET;
global g_MC_RPP;
global g_MC_SpyInDescToProf;
global g_MC_MaxPresInDescToProf;
global g_MC_DDET;
global g_MC_DPST;
global g_MC_SpyAtProf;
global g_MC_MinPresInDriftAtProf;
global g_MC_MaxPresInDriftAtProf;
global g_MC_AST;
global g_MC_DownTimeEnd;
global g_MC_AST_Float;
global g_MC_AscProfDeepestBin;
global g_MC_SpyInAscProf;
global g_MC_AscProf;
global g_MC_MedianValueInAscProf;
global g_MC_LastAscPumpedCtd;
global g_MC_ContinuousProfileStartOrStop;
global g_MC_AET;
global g_MC_AET_Float;
global g_MC_SpyAtSurface;
global g_MC_TST;
global g_MC_TST_Float;
global g_MC_FMT;
global g_MC_Surface;
global g_MC_LMT;
global g_MC_TET;
global g_MC_Grounded;

global g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToDST;
global g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToDST;
global g_MC_InWaterSeriesOfMeasPartOfEndOfProfileRelativeToTST;
global g_MC_InAirSingleMeasRelativeToTST;
global g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToTST;
global g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToTST;
global g_MC_InAirSingleMeasRelativeToTET;


switch (a_decoderId)

   case {1, 3, 4, 11, 12, 17, 19, 24, 25, 27, 28, 29, 31}
      % Provor/Arvor Argos pre-Naos 2013
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_DST ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_AscProf ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         ];
      
   case {30, 32}
      % Provor/Arvor Argos post-Naos 2013
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_AscProf ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];

   case {201, 202, 203}
      % Arvor Deep without "NS & IA"
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_SpyInDescToPark ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_SpyInDescToProf ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_SpyAtProf ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_SpyInAscProf ...
         g_MC_AscProf ...
         g_MC_LastAscPumpedCtd ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];
   
   case {215, 216, 218, 221}
      % Arvor Deep with "NS & IA"
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_SpyInDescToPark ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_SpyInDescToProf ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_SpyAtProf ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_SpyInAscProf ...
         g_MC_AscProf ...
         g_MC_LastAscPumpedCtd ...
         g_MC_AET ...
         g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_TST ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];      

   case {204, 205, 206, 207, 208}
      % Provor/Arvor Iridium without "NS & IA"
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_AscProf ...
         g_MC_LastAscPumpedCtd ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];
      
   case {209}
      % Arvor Iridium 2DO
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_AscProf ...
         g_MC_LastAscPumpedCtd ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];
      
   case {210, 211, 212, 222, 213, 214, 217, 223, 225}
      % Provor/Arvor Iridium with "NS & IA"
      % Arvor-ARN Iridium
      % Arvor-ARN-Ice Iridium 5.45 & 5.47
      % Provor-ARN-DO Iridium
      % Provor-ARN-DO-Ice Iridium
      % Arvor-ARN-DO-Ice Iridium 5.46
      % Arvor-ARN-DO-Ice Iridium 5.48
      % Provor-ARN-DO-Ice Iridium 5.76
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_SpyInDescToPark ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_SpyInDescToProf ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_SpyAtProf ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_SpyInAscProf ...
         g_MC_AscProf ...
         g_MC_LastAscPumpedCtd ...
         g_MC_AET ...
         g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];

   case {224, 226}
      % Arvor-ARN-Ice RBR Iridium 5.49
      % Arvor-ARN-Ice RBR 1 Hz Iridium 5.51
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_SpyInDescToPark ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_SpyInDescToProf ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_SpyAtProf ...
         g_MC_AST ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AscProfDeepestBin ...
         g_MC_SpyInAscProf ...
         g_MC_AscProf ...
         g_MC_AET ...
         g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];           
      
   case {219, 220}
      % Arvor-C 5.3 & 5.301
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_PST ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];      
      
   case {105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 301, 302, 303}
      % Provor CTS4 & Arvor CM
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToDST ...
         g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToDST ...
         g_MC_DST ...
         g_MC_SpyInDescToPark ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_MaxPresInDescToPark ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_SpyInDescToProf ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_SpyAtProf ...
         g_MC_MinPresInDriftAtProf ...
         g_MC_MaxPresInDriftAtProf ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_SpyInAscProf ...
         g_MC_AscProf ...
         g_MC_LastAscPumpedCtd ...
         g_MC_AET ...
         g_MC_SpyAtSurface ...
         g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_LMT ...
         g_MC_TET ...
         g_MC_Grounded ...
         ];

   case {1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, ...
         1012, 1013, 1014, 1015, 1016, 1021, 1022}
      % Apex Argos
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_DST ...
         g_MC_DescProf ...
         g_MC_DET ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_PET ...
         g_MC_RPP ...
         g_MC_DriftAtParkMean ...
         g_MC_DriftAtParkMeanOfDiff ...
         g_MC_DriftAtParkStd ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MinPresInDriftAtParkSupportMeas ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtParkSupportMeas ...
         g_MC_DDET ...
         g_MC_DownTimeEnd ...
         g_MC_AST ...
         g_MC_AST_Float ...
         g_MC_AscProfDeepestBin ...
         g_MC_MedianValueInAscProf ...
         g_MC_AET ...
         g_MC_AET_Float ...
         g_MC_TST ...
         g_MC_TST_Float ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_InAirSingleMeasRelativeToTET ...
         g_MC_LMT ...
         g_MC_TET ...
         ];
      
   case {1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114}
      % Apex APF9 Iridium Rudics
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_DescProf ...
         g_MC_PST ...
         g_MC_DET ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_RPP ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_AET ...
         g_MC_InAirSingleMeasRelativeToTST ...
         g_MC_Surface ...
         g_MC_TST ...
         g_MC_TET ...
         ];
      
   case {1314}
      % Apex APF9 Iridium Sbd
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_DescProf ...
         g_MC_PST ...
         g_MC_DET ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_RPP ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_AET ...
         g_MC_InAirSingleMeasRelativeToTST ...
         g_MC_FMT ...
         g_MC_Surface ...
         g_MC_TST ...
         g_MC_LMT ...
         g_MC_TET ...
         ];
      
   case {1201}
      % Navis
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_DST ...
         g_MC_DescProf ...
         g_MC_DET ...
         g_MC_PST ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_RPP ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_AscProf ...
         g_MC_AET ...
         g_MC_InWaterSeriesOfMeasPartOfEndOfProfileRelativeToTST ...
         g_MC_InWaterSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_InAirSeriesOfMeasPartOfSurfaceSequenceRelativeToTST ...
         g_MC_TST ...
         g_MC_Surface ...
         g_MC_TET ...
         ];

   case {2001, 2002, 2003}
      % Nova/Dova
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_CycleStart ...
         g_MC_SpyInDescToPark ...
         g_MC_DST ...
         g_MC_FST ...
         g_MC_DescProf ...
         g_MC_DescProfDeepestBin ...
         g_MC_PST ...
         g_MC_SpyAtPark ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_MinPresInDriftAtPark ...
         g_MC_MaxPresInDriftAtPark ...
         g_MC_RPP ...
         g_MC_SpyInDescToProf ...
         g_MC_MaxPresInDescToProf ...
         g_MC_DPST ...
         g_MC_SpyAtProf ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_SpyInAscProf ...
         g_MC_AscProf ...
         g_MC_AET ...
         g_MC_Surface ...
         g_MC_TST ...
         g_MC_FMT ...
         g_MC_LMT ...
         g_MC_TET ...
         ];
      
   case {3001}
      % NEMO
      o_mcOrderList = [ ...
         g_MC_Launch ...
         g_MC_DST ...
         g_MC_PST ...
         g_MC_DriftAtPark ...
         g_MC_PET ...
         g_MC_RPP ...
         g_MC_MaxPresInDescToProf ...
         g_MC_AST ...
         g_MC_AscProfDeepestBin ...
         g_MC_AscProf ...
         g_MC_MedianValueInAscProf ...
         g_MC_AET ...
         g_MC_TST ...
         g_MC_Surface ...
         ];
      
   otherwise
      fprintf('WARNING: Float #%d: No MC order list assigned to decoderId #%d\n', ...
         g_decArgo_floatNum, ...
         a_decoderId);
      
end

o_mcOrderList = unique(o_mcOrderList, 'stable');

return
