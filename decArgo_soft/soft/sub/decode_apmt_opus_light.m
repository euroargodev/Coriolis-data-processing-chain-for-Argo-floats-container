% ------------------------------------------------------------------------------
% Decode OPUS-LIGHT data transmitted by a CTS5-USEA float.
%
% SYNTAX :
%  [o_opusLightData] = decode_apmt_opus_light(a_data, a_lastByteNum, a_inputFilePathName)
%
% INPUT PARAMETERS :
%   a_data              : input OPUS-LIGHT data to decode
%   a_lastByteNum       : number of the last useful byte of the data
%   a_inputFilePathName : APMT OPUS file to decode
%
% OUTPUT PARAMETERS :
%   o_opusLightData : OPUS-LIGHT decoded data
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/15/2021 - RNU - creation
% ------------------------------------------------------------------------------
function [o_opusLightData] = decode_apmt_opus_light(a_data, a_lastByteNum, a_inputFilePathName)

% output parameters initialization
o_opusLightData = [];

% codes for CTS5 phases
global g_decArgo_cts5PhaseDescent;
global g_decArgo_cts5PhasePark;
global g_decArgo_cts5PhaseDeepProfile;
global g_decArgo_cts5PhaseShortPark;
global g_decArgo_cts5PhaseAscent;
global g_decArgo_cts5PhaseSurface;

% codes for CTS5 treatment types
global g_decArgo_cts5Treat_RW;
global g_decArgo_cts5Treat_AM;
global g_decArgo_cts5Treat_DW;


% list of cycle phase headers that can be encountered
phaseList = [ ...
   {'[DESCENT]'} ...
   {'[PARK]'} ...
   {'[DEEP_PROFILE]'} ...
   {'[SHORT_PARK]'} ...
   {'[ASCENT]'} ...
   {'[SURFACE]'} ...
   ];

% list of treatment type headers that can be encountered
treatList = [ ...
   {''} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {''} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {''} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {'(RW)'} ...
   {''} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {''} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {'(DW)'} ...
   ];

% list of corresponding bit pattern (used to acces the data)
bitList = [ ...
   {[]} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {[]} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {[]} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {[16 16 8 8 8 16 8]} ...
   {[]} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {[]} ... % unused but to be consistent with g_decArgo_cts5Treat_SS (so that 'DW' is g_decArgo_cts5Treat_DW == 7)
   {[16 16 8 8 8 16 8]} ...
   ];

