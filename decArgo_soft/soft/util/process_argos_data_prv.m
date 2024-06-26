
% ------------------------------------------------------------------------------
% Process Argos data to create Argos cycle files to be used by the decoder.
% This tool applies the following tools to the input data:
% - STEP1: split_argos_cycles
% - STEP2: delete_double_argos_split
% - STEP3: create_argos_cycle_files
% - STEP4: co_cls_correct_argos_raw_file
% - STEP5 (FINAL): move_and_rename_prv_argos_files
%
% SYNTAX :
%   process_argos_data_prv
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   05/28/2015 - RNU - creation
%   02/23/2016 - RNU - STEP4 added
% ------------------------------------------------------------------------------
function process_argos_data_prv(varargin)

% directory of input Argos files (all the files in only one directory)
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_DATA\IN\tmp_process_prv\IN\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_DATA\IN\test_20160225\argos\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\Desktop\reprocess_argos_error_cls_header\DATA\IN\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\tmp\ori\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\TEMP3\ori\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\SOS_VB_20170627\IN\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\Desktop\TMP\IN\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\TEMPO\IN\';
DIR_INPUT_ARGOS_FILES = 'C:\Users\jprannou\_DATA\TMP\IN\';

% output directory (at the end of the process, it will contain one directory for
% each step of the process and a 'FINAL' directory for the final step)
DIR_OUTPUT = 'C:\Users\jprannou\_DATA\IN\tmp_process_prv\OUT\';
DIR_OUTPUT = 'C:\Users\jprannou\_DATA\IN\test_20160225\argos_out\';
DIR_OUTPUT = 'C:\Users\jprannou\Desktop\reprocess_argos_error_cls_header\DATA\OUT\';
DIR_OUTPUT = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\TEMP3\ori_out\';
DIR_OUTPUT = 'C:\Users\jprannou\Desktop\TMP\OUT\';
DIR_OUTPUT = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\TEMPO\OUT\';
DIR_OUTPUT = 'C:\Users\jprannou\_DATA\TMP\OUT\';

% directory to store the log files
DIR_LOG_FILE = 'C:\Users\jprannou\_RNU\DecArgo_soft\work\log\';

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

% default values initialization
init_default_values;


% configuration parameters
configVar = [];
configVar{end+1} = 'FLOAT_LIST_FILE_NAME';

% get configuration parameters
g_decArgo_realtimeFlag = 0;
g_decArgo_delayedModeFlag = 0;
[configVal, unusedVarargin, inputError] = get_config_dec_argo(configVar, []);
floatListFileName = configVal{1};

if (nargin == 0)
   % floats to process come from floatListFileName
   if ~(exist(floatListFileName, 'file') == 2)
      fprintf('File not found: %s\n', floatListFileName);
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

logFile = [DIR_LOG_FILE '/' 'process_argos_data_prv' name '_' datestr(now, 'yyyymmddTHHMMSS') '.log'];
diary(logFile);
tic;

% create output directory
if (exist(DIR_OUTPUT, 'dir') == 7)
   rmdir(DIR_OUTPUT, 's');
   fprintf('INFO: Removing directory: %s\n', DIR_OUTPUT);
end
mkdir(DIR_OUTPUT);
fprintf('INFO: Creating directory: %s\n', DIR_OUTPUT);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % STEP 1: split the data by satellite passes
fprintf('STEP 1: split the data by satellite passes\n');
dirOutStep1 = [DIR_OUTPUT '/STEP1/'];
[ok] = split_argos_cycles_bis(floatList, DIR_INPUT_ARGOS_FILES, dirOutStep1);
if (ok == 0)
   fprintf('ERROR: In step1 - exit\n');
   return
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % STEP 2: delete identical satellite passes
fprintf('\nSTEP 2: delete identical satellite passes\n');
dirOutStep2 = [DIR_OUTPUT '/STEP2/'];
% duplicate the input directory in the output one
copy_file(dirOutStep1, dirOutStep2);
[ok] = delete_double_argos_split_bis(dirOutStep2);
if (ok == 0)
   fprintf('ERROR: In step2 - exit\n');
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: create cycle files
fprintf('\nSTEP 3: create cycle files\n');
dirOutStep3 = [DIR_OUTPUT '/STEP3/'];
[ok] = create_argos_cycle_files_bis(floatList, dirOutStep2, dirOutStep3);
if (ok == 0)
   fprintf('ERROR: In step3 - exit\n');
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 4: correct CLS headers (number of lines in the satellite pass)
fprintf('\nSTEP 4: correct CLS headers\n');
dirOutStep4 = [DIR_OUTPUT '/STEP4/'];
[ok] = co_cls_correct_argos_raw_file_bis(dirOutStep3, dirOutStep4);
if (ok == 0)
   fprintf('ERROR: In step4 - exit\n');
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 5: identify cycle files
fprintf('\nSTEP 5: identify cycle files\n');
dirOutStep5 = [DIR_OUTPUT '/FINAL/'];
mkdir(dirOutStep5);
% create temporary directory
mkdir([dirOutStep5 '/IN/']);
% duplicate the input directory in the output one
copy_file(dirOutStep4, [dirOutStep5 '/IN/']);
[ok] = move_and_rename_prv_argos_files_bis(floatList, [dirOutStep5 '/IN/'], dirOutStep5);
if (ok == 0)
   fprintf('ERROR: In step5 - exit\n');
   return
end
rmdir([dirOutStep5 '/IN/'], 's');

ellapsedTime = toc;
fprintf('done (Elapsed time is %.1f seconds)\n', ellapsedTime);

diary off;

return

% ------------------------------------------------------------------------------
% Split Argos cycle files (one file for each satellite pass).
%
% SYNTAX :
%   split_argos_cycles or split_argos_cycles(6900189, 7900118)
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
%   03/18/2014 - RNU - creation
% ------------------------------------------------------------------------------
function [o_ok] = split_argos_cycles_bis(varargin)

o_ok = 1;

if (nargin ~= 3)
   o_ok = 0;
   return
end

% floats to process
floatList = varargin{1};

% input and output directories
DIR_INPUT_ARGOS_FILES = varargin{2};
DIR_OUTPUT_ARGOS_FILES = varargin{3};

% number of cycle files to process per run
NB_FILES_PER_RUN = 10000;

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

% default values initialization
init_default_values;


% configuration parameters
configVar = [];
configVar{end+1} = 'FLOAT_INFORMATION_FILE_NAME';

% get configuration parameters
g_decArgo_realtimeFlag = 0;
g_decArgo_delayedModeFlag = 0;
[configVal, unusedVarargin, inputError] = get_config_dec_argo(configVar, []);
floatInformationFileName = configVal{1};

% create the output directory
if ~(exist(DIR_OUTPUT_ARGOS_FILES, 'dir') == 7)
   mkdir(DIR_OUTPUT_ARGOS_FILES);
end

% get floats information
[listWmoNum, listDecId, listArgosId, listFrameLen, ...
   listCycleTime, listDriftSamplingPeriod, listDelay, ...
   listLaunchDate, listLaunchLon, listLaunchLat, ...
   listRefDay, listEndDate, listDmFlag] = get_floats_info(floatInformationFileName);

% create the list of Argos Ids
nbFloats = length(floatList);
argosIdList = [];
for idFloat = 1:nbFloats
   
   floatNum = floatList(idFloat);
   
   % find current float Argos Id
   idF = find(listWmoNum == floatNum, 1);
   if (isempty(idF))
      fprintf('ERROR: No information on float #%d\n', floatNum);
      fprintf('(nothing done)\n');
      continue
   end
   floatArgosId = str2num(listArgosId{idF});
   argosIdList = [argosIdList; floatArgosId];
end
argosIdList = unique(argosIdList);