inputData = a_data;
lastByteNum = a_lastByteNum;
currentPhaseNum = -1;
currentTreatNum = -1;
dataStruct = [];
currentDataStruct = [];
currentByte = 2;
while (currentByte <= lastByteNum)
   
   newPhaseNum = -1;
   newTreatNum = -1;
   
   % look for a new phase header
   if (inputData(currentByte) == '[')
      for idPhase = 1:length(phaseList)
         phaseName = phaseList{idPhase};
         if (strcmp(char(inputData(currentByte:currentByte+length(phaseName)-1))', phaseName))
            newPhaseNum = idPhase;
            currentByte = currentByte + length(phaseName);
            break
         end
      end
   end
   
   % the treatment type of PARK, SHORT_PARK and SURFACE measurements is always
   % RAW (NKE personal communication)
   if (ismember(newPhaseNum, [g_decArgo_cts5PhasePark g_decArgo_cts5PhaseShortPark g_decArgo_cts5PhaseSurface]))
      newTreatNum = g_decArgo_cts5Treat_RW;
   else

      % look for a new treatment header
      if (inputData(currentByte) == '(')
         for idTreat = 1:length(treatList)
            treatName = treatList{idTreat};
            if (~isempty(treatName))
               if (strcmp(char(inputData(currentByte:currentByte+length(treatName)-1))', treatName))
                  newTreatNum = idTreat;
                  currentByte = currentByte + length(treatName);
                  break
               end
            end
         end
      end
   end
   
   % consider modification of phase or treatment
   if ((newPhaseNum ~= -1) || (newTreatNum ~= -1))
      if (~isempty(currentDataStruct))
         
         % finalize decoded data
         % compute the dates
         if (~ismember(currentPhaseNum, [g_decArgo_cts5PhasePark g_decArgo_cts5PhaseShortPark g_decArgo_cts5PhaseSurface]))
            date = currentDataStruct.data(:, 1);
            date(1) = date(1) + currentDataStruct.date;
            for id = 2:length(date)
               date(id) = date(id-1) + date(id);
            end
            currentDataStruct.data(:, 1) = epoch_2_julian_dec_argo(date);
         end
         
         % store decoded data
         dataStruct{end+1} = currentDataStruct;
         currentDataStruct = [];
      end
      
      if (newPhaseNum ~= -1)
         currentPhaseNum = newPhaseNum;
      end
      if (newTreatNum ~= -1)
         currentTreatNum = newTreatNum;
      end
      phaseName = phaseList{currentPhaseNum};
      treatName = treatList{currentTreatNum};
      %       fprintf('%s %s\n', phaseName, treatName);
      currentDataStruct.phase = phaseName;
      currentDataStruct.phaseId = currentPhaseNum;
      currentDataStruct.treat = treatName;
      currentDataStruct.treatId = currentTreatNum;
      currentDataStruct.date = [];
      currentDataStruct.data = [];
      
      % the absolute date is provided in the beginning of descent/ascent phase
      % data
      if (ismember(currentPhaseNum, [g_decArgo_cts5PhaseDescent g_decArgo_cts5PhaseDeepProfile g_decArgo_cts5PhaseAscent]))
         data = get_bits(1, 32, inputData(currentByte:currentByte+3));
         currentDataStruct.date = typecast(swapbytes(uint32(data)), 'uint32');
         currentByte = currentByte + 4;
      end
   end
   
   % read the data
   if ((currentPhaseNum ~= -1) && (currentTreatNum ~= -1))
      tabNbBits = bitList{currentTreatNum};
      % absolute date during PARK, SHORT_PARK and SURFACE phases
      if (ismember(currentPhaseNum, [g_decArgo_cts5PhasePark g_decArgo_cts5PhaseShortPark g_decArgo_cts5PhaseSurface]))
         tabNbBits(1) = 32;
      end
      nbBytes = sum(tabNbBits)/8;
      rawData = get_bits(1, tabNbBits, inputData(currentByte:currentByte+nbBytes-1));
      for id = 1:length(tabNbBits)
         if (tabNbBits(id) > 8)
            rawData(id) = decode_apmt_meas(rawData(id), tabNbBits(id), 0, a_inputFilePathName);
         end
      end
      
      if (ismember(currentTreatNum, [g_decArgo_cts5Treat_RW g_decArgo_cts5Treat_DW]))
         % raw data
         if (ismember(currentPhaseNum, [g_decArgo_cts5PhasePark g_decArgo_cts5PhaseShortPark g_decArgo_cts5PhaseSurface]))
            data(1) = epoch_2_julian_dec_argo(rawData(1));
         else
            data(1) = rawData(1);
         end
         data(2) = rawData(2)/10 - 100;
         data(3) = str2double(char(rawData(3)));
         data(4) = rawData(4)/10;
         data(5) = rawData(5)/10;
         data(6) = rawData(6)/1000 - 5;
         nbF = rawData(7);
         
         % Channels F decoding
         currentByte = currentByte + nbBytes;
         tabNbBits2 = [repmat(16, 1, nbF) 8];
         nbBytes = sum(tabNbBits2)/8;
         rawData = get_bits(1, tabNbBits2, inputData(currentByte:currentByte+nbBytes-1));
         for id = 1:length(tabNbBits2)
            if (tabNbBits2(id) > 8)
               rawData(id) = decode_apmt_meas(rawData(id), tabNbBits2(id), 0, a_inputFilePathName);
            end
         end
         dataF = rawData(1:end-1)';
         nbB = rawData(end);
         
         % Channels B decoding
         currentByte = currentByte + nbBytes;
         tabNbBits2 = repmat(16, 1, nbB);
         nbBytes = sum(tabNbBits2)/8;
         rawData = get_bits(1, tabNbBits2, inputData(currentByte:currentByte+nbBytes-1));
         for id = 1:length(tabNbBits2)
            if (tabNbBits2(id) > 8)
               rawData(id) = decode_apmt_meas(rawData(id), tabNbBits2(id), 0, a_inputFilePathName);
            end
         end
         dataB = rawData';
         
      else
         fprintf('ERROR: Treatment #%d not managed\n', currentTreatNum);
      end
      dataAll = [data(1:6) nbF nan(1, 255) nbB nan(1, 255)];
      dataAll(8:8+length(dataF)-1) = dataF;
      dataAll(264:264+length(dataB)-1) = dataB;
      currentDataStruct.data = [currentDataStruct.data; dataAll];
      currentByte = currentByte + nbBytes;
   else
      fprintf('ERROR: This should not happen\n');
      break
   end
end

if (~isempty(currentDataStruct))
   
   % finalize decoded data
   % compute the dates
   if (~ismember(currentPhaseNum, [g_decArgo_cts5PhasePark g_decArgo_cts5PhaseShortPark g_decArgo_cts5PhaseSurface]))
      date = currentDataStruct.data(:, 1);
      date(1) = date(1) + currentDataStruct.date;
      for id = 2:length(date)
         date(id) = date(id-1) + date(id);
      end
      currentDataStruct.data(:, 1) = epoch_2_julian_dec_argo(date);
   end
   
   % store decoded data
   dataStruct{end+1} = currentDataStruct;
end

o_opusLightData = dataStruct;

return