% process the files of the input directory
files = dir(DIR_INPUT_ARGOS_FILES);
nbFilesTot = length(files);
stop = 0;
idFile = 1;
filePathNames = [];
nbFiles = 0;
while (~stop)
   
   fileName = files(idFile).name;
   filePathName = [DIR_INPUT_ARGOS_FILES '/' fileName];
   
   fprintf('%03d/%03d %s\n', idFile, nbFilesTot, fileName);
   
   if (exist(filePathName, 'file') == 2)
      
      filePathNames{end+1} = filePathName;
      nbFiles = nbFiles + 1;
      if (nbFiles == NB_FILES_PER_RUN)
         
         fprintf('\nProcessing one set of %d files\n', nbFiles);
         
         tic;
         tmpName = ['./tmp_' datestr(now, 'yyyymmddTHHMMSS') '.mat'];
         save(tmpName, 'filePathNames');
         %          split_argos_cycles_one_set( ...
         %             tmpName, ...
         %             DIR_OUTPUT_ARGOS_FILES);
         cmd = ['matlab -nodesktop -nosplash -r "split_argos_cycles_one_set(''' tmpName ''', ''' DIR_OUTPUT_ARGOS_FILES ''');exit"'];
         system(cmd);
         ellapsedTime = toc;
         delete(tmpName);
         fprintf('done (Elapsed time is %.1f seconds)\n', ellapsedTime);
         
         clear filePathNames;
         filePathNames = [];
         nbFiles = 0;
         
      end
      
   end
   
   idFile = idFile + 1;
   if (idFile > nbFilesTot)
      if (nbFiles > 0)
         
         fprintf('\nProcessing one set of %d files\n', nbFiles);
         
         tic;
         tmpName = ['./tmp_' datestr(now, 'yyyymmddTHHMMSS') '.mat'];
         save(tmpName, 'filePathNames');
         %          split_argos_cycles_one_set( ...
         %             tmpName, ...
         %             DIR_OUTPUT_ARGOS_FILES);
         cmd = ['matlab -nodesktop -nosplash -r "split_argos_cycles_one_set(''' tmpName ''', ''' DIR_OUTPUT_ARGOS_FILES ''');exit"'];
         system(cmd);
         ellapsedTime = toc;
         delete(tmpName);
         fprintf('done (Elapsed time is %.1f seconds)\n', ellapsedTime);
         
         clear filePathNames;
         filePathNames = [];
         nbFiles = 0;
         
      end
      
      stop = 1;
   end
end

return

% ------------------------------------------------------------------------------
% Find and delete identical split files (one file for each satellite pass)
% of a given directory.
%
% SYNTAX :
%   delete_double_argos_split
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   03/18/2014 - RNU - creation
% ------------------------------------------------------------------------------
function [o_ok] = delete_double_argos_split_bis(varargin)

o_ok = 1;

if (nargin ~= 1)
   o_ok = 0;
   return
end

% input and output directory
DIR_INPUT_OUTPUT_ARGOS_FILES = varargin{1};


% process the directories of the input directory
dirs = dir(DIR_INPUT_OUTPUT_ARGOS_FILES);
nbDirs = length(dirs);
for idDir = 1:nbDirs
   
   dirName = dirs(idDir).name;
   dirPathName = [DIR_INPUT_OUTPUT_ARGOS_FILES '/' dirName];
   
   if (isdir(dirPathName))
      if ~(strcmp(dirName, '.') || strcmp(dirName, '..'))
         
         fprintf('%03d/%03d Processing directory %s\n', idDir, nbDirs, dirName);
         
         % look for possible duplicated files
         fileList = [];
         files = dir(dirPathName);
         nbFiles = length(files);
         for idFile = 1:nbFiles
            
            fileName = files(idFile).name;
            if ~(strcmp(fileName, '.') || strcmp(fileName, '..'))
               fileList{end+1} = fileName(1:end-7);
            end
         end
         fileList = unique(fileList);
         
         % process possible duplicated files
         nbFiles = length(fileList);
         for idFile = 1:nbFiles
            stop = 0;
            while (~stop)
               if (length(dir([dirPathName '/' fileList{idFile} '*'])) > 1)
                  
                  dFiles = dir([dirPathName '/' fileList{idFile} '*']);
                  if (length(fileList{idFile}) == 7)
                     idDel = [];
                     nbDFiles = length(dFiles);
                     for id = 1:nbDFiles
                        if (~isempty(strfind(dFiles(id).name, '-')))
                           idDel = [idDel id];
                        end
                     end
                     dFiles(idDel) = [];
                  end
                  
                  deleted = 0;
                  nbDFiles = length(dFiles);
                  for id1 = 1:nbDFiles
                     for id2 = id1+1:nbDFiles
                        
                        % compare the 2 file contents
                        
                        fileName1 = [dirPathName '/' dFiles(id1).name];
                        fid1 = fopen(fileName1, 'r');
                        if (fid1 == -1)
                           fprintf('ERROR: Unable to open file: %s\n', fileName1);
                           return
                        end
                        file1Contents = textscan(fid1, '%s');
                        fclose(fid1);
                        
                        fileName2 = [dirPathName '/' dFiles(id2).name];
                        fid2 = fopen(fileName2, 'r');
                        if (fid2 == -1)
                           fprintf('ERROR: Unable to open file: %s\n', fileName2);
                           return
                        end
                        file2Contents = textscan(fid2, '%s');
                        fclose(fid2);
                        
                        compRes = 1;
                        file1Contents = file1Contents{:};
                        file2Contents = file2Contents{:};
                        for idL = 1:min([length(file1Contents) length(file2Contents)])
                           if ((length(file1Contents) >= idL) && (length(file2Contents) >= idL))
                              if (strcmp(file1Contents{idL}, file2Contents{idL}) == 0)
                                 compRes = 2;
                                 break
                              end
                           elseif (length(file1Contents) >= idL)
                              compRes = 3;
                              break
                           elseif (length(file2Contents) >= idL)
                              compRes = 4;
                              break
                           end
                        end
                        
                        if (compRes == 1)
                           
                           % files are identical
                           fprintf('INFO: Files %s and %s are identical - %s deleted\n', dFiles(id1).name, dFiles(id2).name, dFiles(id2).name);
                           delete(fileName2);
                           deleted = 1;
                           break
                        elseif (compRes == 3)
                           
                           % new file contents is included in base file
                           fprintf('INFO: File %s includes file %s contents - %s deleted\n', dFiles(id1).name, dFiles(id2).name, dFiles(id2).name);
                           delete(fileName2);
                           deleted = 1;
                           break
                        elseif (compRes == 4)
                           
                           % base file contents is included in new file
                           fprintf('INFO: File %s includes file %s contents - %s deleted\n', dFiles(id2).name, dFiles(id1).name, dFiles(id1).name);
                           delete(fileName1);
                           deleted = 1;
                           break
                        end
                     end
                     if (deleted == 1)
                        break
                     end
                  end
                  
                  if (deleted == 0)
                     stop = 1;
                  end
               else
                  stop = 1;
               end
            end
         end
      end
   end
end

return

% ------------------------------------------------------------------------------
% For a given list of floats, process the associated Argos split files (one
% file for each satellite pass) by concatenating them so that each output file
% (called Argos cycle file) contains only one cycle transmitted data (the
% non-transmission periods are always less than a given threshold
% (i.e. g_decArgo_minNonTransDurForNewCycle)).
%
% SYNTAX :
%   create_argos_cycle_files or create_argos_cycle_files(6900189, 7900118)
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
%   03/18/2014 - RNU - creation
% ------------------------------------------------------------------------------
function [o_ok] = create_argos_cycle_files_bis(varargin)

o_ok = 1;

if (nargin ~= 3)
   o_ok = 0;
   return
end

% float to process
floatList = varargin{1};

% input and output directories
DIR_INPUT_ARGOS_FILES = varargin{2};
DIR_OUTPUT_ARGOS_FILES = varargin{3};

% default values
global g_decArgo_janFirst1950InMatlab;

% miscellaneous decoder configuration parameters
global g_decArgo_minNonTransDurForNewCycle;

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;

% minimum duration of the non-transmission periods for a given file (in hour)
MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE = g_decArgo_minNonTransDurForNewCycle;


% configuration parameters
configVar = [];
configVar{end+1} = 'FLOAT_INFORMATION_FILE_NAME';

% get configuration parameters
g_decArgo_realtimeFlag = 0;
g_decArgo_delayedModeFlag = 0;
[configVal, unusedVarargin, inputError] = get_config_dec_argo(configVar, []);
floatInformationFileName = configVal{1};

% create the output directories
if ~(exist(DIR_OUTPUT_ARGOS_FILES, 'dir') == 7)
   mkdir(DIR_OUTPUT_ARGOS_FILES);
end

% get floats information
[listWmoNum, listDecId, listArgosId, listFrameLen, ...
   listCycleTime, listDriftSamplingPeriod, listDelay, ...
   listLaunchDate, listLaunchLon, listLaunchLat, ...
   listRefDay, listEndDate, listDmFlag] = get_floats_info(floatInformationFileName);

% create the list of Argos Ids (to manage reused Argos Ids)
nbFloats = length(floatList);
argosIdListAll = ones(length(floatList), 1)*-1;
for idFloat = 1:nbFloats
   
   floatNum = floatList(idFloat);
   
   % find current float Argos Id
   idF = find(listWmoNum == floatNum, 1);
   if (isempty(idF))
      fprintf('ERROR: No information on float #%d\n', floatNum);
      fprintf('(nothing done)\n');
      continue
   end
   floatArgosId = str2num(listArgosId{idF});
   argosIdListAll(idFloat) = floatArgosId;
end
argosIdListAll = sort(argosIdListAll);
argosIdList = unique(argosIdListAll);
argosIdOccList = ones(length(argosIdList), 1);
idM = find(diff(argosIdListAll) == 0);
for id = 1:length(idM)
   idOcc = length(find(argosIdListAll == argosIdListAll(idM(id))));
   idF = find(argosIdList == argosIdListAll(idM(id)));
   argosIdOccList(idF) = idOcc;
end

% process the floats
nbFloats = length(floatList);
for idFloat = 1:nbFloats
   
   floatNum = floatList(idFloat);
   if (ismember(floatNum, [6901260])) % 1 day cycle duration floats
      MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE = 10; % 10 hours
   end
   
   floatNumStr = num2str(floatNum);
   fprintf('%03d/%03d %s\n', idFloat, nbFloats, floatNumStr);
   
   % find current float Argos Id
   idF = find(listWmoNum == floatNum, 1);
   if (isempty(idF))
      fprintf('ERROR: No information on float #%d\n', floatNum);
      fprintf('(nothing done)\n');
      continue
   end
   floatArgosId = str2num(listArgosId{idF});
   
   % find the occurence of ArgosId for this float
   idFloatArgosIdOcc = find(argosIdList == floatArgosId);
   floatArgosIdOcc = argosIdOccList(idFloatArgosIdOcc);
   
   % directory of Argos files for this float
   dirInputFloat = [DIR_INPUT_ARGOS_FILES '/' sprintf('%06d', floatArgosId) '/'];
   if (~isdir(dirInputFloat))
      fprintf('WARNING: No Argos data for float #%d\n', floatNum);
      continue
   end
   
   % collect dates in the Argos files of the float
   argosFileNames = [];
   argosFileFirstMsgDate = [];
   argosFileLastMsgDate = [];
   floatArgosDate = [];
   argosFiles = dir([dirInputFloat '/' sprintf('*%d*', floatArgosId)]);
   for idFile = 1:length(argosFiles)
      
      argosFileName = argosFiles(idFile).name;
      argosFilePathName = [dirInputFloat '/' argosFileName];
      
      [val1, count1, errmsg1, nextindex1] = sscanf(argosFileName, '%d_%d-%d-%d-%d-%d-%d_%d.txt');
      
      if ((isempty(errmsg1) && (count1 == 8)))
         
         [argosLocDate, argosDataDate] = ...
            read_argos_file_fmt1_rough(argosFilePathName, floatArgosId);
         argosDate = [argosLocDate; argosDataDate];
         
         if (~isempty(argosDate))
            argosFileNames{end+1} = argosFilePathName;
            argosFileFirstMsgDate(end+1) = min(argosDate);
            argosFileLastMsgDate(end+1) = max(argosDate);
            
            floatArgosDate = [floatArgosDate; argosDate];
         else
            fprintf('WARNING: Empty file (%s) - not considered\n', argosFileName);
         end
      else
         fprintf('WARNING: Not expected file name %s - not considered\n', argosFileName);
      end
   end
   
   % process the Argos files in chronological order
   if (~isempty(argosFileNames))
      
      % compute the first date of each split file
      floatArgosDate = sort(floatArgosDate);
      
      idCut = find(diff(floatArgosDate)*24 >= MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE);
      dateCut = min(floatArgosDate);
      if (~isempty(idCut))
         dateCut = [dateCut; floatArgosDate(idCut+1)];
      end
      
      % create the output dircetory for this floats
      dirOutputFloat = [DIR_OUTPUT_ARGOS_FILES '/' sprintf('%06d', floatArgosId) '/'];
      if ~(exist(dirOutputFloat, 'dir') == 7)
         mkdir(dirOutputFloat);
      end
      
      % create the output file names
      fileNameList = [];
      for id = 1:length(dateCut)
         fileName = sprintf('%06d_%s_%d.txt', ...
            floatArgosId, ...
            datestr(dateCut(id)+g_decArgo_janFirst1950InMatlab, 'yyyy-mm-dd-HH-MM-SS'), ...
            floatNum);
         fileNameList{id} = [dirOutputFloat '/' fileName];
      end
      
      % chronologically sort the files
      [argosFileFirstMsgDate, idSort] = sort(argosFileFirstMsgDate);
      argosFileLastMsgDate = argosFileLastMsgDate(idSort);
      argosFileNames = argosFileNames(idSort);
      
      nbFiles = length(argosFileNames);
      for idFile = 1:nbFiles
         
         % open and process input file
         fIdIn = fopen(argosFileNames{idFile}, 'r');
         if (fIdIn == -1)
            fprintf('Error while opening file : %s\n', argosFileNames{idFile});
            return
         end
         
         text = [];
         dateList = [];
         lineNum = 0;
         while (1)
            line = fgetl(fIdIn);
            lineNum = lineNum + 1;
            if (line == -1)
               if (~isempty(text))
                  if (~isempty(dateList))
                     minDate = min(dateList);
                     
                     % number of the file to store the data
                     idF = find(dateCut <= minDate);
                     if (~isempty(idF))
                        fileNum = idF(end);
                     else
                        fileNum = length(dateCut);
                     end
                     
                     % store the data in the output file
                     fIdOut = fopen(fileNameList{fileNum}, 'a');
                     if (fIdOut == -1)
                        fprintf('ERROR: Unable to open file: %s\n', fileNameList{fileNum});
                        return
                     end
                     
                     for id = 1:length(text)
                        fprintf(fIdOut, '%s\n', text{id});
                     end
                     
                     fclose(fIdOut);
                     
                  else
                     fprintf('INFO: Argos data without dates - not considered\n');
                     for id = 1:length(text)
                        fprintf('%s\n', text{id});
                     end
                     fprintf('\n');
                  end
               end
               
               break
            end
            
            % empty line
            if (strcmp(deblank(line), ''))
               continue
            end
            
            % look for satellite pass header
            [val, count, errmsg, nextindex] = sscanf(line, '%d %d %d %d %c %c %d-%d-%d %d:%d:%d %f %f %f %d');
            if (isempty(errmsg) && (count >= 5) && (val(2) == floatArgosId))
               if (~isempty(text))
                  if (~isempty(dateList))
                     minDate = min(dateList);
                     
                     % number of the file to store the data
                     idF = find(dateCut <= minDate);
                     if (~isempty(idF))
                        fileNum = idF(end);
                     else
                        fileNum = length(dateCut);
                     end
                     
                     % store the data in the output file
                     fIdOut = fopen(fileNameList{fileNum}, 'a');
                     if (fIdOut == -1)
                        fprintf('ERROR: Unable to open file: %s\n', fileNameList{fileNum});
                        return
                     end
                     
                     for id = 1:length(text)
                        fprintf(fIdOut, '%s\n', text{id});
                     end
                     
                     fclose(fIdOut);
                     
                  else
                     fprintf('INFO: Argos data without dates - not considered\n');
                     for id = 1:length(text)
                        fprintf('%s\n', text{id});
                     end
                     fprintf('\n');
                  end
                  
                  text = [];
                  dateList = [];
               end
               
               if (isempty(errmsg) && (count == 16))
                  date = gregorian_2_julian_dec_argo(sprintf('%04d/%02d/%02d %02d:%02d:%02d', ...
                     val(7), val(8), val(9), val(10), val(11), val(12)));
                  dateList = [dateList; date];
               end
               
            else
               
               % look for message header
               [val, count, errmsg, nextindex] = sscanf(line, '%d-%d-%d %d:%d:%f %d %2c %2c %2c %2c');
               if (isempty(errmsg) && (count == 11))
                  
                  date = gregorian_2_julian_dec_argo(sprintf('%04d/%02d/%02d %02d:%02d:%02d', ...
                     val(1), val(2), val(3), val(4), val(5), val(6)));
                  dateList = [dateList; date];
                  
               else
                  [val, count, errmsg, nextindex] = sscanf(line, '%d-%d-%d %d:%d:%f %d %8c %x %x %x');
                  if (isempty(errmsg) && (count == 11))
                     
                     date = gregorian_2_julian_dec_argo(sprintf('%04d/%02d/%02d %02d:%02d:%02d', ...
                        val(1), val(2), val(3), val(4), val(5), val(6)));
                     dateList = [dateList; date];
                     
                  end
               end
            end
            
            text{end+1} = line;
         end
         
         fclose(fIdIn);
         
         %          % move the file to the done files directory
         %          if (floatArgosIdOcc == 1)
         %             move_file(argosFileNames{idFile}, DIR_DONE_ARGOS_FILES);
         %          end
      end
   else
      fprintf('INFO: No available Argos file for float #%d\n', ...
         floatNum);
   end
   
   argosIdOccList(idFloatArgosIdOcc) = argosIdOccList(idFloatArgosIdOcc) - 1;
end

return

% ------------------------------------------------------------------------------
% Correction of the Argos HEX data.
% The correction only concerns the number of lines of the satellite pass.
%
% SYNTAX :
%   co_cls_correct_argos_raw_file
%
% INPUT PARAMETERS :
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/04/2014 - RNU - creation
% ------------------------------------------------------------------------------
function [o_ok] = co_cls_correct_argos_raw_file_bis(varargin)

o_ok = 1;

if (nargin ~= 2)
   o_ok = 0;
   return
end

% input directory(ies) to process
tabInputDirName = [];
tabInputDirName{end+1} = varargin{1};

% directory to store corrected files
corDirName = varargin{2};
if ~(exist(corDirName, 'dir') == 7)
   mkdir(corDirName);
end

% flag to process also sub-directories
SUB_DIR_FLAG = 1;


for idName = 1:length(tabInputDirName)
   
   % directory to process
   inputDirName = char(tabInputDirName{idName});
   
   fprintf('Processing directory : %s\n', inputDirName);
   
   if (SUB_DIR_FLAG == 0)
      co_cls_correct_argos_raw_file_one_dir(inputDirName, corDirName);
   else
      dirs = dir(inputDirName);
      nbDirs = length(dirs);
      for idDir = 1:nbDirs
         
         dirName = dirs(idDir).name;
         subDirPathName = [inputDirName '/' dirName '/'];
         
         if (isdir(subDirPathName))
            if ~(strcmp(dirName, '.') || strcmp(dirName, '..'))
               
               corSubDirName = [corDirName '/' dirName];
               if ~(exist(corSubDirName, 'dir') == 7)
                  mkdir(corSubDirName);
               end
               
               fprintf('Processing sub-directory : %s\n', dirName);
               
               co_cls_correct_argos_raw_file_one_dir(subDirPathName, corSubDirName);
            end
         end
      end
   end
end

return

% ------------------------------------------------------------------------------
% Correction of the Argos HEX files of a given directory.
% The correction only concerns the number of lines of the satellite pass.
%
% SYNTAX :
%  co_cls_correct_argos_raw_file(a_inputDir, a_outputDir)
%
% INPUT PARAMETERS :
%   a_inputDir  : input directory of the files to correct
%   a_outputDir : output directory of the corrected files
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   04/04/2014 - RNU - creation
% ------------------------------------------------------------------------------
function co_cls_correct_argos_raw_file_one_dir(a_inputDir, a_outputDir)

% processing of current directory contents
files = dir(a_inputDir);
nbFiles = length(files);
fprintf('Dir: %s (%d files)\n', a_inputDir, nbFiles);
for idFic = 1:nbFiles
   fileName = files(idFic).name;
   filePathName = [a_inputDir '/' fileName];
   
   if (exist(filePathName, 'file') == 2)
      
      % process the current file
      fIdIn = fopen(filePathName, 'r');
      if (fIdIn == -1)
         fprintf('Error while opening file : %s\n', filePathName);
         return
      end
      
      % first step: looking for satellite pass header and storing the number of
      % lines of each satellite pass
      tabNbLinesToReadCor = [];
      tabNbLinesToReadOri = [];
      startLine = -1;
      lineNum = 0;
      while (1)
         line = fgetl(fIdIn);
         if (line == -1)
            if (startLine ~= -1)
               tabNbLinesToReadCor = [tabNbLinesToReadCor; lineNum-startLine+1];
            end
            break
         end
         lineNum = lineNum + 1;
         
         % looking for satellite pass header
         [val1, count1, errmsg1, nextindex1] = sscanf(line, '%d %d %d %d %c %c %d-%d-%d %d:%d:%f %f %f %f %d');
         [val2, count2, errmsg2, nextindex2] = sscanf(line, '%d %d %d %d %c');
         [val3, count3, errmsg3, nextindex3] = sscanf(line, '%d %d %d %d %c %d-%d-%d %d:%d:%f %d %x %x %x %x');
         if ((isempty(errmsg1) && (count1 == 16)) || ...
               (isempty(errmsg2) && (count2 == 5) && (val2(2) > 99)) || ...
               (isempty(errmsg3) && (count3 == 16) && (isempty(find(val3(13:end) > 255, 1)))))
            
            if (startLine ~= -1)
               tabNbLinesToReadCor = [tabNbLinesToReadCor; lineNum-startLine];
            end
            startLine = lineNum;
            tabNbLinesToReadOri = [tabNbLinesToReadOri; val1(3)];
         end
      end
      
      fclose(fIdIn);
      
      % second step: writing of output file with the updated number of lines of
      % each satellite pass
      if (~isempty(tabNbLinesToReadCor))
         
         if (isempty(find((tabNbLinesToReadCor-tabNbLinesToReadOri) ~= 0, 1)))
            % no error dected => duplicate the file
            fileIn = filePathName;
            fileOut = [a_outputDir '/' fileName];
            copy_file(fileIn, fileOut);
         else
            % error(s) detected => correct the file
            
            % input file
            fIdIn = fopen(filePathName, 'r');
            if (fIdIn == -1)
               fprintf('Error while opening file : %s\n', filePathName);
               return
            end
            
            % output file
            outputFileName = [a_outputDir '/' fileName];
            fIdOut = fopen(outputFileName, 'wt');
            if (fIdOut == -1)
               fprintf('Error while creating file : %s\n', outputFileName);
               return
            end
            
            lineNum = 0;
            for id = 1:length(tabNbLinesToReadCor)
               started = 0;
               nbLinesToCopy = tabNbLinesToReadCor(id);
               while (nbLinesToCopy > 0)
                  line = fgetl(fIdIn);
                  if (line == -1)
                     break
                  end
                  lineNum = lineNum + 1;
                  
                  if (started == 1)
                     nbLinesToCopy = nbLinesToCopy - 1;
                  end
                  
                  % looking for satellite pass header
                  [val1, count1, errmsg1, nextindex1] = sscanf(line, '%d %d %d %d %c %c %d-%d-%d %d:%d:%f %f %f %f %d');
                  [val2, count2, errmsg2, nextindex2] = sscanf(line, '%d %d %d %d %c');
                  [val3, count3, errmsg3, nextindex3] = sscanf(line, '%d %d %d %d %c %d-%d-%d %d:%d:%f %d %x %x %x %x');
                  if ((isempty(errmsg1) && (count1 == 16)) || ...
                        (isempty(errmsg2) && (count2 == 5) && (val2(2) > 99)) || ...
                        (isempty(errmsg3) && (count3 == 16) && (isempty(find(val3(13:end) > 255, 1)))))
                     
                     started = 1;
                     nbLinesToCopy = nbLinesToCopy - 1;
                     if (tabNbLinesToReadCor(id) > 1)
                        if (val1(3) ~= tabNbLinesToReadCor(id))
                           idBlank = strfind(line, ' ');
                           
                           idB1 = idBlank(1);
                           idB = idBlank(2);
                           pos = 3;
                           while ((idB == idB1+1) && (pos <= length(idBlank)))
                              idB = idBlank(pos);
                              pos = pos + 1;
                           end
                           idB2 = idB;
                           idB = idBlank(pos);
                           pos = pos + 1;
                           while ((idB == idB2+1) && (pos <= length(idBlank)))
                              idB = idBlank(pos);
                              pos = pos + 1;
                           end
                           idB3 = idB;
                           
                           line = [line(1:idB2) num2str(tabNbLinesToReadCor(id)) line(idB3:end)];
                           fprintf('File corrected %s: line %d (%d instead of %d)\n', ...
                              fileName, lineNum, tabNbLinesToReadCor(id), val1(3));
                        end
                     end
                  end
                  
                  if (tabNbLinesToReadCor(id) > 1)
                     fprintf(fIdOut, '%s\n', line);
                  end
               end
            end
            
            fclose(fIdOut);
            fclose(fIdIn);
         end
      end
   end
end

return

% ------------------------------------------------------------------------------
% For a given list of floats, process the associated Argos cycle files by:
%   1: renaming the files (according to float and cycle numbers)
%   2: moving the file to the apropriate directory.
%
% SYNTAX :
%   move_and_rename_argos_files or move_and_rename_argos_files(6900189, 7900118)
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
%   01/25/2014 - RNU - creation
% ------------------------------------------------------------------------------
function [o_ok] = move_and_rename_prv_argos_files_bis(varargin)

o_ok = 1;

if (nargin ~= 3)
   o_ok = 0;
   return
end

% float to process
floatList = varargin{1};

% input and output directories
DIR_INPUT_ARGOS_FILES = varargin{2};
DIR_OUTPUT_ARGOS_FILES = varargin{3};

% global input parameter information
global g_decArgo_processModeAll;
g_decArgo_processModeAll = 1;
global g_decArgo_inputArgosFile;
global g_decArgo_processModeRedecode;
g_decArgo_processModeRedecode = 0;

% configuration values
global g_decArgo_dirInputHexArgosFileFormat1
g_decArgo_dirInputHexArgosFileFormat1 = DIR_OUTPUT_ARGOS_FILES;

% directory of json meta-data files
global g_decArgo_dirInputJsonFloatMetaDataFile;

% default values
global g_decArgo_janFirst1950InMatlab;
global g_decArgo_dateDef;

% storage of already computed cycles
global g_util_cycleNumber;
global g_util_firstMsgDate;
global g_util_lastMsgDate;

% mode processing flags
global g_decArgo_realtimeFlag;
global g_decArgo_delayedModeFlag;


% configuration parameters
configVar = [];
configVar{end+1} = 'FLOAT_INFORMATION_FILE_NAME';
configVar{end+1} = 'DIR_INPUT_JSON_FLOAT_META_DATA_FILE';

% get configuration parameters
g_decArgo_realtimeFlag = 0;
g_decArgo_delayedModeFlag = 0;
[configVal, unusedVarargin, inputError] = get_config_dec_argo(configVar, []);
floatInformationFileName = configVal{1};
g_decArgo_dirInputJsonFloatMetaDataFile = configVal{2};

% create the output directories
if ~(exist(DIR_OUTPUT_ARGOS_FILES, 'dir') == 7)
   mkdir(DIR_OUTPUT_ARGOS_FILES);
end

% get floats information
[listWmoNum, listDecId, listArgosId, listFrameLen, ...
   listCycleTime, listDriftSamplingPeriod, listDelay, ...
   listLaunchDate, listLaunchLon, listLaunchLat, ...
   listRefDay, listEndDate, listDmFlag] = get_floats_info(floatInformationFileName);

% process the floats
nbFloats = length(floatList);
for idFloat = 1:nbFloats
   
   g_util_cycleNumber = [];
   g_util_firstMsgDate = [];
   g_util_lastMsgDate = [];
   
   floatNum = floatList(idFloat);
   g_decArgo_floatNum = floatNum;
   floatNumStr = num2str(floatNum);
   fprintf('%03d/%03d %s\n', idFloat, nbFloats, floatNumStr);
   
   % find current float Argos Id
   idF = find(listWmoNum == floatNum, 1);
   if (isempty(idF))
      fprintf('ERROR: No information on float #%d\n', floatNum);
      fprintf('(nothing done)\n');
      continue
   end
   floatArgosId = str2num(listArgosId{idF});
   floatEndDate = listEndDate(idF);
   
   % select and sort the Argos files of the float
   argosFileNames = [];
   argosFileFirstMsgDate = [];
   dirInputFloat = [DIR_INPUT_ARGOS_FILES '/' sprintf('%06d', floatArgosId) '/'];
   argosFiles = dir([dirInputFloat '/' sprintf('*%d*%d*', floatArgosId, floatNum)]);
   for idFile = 1:length(argosFiles)
      
      argosFileName = argosFiles(idFile).name;
      argosFilePathName = [dirInputFloat '/' argosFileName];
      
      if (length(argosFileName) >= 27)
         
         [val1, count1, errmsg1, nextindex1] = sscanf(argosFileName(1:27), '%d_%d-%d-%d-%d-%d-%d_');
         
         if (isempty(errmsg1) && (count1 == 7))
            
            if (floatEndDate ~= g_decArgo_dateDef)
               
               % check if the file should be considered
               fileDate = datenum(argosFileName(8:26), 'yyyy-mm-dd-HH-MM-SS') - g_decArgo_janFirst1950InMatlab;
               if (fileDate > floatEndDate)
                  fprintf('INFO: Date of input file (%s) is after float end decoding date (%s) - file stored without cycle number (i.e. not decoded)\n', ...
                     julian_2_gregorian_dec_argo(fileDate), ...
                     julian_2_gregorian_dec_argo(floatEndDate));
                  g_decArgo_inputArgosFile = argosFilePathName;
                  move_argos_input_file(floatArgosId, fileDate, floatNum, [], 'UUU');
                  continue
               end
            end
            
            argosFileNames{end+1} = argosFilePathName;
            argosFileFirstMsgDate(end+1) = datenum(argosFileName(8:26), 'yyyy-mm-dd-HH-MM-SS') - ...
               g_decArgo_janFirst1950InMatlab;
            
         else
            fprintf('ERROR: Not expected file name: %s - file not considered\n', argosFileName);
         end
      else
         fprintf('ERROR: Not expected file name: %s - file not considered\n', argosFileName);
      end
   end
   
   % chronologically sort the files
   [argosFileFirstMsgDate, idSort] = sort(argosFileFirstMsgDate);
   argosFileNames = argosFileNames(idSort);
   
   % process the Argos files of the float
   nbFiles = length(argosFileNames);
   for idFile = 1:nbFiles
      % process one Argos file
      g_decArgo_inputArgosFile = argosFileNames{idFile};
      move_and_rename_file(argosFileNames{idFile}, floatNum, floatArgosId, ...
         floatInformationFileName);
   end
end

return

% ------------------------------------------------------------------------------
% Process one Argos cycle file by:
%   1: renaming it (according to float and cycle numbers)
%   2: moving it to the apropriate directory.
%
% SYNTAX :
%  move_and_rename_file(a_argosFileName, a_floatNum, a_argosId, ...
%    a_floatInformationFileName)
%
% INPUT PARAMETERS :
%   a_argosFileName : Argos cycle file name
%   a_floatNum : float WMO number
%   a_argosId : float Argos Id
%   a_floatInformationFileName : name of the float information file
%
% OUTPUT PARAMETERS :
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   01/25/2014 - RNU - creation
% ------------------------------------------------------------------------------
function move_and_rename_file(a_argosFileName, a_floatNum, a_argosId, ...
   a_floatInformationFileName)

% storage of already computed cycles
global g_util_cycleNumber;
global g_util_firstMsgDate;
global g_util_lastMsgDate;

% miscellaneous decoder configuration parameters
global g_decArgo_minNonTransDurForNewCycle;
global g_decArgo_minNumMsgForNotGhost;

% global input parameter information
global g_decArgo_inputArgosFile;

% minimum number of float messages for not only ghosts in contents
NB_MSG_MIN = g_decArgo_minNumMsgForNotGhost;

% minimum duration (in hour) of a non-transmission period to create a new
% cycle
MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE = g_decArgo_minNonTransDurForNewCycle;


% get floats information
[listWmoNum, listDecId, listArgosId, listFrameLen, ...
   listCycleTime, listDriftSamplingPeriod, listDelay, ...
   listLaunchDate, listLaunchLon, listLaunchLat, ...
   listRefDay, listEndDate, listDmFlag] = get_floats_info(a_floatInformationFileName);

idFloat = find(listWmoNum == a_floatNum);

frameLen = listFrameLen(idFloat);
floatDecId = listDecId(idFloat);
floatLaunchDate = listLaunchDate(idFloat);
floatCycleTime = listCycleTime(idFloat);
floatRefDay = listRefDay(idFloat);

% read Argos file
[argosLocDate, argosLocLon, argosLocLat, argosLocAcc, argosLocSat, ...
   argosDataDate, argosDataData] = read_argos_file_fmt1({a_argosFileName}, a_argosId, frameLen);
firstArgosMsgDate = min(argosDataDate);
lastArgosMsgDate = max(argosDataDate);

% store file with only ghost messages without any cycle number
if (isempty(argosDataDate))
   
   % search dates in the file without checking its consistency
   [argosLocDate, argosDataDate] = ...
      read_argos_file_fmt1_rough(a_argosFileName, a_argosId);
   if (~isempty(argosDataDate))
      move_argos_input_file(a_argosId, min(argosDataDate), a_floatNum, [], 'EEE');
   else
      move_argos_input_file(a_argosId, min(argosLocDate), a_floatNum, [], 'EEE');
   end
   fprintf('INFO: File (%s) contains no Argos messages - file stored without cycle number (i.e. not decoded)\n', ...
      a_argosFileName);
   
   return
elseif (length(unique(argosDataDate)) < NB_MSG_MIN)
   
   move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, [], 'GGG');
   fprintf('INFO: File (%s) contains only ghost messages - file stored without cycle number (i.e. not decoded)\n', ...
      a_argosFileName);
   
   return
end

% find the cycle number

% retrieve useful float meta-data
[launchDate, delayBeforeMission, preludeDuration, firstProfileEndDate, cycleDuration, nbCyclesFirstMission] = ...
   get_meta_data_for_cycle_number_determination(a_floatNum, floatDecId, floatLaunchDate, floatCycleTime, floatRefDay);
if (isempty(launchDate))
   fprintf('ERROR: Unable to compute cycle number because of missing meta-data - file stored without cycle number (i.e. not decoded)\n');
   
   move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, [], 'MMM');
   return
end

% estimate the cycle number
cycleNumber = [];
if (lastArgosMsgDate > launchDate)
   if (length(cycleDuration) == 1)
      
      % floats with one cycle duration
      
      if (get_default_prelude_duration(floatDecId) == 0)
         
         % floats with no prelude phase
         
         % try to use already computed cycles
         idPrevCycle = find(g_util_lastMsgDate < firstArgosMsgDate);
         if (~isempty(idPrevCycle))
            idPrevCycle = idPrevCycle(end);
            nbCycles = round((firstArgosMsgDate-g_util_firstMsgDate(idPrevCycle))/cycleDuration);
            if ((nbCycles == 0) && ...
                  ((firstArgosMsgDate-g_util_lastMsgDate(idPrevCycle))*24 >= MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE))
               % we consider it is a new cycle if we have had a
               % MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE hours period without
               % transmission
               nbCycles = 1;
            end
            cycleNumber = g_util_cycleNumber(idPrevCycle) + nbCycles;
         end
         
         % use float meta-data
         if (isempty(cycleNumber))
            cycleNumber = round((firstArgosMsgDate-firstProfileEndDate)/cycleDuration);
            %          fprintf('INFO: Cycle number (%d) has been computed from meta-data only\n', cycleNumber);
         end
         
      else
         
         % floats with a prelude phase
         
         % try to use already computed cycles
         idPrevCycle = find(g_util_lastMsgDate < firstArgosMsgDate);
         if (~isempty(idPrevCycle))
            idPrevCycle = idPrevCycle(end);
            if (g_util_cycleNumber(idPrevCycle) == 0)
               cycleNumber = round((firstArgosMsgDate-firstProfileEndDate)/cycleDuration) + 1;
               if ((cycleNumber == 0) && ...
                     ((firstArgosMsgDate-g_util_lastMsgDate(idPrevCycle))*24 >= MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE))
                  % we consider it is a new cycle if we have had a
                  % MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE hours period without
                  % transmission
                  cycleNumber = 1;
               end
            else
               nbCycles = round((firstArgosMsgDate-g_util_firstMsgDate(idPrevCycle))/cycleDuration);
               if ((nbCycles == 0) && ...
                     ((firstArgosMsgDate-g_util_lastMsgDate(idPrevCycle))*24 >= MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE))
                  % we consider it is a new cycle if we have had a
                  % MIN_NON_TRANS_DURATION_FOR_NEW_CYCLE hours period without
                  % transmission
                  nbCycles = 1;
               end
               cycleNumber = g_util_cycleNumber(idPrevCycle) + nbCycles;
            end
         end
         
         % use float meta-data
         if (isempty(cycleNumber))
            if (firstArgosMsgDate < launchDate + preludeDuration/1440)
               cycleNumber = 0;
            elseif (firstArgosMsgDate < firstProfileEndDate)
               if (abs(firstArgosMsgDate-(launchDate + preludeDuration/1440)) < abs(firstArgosMsgDate-firstProfileEndDate))
                  cycleNumber = 0;
               else
                  cycleNumber = 1;
               end
            else
               cycleNumber = round((firstArgosMsgDate-firstProfileEndDate)/cycleDuration) + 1;
            end
            %          fprintf('INFO: Cycle number (%d) has been computed from meta-data only\n', cycleNumber);
         end
      end
      
   else
      
      % floats with two cycle durations
      
      % these float versions provide the cycle numbers
      decodedCycleNumber = decode_cycle_number(a_argosFileName, ...
         a_floatNum, a_argosId, frameLen, floatDecId);
      
      if (~isempty(decodedCycleNumber) && (decodedCycleNumber ~= -1))
         
         % the cycle number has been decoded from the transmitted data
         if (decodedCycleNumber ~= 0)
            cycleNumber = decodedCycleNumber;
         else
            
            % the cycle number reported by the float is #0
            % it can be the prelude or a EOL, we must use additional dates and
            % information to set the correct cycle number
            
            % multiple cycle durations only concern floats with a prelude phase
            
            % compute the duration of the cycle #1 (first deep cycle)
            firstDeepCycleDuration = firstProfileEndDate - floatRefDay - ...
               delayBeforeMission/1440 - preludeDuration/1440;
            
            % compute the duration of the transition cycle
            surfTime = firstProfileEndDate - fix(firstProfileEndDate);
            transitionCycleStartDate = surfTime + (nbCyclesFirstMission-1)*cycleDuration(1);
            transitionCycleEndDate = fix(transitionCycleStartDate + cycleDuration(2)) + surfTime;
            transitionCycleDuration = transitionCycleEndDate - transitionCycleStartDate;
            
            % try to use already computed cycles
            idPrevCycle = find(g_util_lastMsgDate < firstArgosMsgDate);
            if (~isempty(idPrevCycle))
               idPrevCycle = idPrevCycle(end);
               
               if (g_util_cycleNumber(idPrevCycle) == 0)
                  
                  refDate = g_util_lastMsgDate(idPrevCycle);
                  dates = [ ...
                     refDate+firstDeepCycleDuration ...
                     repmat(cycleDuration(1), 1, nbCyclesFirstMission-1) ...
                     transitionCycleDuration ...
                     repmat(cycleDuration(2), 1, 999)];
                  for id = 2:length(dates)
                     dates(id) = dates(id) + dates(id-1);
                  end
                  cycleNumbers = 1:length(dates);
                  
                  [~, idMin] = min(abs(dates-firstArgosMsgDate));
                  cycleNumber = cycleNumbers(idMin);
                  
               elseif ((g_util_cycleNumber(idPrevCycle) > 0) && (g_util_cycleNumber(idPrevCycle) < nbCyclesFirstMission))
                  
                  refDate = g_util_firstMsgDate(idPrevCycle);
                  dates = [ ...
                     refDate ...
                     repmat(cycleDuration(1), 1, nbCyclesFirstMission-g_util_cycleNumber(idPrevCycle)) ...
                     transitionCycleDuration ...
                     repmat(cycleDuration(2), 1, 999)];
                  for id = 2:length(dates)
                     dates(id) = dates(id) + dates(id-1);
                  end
                  cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
                  
                  [~, idMin] = min(abs(dates-firstArgosMsgDate));
                  cycleNumber = cycleNumbers(idMin);
                  
               elseif (g_util_cycleNumber(idPrevCycle) == nbCyclesFirstMission)
                  
                  refDate = g_util_firstMsgDate(idPrevCycle);
                  dates = [ ...
                     refDate ...
                     transitionCycleDuration ...
                     repmat(cycleDuration(2), 1, 999)];
                  for id = 2:length(dates)
                     dates(id) = dates(id) + dates(id-1);
                  end
                  cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
                  
                  [~, idMin] = min(abs(dates-firstArgosMsgDate));
                  cycleNumber = cycleNumbers(idMin);
                  
               else
                  
                  refDate = g_util_firstMsgDate(idPrevCycle);
                  dates = [ ...
                     refDate ...
                     repmat(cycleDuration(2), 1, 999)];
                  for id = 2:length(dates)
                     dates(id) = dates(id) + dates(id-1);
                  end
                  cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
                  
                  [~, idMin] = min(abs(dates-firstArgosMsgDate));
                  cycleNumber = cycleNumbers(idMin);
                  
               end
               
            else
               
               % use float meta-data
               
               dates = [ ...
                  floatRefDay+delayBeforeMission/1440 ...
                  preludeDuration/1440+firstDeepCycleDuration ...
                  repmat(cycleDuration(1), 1, nbCyclesFirstMission-1) ...
                  transitionCycleDuration ...
                  repmat(cycleDuration(2), 1, 999)];
               for id = 2:length(dates)
                  dates(id) = dates(id) + dates(id-1);
               end
               cycleNumbers = 0:length(dates);
               
               [~, idMin] = min(abs(dates-firstArgosMsgDate));
               cycleNumber = cycleNumbers(idMin);
               
            end
         end
         
      elseif (decodedCycleNumber == -1)
         
         diffArgosDataDates = diff(argosDataDate)*24;
         
         % the file contains multiple cycles
         [subFileNameList] = split_argos_file(a_argosFileName, a_floatNum, a_argosId);
         if (~isempty(subFileNameList))
            
            fprintf('INFO: Argos cycle file split (%.1f hours without transmission): %s\n', ...
               max(diffArgosDataDates), a_argosFileName);
         else
            fprintf('ERROR: Unable to split Argos cycle file: %s\n', ...
               argosFileName);
         end
         
         for idFile = 1:length(subFileNameList)
            
            cycleNumberFile = [];
            
            decodedCycleNumber = decode_cycle_number(subFileNameList{idFile}, ...
               a_floatNum, a_argosId, frameLen, floatDecId);
            
            if (~isempty(decodedCycleNumber) && (decodedCycleNumber ~= -1))
               
               % the cycle number has been decoded from the transmitted data
               if (decodedCycleNumber ~= 0)
                  cycleNumberFile = decodedCycleNumber;
               else
                  
                  % the cycle number reported by the float is #0
                  % it can be the prelude or a EOL, we must use additional dates and
                  % information to set the correct cycle number
                  
                  % multiple cycle durations only concern floats with a prelude phase
                  
                  % compute the duration of the cycle #1 (first deep cycle)
                  firstDeepCycleDuration = firstProfileEndDate - floatRefDay - ...
                     delayBeforeMission/1440 - preludeDuration/1440;
                  
                  % compute the duration of the transition cycle
                  surfTime = firstProfileEndDate - fix(firstProfileEndDate);
                  transitionCycleStartDate = surfTime + (nbCyclesFirstMission-1)*cycleDuration(1);
                  transitionCycleEndDate = fix(transitionCycleStartDate + cycleDuration(2)) + surfTime;
                  transitionCycleDuration = transitionCycleEndDate - transitionCycleStartDate;
                  
                  % try to use already computed cycles
                  idPrevCycle = find(g_util_lastMsgDate < firstArgosMsgDate);
                  if (~isempty(idPrevCycle))
                     idPrevCycle = idPrevCycle(end);
                     
                     if (g_util_cycleNumber(idPrevCycle) == 0)
                        
                        refDate = g_util_lastMsgDate(idPrevCycle);
                        dates = [ ...
                           refDate+firstDeepCycleDuration ...
                           repmat(cycleDuration(1), 1, nbCyclesFirstMission-1) ...
                           transitionCycleDuration ...
                           repmat(cycleDuration(2), 1, 999)];
                        for id = 2:length(dates)
                           dates(id) = dates(id) + dates(id-1);
                        end
                        cycleNumbers = 1:length(dates);
                        
                        [~, idMin] = min(abs(dates-firstArgosMsgDate));
                        cycleNumberFile = cycleNumbers(idMin);
                        
                     elseif ((g_util_cycleNumber(idPrevCycle) > 0) && (g_util_cycleNumber(idPrevCycle) < nbCyclesFirstMission))
                        
                        refDate = g_util_firstMsgDate(idPrevCycle);
                        dates = [ ...
                           refDate ...
                           repmat(cycleDuration(1), 1, nbCyclesFirstMission-g_util_cycleNumber(idPrevCycle)) ...
                           transitionCycleDuration ...
                           repmat(cycleDuration(2), 1, 999)];
                        for id = 2:length(dates)
                           dates(id) = dates(id) + dates(id-1);
                        end
                        cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
                        
                        [~, idMin] = min(abs(dates-firstArgosMsgDate));
                        cycleNumberFile = cycleNumbers(idMin);
                        
                     elseif (g_util_cycleNumber(idPrevCycle) == nbCyclesFirstMission)
                        
                        refDate = g_util_firstMsgDate(idPrevCycle);
                        dates = [ ...
                           refDate ...
                           transitionCycleDuration ...
                           repmat(cycleDuration(2), 1, 999)];
                        for id = 2:length(dates)
                           dates(id) = dates(id) + dates(id-1);
                        end
                        cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
                        
                        [~, idMin] = min(abs(dates-firstArgosMsgDate));
                        cycleNumberFile = cycleNumbers(idMin);
                        
                     else
                        
                        refDate = g_util_firstMsgDate(idPrevCycle);
                        dates = [ ...
                           refDate ...
                           repmat(cycleDuration(2), 1, 999)];
                        for id = 2:length(dates)
                           dates(id) = dates(id) + dates(id-1);
                        end
                        cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
                        
                        [~, idMin] = min(abs(dates-firstArgosMsgDate));
                        cycleNumberFile = cycleNumbers(idMin);
                        
                     end
                     
                  else
                     
                     % use float meta-data
                     
                     dates = [ ...
                        floatRefDay+delayBeforeMission/1440 ...
                        preludeDuration/1440+firstDeepCycleDuration ...
                        repmat(cycleDuration(1), 1, nbCyclesFirstMission-1) ...
                        transitionCycleDuration ...
                        repmat(cycleDuration(2), 1, 999)];
                     for id = 2:length(dates)
                        dates(id) = dates(id) + dates(id-1);
                     end
                     cycleNumbers = 0:length(dates);
                     
                     [~, idMin] = min(abs(dates-firstArgosMsgDate));
                     cycleNumberFile = cycleNumbers(idMin);
                     
                  end
               end
               
               if (~isempty(cycleNumberFile))
                  cycleNumber = [cycleNumber cycleNumberFile];
               else
                  fprintf('ERROR: Float #%d: Cannot determine cycle number for file: %s\n', ...
                     a_floatNum, subFileNameList{idFile});
                  cycleNumber = [];
                  break
               end
            else
               fprintf('ERROR: Float #%d: Cannot determine cycle number for file: %s\n', ...
                  a_floatNum, subFileNameList{idFile});
               cycleNumber = [];
               break
            end
         end
      else
         % the cycle number cannot be decoded from the transmitted data
         % we will use the transmission times to determine cycle number
         
         % multiple cycle durations only concern floats with a prelude phase
         
         % compute the duration of the cycle #1 (first deep cycle)
         firstDeepCycleDuration = firstProfileEndDate - floatRefDay - ...
            delayBeforeMission/1440 - preludeDuration/1440;
         
         % compute the duration of the transition cycle
         surfTime = firstProfileEndDate - fix(firstProfileEndDate);
         transitionCycleStartDate = surfTime + (nbCyclesFirstMission-1)*cycleDuration(1);
         transitionCycleEndDate = fix(transitionCycleStartDate + cycleDuration(2)) + surfTime;
         transitionCycleDuration = transitionCycleEndDate - transitionCycleStartDate;
         
         % try to use already computed cycles
         idPrevCycle = find(g_util_lastMsgDate < firstArgosMsgDate);
         if (~isempty(idPrevCycle))
            idPrevCycle = idPrevCycle(end);
            
            if (g_util_cycleNumber(idPrevCycle) == 0)
               
               refDate = g_util_lastMsgDate(idPrevCycle);
               dates = [ ...
                  refDate+firstDeepCycleDuration ...
                  repmat(cycleDuration(1), 1, nbCyclesFirstMission-1) ...
                  transitionCycleDuration ...
                  repmat(cycleDuration(2), 1, 999)];
               for id = 2:length(dates)
                  dates(id) = dates(id) + dates(id-1);
               end
               cycleNumbers = 1:length(dates);
               
               [~, idMin] = min(abs(dates-firstArgosMsgDate));
               cycleNumber = cycleNumbers(idMin);
               
            elseif ((g_util_cycleNumber(idPrevCycle) > 0) && (g_util_cycleNumber(idPrevCycle) < nbCyclesFirstMission))
               
               refDate = g_util_firstMsgDate(idPrevCycle);
               dates = [ ...
                  refDate ...
                  repmat(cycleDuration(1), 1, nbCyclesFirstMission-g_util_cycleNumber(idPrevCycle)) ...
                  transitionCycleDuration ...
                  repmat(cycleDuration(2), 1, 999)];
               for id = 2:length(dates)
                  dates(id) = dates(id) + dates(id-1);
               end
               cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
               
               [~, idMin] = min(abs(dates-firstArgosMsgDate));
               cycleNumber = cycleNumbers(idMin);
               
            elseif (g_util_cycleNumber(idPrevCycle) == nbCyclesFirstMission)
               
               refDate = g_util_firstMsgDate(idPrevCycle);
               dates = [ ...
                  refDate ...
                  transitionCycleDuration ...
                  repmat(cycleDuration(2), 1, 999)];
               for id = 2:length(dates)
                  dates(id) = dates(id) + dates(id-1);
               end
               cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
               
               [~, idMin] = min(abs(dates-firstArgosMsgDate));
               cycleNumber = cycleNumbers(idMin);
               
            else
               
               refDate = g_util_firstMsgDate(idPrevCycle);
               dates = [ ...
                  refDate ...
                  repmat(cycleDuration(2), 1, 999)];
               for id = 2:length(dates)
                  dates(id) = dates(id) + dates(id-1);
               end
               cycleNumbers = g_util_cycleNumber(idPrevCycle):g_util_cycleNumber(idPrevCycle)+length(dates);
               
               [~, idMin] = min(abs(dates-firstArgosMsgDate));
               cycleNumber = cycleNumbers(idMin);
               
            end
            
         else
            
            % use float meta-data
            
            dates = [ ...
               floatRefDay+delayBeforeMission/1440 ...
               preludeDuration/1440+firstDeepCycleDuration ...
               repmat(cycleDuration(1), 1, nbCyclesFirstMission-1) ...
               transitionCycleDuration ...
               repmat(cycleDuration(2), 1, 999)];
            for id = 2:length(dates)
               dates(id) = dates(id) + dates(id-1);
            end
            cycleNumbers = 0:length(dates);
            
            [~, idMin] = min(abs(dates-firstArgosMsgDate));
            cycleNumber = cycleNumbers(idMin);
            
         end
      end
   end
else
   move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, [], 'TTT');
   
   fprintf('INFO: Last date of input file (%s) is before float launch date (%s) - file stored without cycle number (i.e. not decoded)\n', ...
      julian_2_gregorian_dec_argo(lastArgosMsgDate), ...
      julian_2_gregorian_dec_argo(launchDate));
   return
end

% create the name of the input file and move it to the approriate directory
if (~isempty(cycleNumber))
   if (length(cycleNumber) == 1)
      if (cycleNumber < 0)
         move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, [], 'MMM');
         
         fprintf('ERROR: Computed cycle number is negative (%d): check the consistency of the meta-data - file stored without cycle number (i.e. not decoded)\n', ...
            cycleNumber);
      else
         move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, cycleNumber);
         
         g_util_cycleNumber = [g_util_cycleNumber; cycleNumber];
         g_util_firstMsgDate = [g_util_firstMsgDate; firstArgosMsgDate];
         g_util_lastMsgDate = [g_util_lastMsgDate; lastArgosMsgDate];
      end
   else
      for idFile = 1:length(subFileNameList)
         
         % read Argos file
         [argosLocDate, argosLocLon, argosLocLat, argosLocAcc, argosLocSat, ...
            argosDataDate, argosDataData] = read_argos_file_fmt1({subFileNameList{idFile}}, a_argosId, frameLen);
         firstArgosMsgDate = min(argosDataDate);
         lastArgosMsgDate = max(argosDataDate);
         
         g_decArgo_inputArgosFile = subFileNameList{idFile};
         
         if (cycleNumber(idFile) < 0)
            move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, [], 'MMM');
            
            fprintf('ERROR: Computed cycle number is negative (%d): check the consistency of the meta-data - file stored without cycle number (i.e. not decoded)\n', ...
               cycleNumber(idFile));
         else
            move_argos_input_file(a_argosId, firstArgosMsgDate, a_floatNum, cycleNumber(idFile));
            
            g_util_cycleNumber = [g_util_cycleNumber; cycleNumber(idFile)];
            g_util_firstMsgDate = [g_util_firstMsgDate; firstArgosMsgDate];
            g_util_lastMsgDate = [g_util_lastMsgDate; lastArgosMsgDate];
         end
      end
   end
end

return
