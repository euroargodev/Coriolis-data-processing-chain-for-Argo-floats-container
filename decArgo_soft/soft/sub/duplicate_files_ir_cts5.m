% ------------------------------------------------------------------------------
% Duplicate a list of files from a directory to another one.
%
% SYNTAX :
%  [o_nbFiles] = duplicate_files_ir_cts5(a_listFileNames, a_inputDir, a_outputDir, a_floatNum)
%
% INPUT PARAMETERS :
%   a_listFileNames : names of the files to duplicate
%   a_inputDir      : input directory
%   a_outputDir     : output directory
%   a_floatNum      : concerned float WMO number
%
% OUTPUT PARAMETERS :
%   o_nbFiles : number of files duplicated
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   02/20/2017 - RNU - creation
% ------------------------------------------------------------------------------
function [o_nbFiles] = duplicate_files_ir_cts5(a_listFileNames, a_inputDir, a_outputDir, a_floatNum)

% output parameters initialization
o_nbFiles = 0;

% default values
global g_decArgo_janFirst1950InMatlab;

% SBD sub-directories
global g_decArgo_updatedDirectory;
global g_decArgo_unusedDirectory;

% lists of CTS5 files
global g_decArgo_provorCts5UseaFileTypeListRsync;


% type of files to copy
fileTypeList = g_decArgo_provorCts5UseaFileTypeListRsync; % also includes g_decArgo_provorCts5OseanFileTypeListRsync elements

% copy the files of the list
for idFile = 1:length(a_listFileNames)
   
   % control file type
   [~, fileName, fileExtension] = fileparts(a_listFileNames{idFile});
      
   ok = 0;
   for idType = 1:size(fileTypeList, 1)
      if (~isempty(strfind(fileName, fileTypeList{idType, 1})) && ...
            strcmp(fileExtension, fileTypeList{idType, 2}))
         ok = 1;
         break
      end
   end
   
   % copy file
   if (ok)
      
      fileName = a_listFileNames{idFile};
      fileNameIn = [a_inputDir '/' fileName];
      fileInfo = dir(fileNameIn);
      if (~isempty(fileInfo))
         fileNameOut = [ ...
            fileName(1:end-4) '_' ...
            datestr(datenum(fileInfo.date, 'dd-mmmm-yyyy HH:MM:SS'), 'yyyymmddHHMMSS') ...
            fileName(end-3:end)];

         filePathNameOut = [a_outputDir '/' fileNameOut];
         if (exist(filePathNameOut, 'file') == 2)
            % file exists
            %          fprintf('%s - unchanged\n', fileNameOut);
         else
            fileExist = dir([a_outputDir '/' fileName(1:end-4) '_*' fileName(end-3:end)]);
            idDel = [];
            for idF = 1:length(fileExist)
               if (length(fileExist(idF).name) ~= length(fileNameOut))
                  idDel = [idDel idF];
               end
            end
            fileExist(idDel) = [];
            if (~isempty(fileExist))
               % update existing file
               move_file([a_outputDir '/' fileExist.name], g_decArgo_updatedDirectory);
               copy_file(fileNameIn, filePathNameOut);
               o_nbFiles = o_nbFiles + 1;
               %             fprintf('%s - copy (update of %s)\n', fileNameOut,fileExist.name);
            else
               % copy new file
               copy_file(fileNameIn, filePathNameOut);
               o_nbFiles = o_nbFiles + 1;
               %             fprintf('%s - copy\n', fileNameOut);
            end
         end
      else
         fprintf('ERROR: File is expected from rsync list but not in the data: %s\n', ...
            fileNameIn);
      end
   end
end

% clean files to be processed
switch(a_floatNum)
   case 4901801
      % files 019b_* should be kept
      delFile = dir([a_outputDir '/019b_*']);
      for idF = 1:length(delFile)
         move_file([a_outputDir '/' delFile(idF).name], g_decArgo_unusedDirectory);
         %          fprintf('MISC: %s - not used\n', delFile(idF).name);
      end
      
   case 4901802
      % file 013b_system_00007#01.hex is not the first part of
      % 013b_system_00007.hex => only 013b_system_00007#02.hex should be kept
      delFile = dir([a_outputDir '/013b_system_00007#01*.hex']);
      if (~isempty(delFile))
         move_file([a_outputDir '/' delFile.name], g_decArgo_unusedDirectory);
      end
      
   case 4901805
      % files 012b_* should not be kept
      delFile = dir([a_outputDir '/012b_*']);
      for idF = 1:length(delFile)
         move_file([a_outputDir '/' delFile(idF).name], g_decArgo_unusedDirectory);
      end
      
   case 6902667
      % there are 2 deployments of the same float => use only files dated
      % after july 2016
      startDate = gregorian_2_julian_dec_argo('2016/07/01 00:00:00');
      files = dir(a_outputDir);
      for idF = 1:length(files)
         if (~files(idF).isdir)
            if (datenum(files(idF).date, 'dd-mmmm-yyyy HH:MM:SS')-g_decArgo_janFirst1950InMatlab < startDate)
               move_file([a_outputDir '/' files(idF).name], g_decArgo_unusedDirectory);
               %                fprintf('MISC: %s - not used\n', files(idF).name);
            end
         end
      end
      
   case 6902669
      % files 3a9b_* should not be kept
      delFile = dir([a_outputDir '/3a9b_*']);
      for idF = 1:length(delFile)
         move_file([a_outputDir '/' delFile(idF).name], g_decArgo_unusedDirectory);
      end
      
   case 6902829
      % file 3aa9_system_00116.hex should not be kept
      delFile = dir([a_outputDir '/3aa9_system_00116_*.hex']);
      if (~isempty(delFile))
         move_file([a_outputDir '/' delFile.name], g_decArgo_unusedDirectory);
      end
      
   case 6902968
      % file 4279_047_00_payload.xml doesn't contain configuration at
      % launch for UVP sensor => we should use file _payload_190528_073923.xml
      delFile = dir([a_outputDir '/4279_047_00_payload_*.xml']);
      if (~isempty(delFile))
         inFile = dir([a_inputDir '/_payload_190528_073923.xml']);
         if (~isempty(inFile))
            move_file([a_outputDir '/' delFile.name], g_decArgo_unusedDirectory);
            outFile = [a_outputDir '/4279_047_00_payload_' ...
               datestr(datenum(inFile.date, 'dd-mmmm-yyyy HH:MM:SS'), 'yyyymmddHHMMSS') '.xml'];
            copy_file([a_inputDir '/' inFile.name], outFile);
         end
      end

   case 6903124
      % files: 3e82_255_01_do.hex, 3e82_255_01_eco.hex, 3e82_255_01_ocr.hex,
      % 3e82_255_01_ramses.hex should not be kept
      delFile = dir([a_outputDir '/3e82_255_01_*.hex']);
      for idF = 1:length(delFile)
         move_file([a_outputDir '/' delFile(idF).name], g_decArgo_unusedDirectory);
      end

      % removed when a resue mode has been implemented for SYSTEM files
      %    case 6903094
      %       % files 3ab0_system_00102#02.hex, 3ab0_system_00106#02.hex and 3ab0_system_00110#02.hex should not be kept
      %       delFile = dir([a_outputDir '/3ab0_system_00102#02_*.hex']);
      %       if (~isempty(delFile))
      %          move_file([a_outputDir '/' delFile.name], g_decArgo_unusedDirectory);
      %       end
      %       delFile = dir([a_outputDir '/3ab0_system_00106#02_*.hex']);
      %       if (~isempty(delFile))
      %          move_file([a_outputDir '/' delFile.name], g_decArgo_unusedDirectory);
      %       end
      %       delFile = dir([a_outputDir '/3ab0_system_00110#02_*.hex']);
      %       if (~isempty(delFile))
      %          move_file([a_outputDir '/' delFile.name], g_decArgo_unusedDirectory);
      %       end

   case 6904226
      % two prefix are resent in transmitted files '4e88' and 'ffff'
      renameFile = dir([a_outputDir '/ffff_*.*']);
      for idF = 1:length(renameFile)
         fileNameIn = renameFile(idF).name;
         fileNameOut = regexprep(fileNameIn, 'ffff', '4e88');
         move_file([a_outputDir '/' fileNameIn], [a_outputDir '/' fileNameOut]);
      end

   case 6904139
      % file: 520d_049_autotest_00001.txt not be kept
      delFile = dir([a_outputDir '/520d_049_autotest_00001_*.txt']);
      for idF = 1:length(delFile)
         move_file([a_outputDir '/' delFile(idF).name], g_decArgo_unusedDirectory);
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case {5906972, 6903093}
      % CTS5 floats with Iridium location email
      mailFiles = dir([a_inputDir '/co_*_*_*_*_*.txt']);
      for idFile = 1:length(mailFiles)
         mailFileName = mailFiles(idFile).name;
         mailFilePathName = [a_inputDir '/' mailFileName];

         mailFilePathNameOut = [a_outputDir '/' mailFileName];
         if (exist(mailFilePathNameOut, 'file') == 2)
            % when the file already exists, check (with its date) if it needs to be
            % updated
            mailFileOut = dir(mailFilePathNameOut);
            if (~strcmp(mailFiles(idFile).date, mailFileOut.date))
               copy_file(mailFilePathName, a_outputDir);
               %                fprintf('%s => copy\n', mailFileName);
               %             else
               %                fprintf('%s => unchanged\n', mailFileName);
            end
         else
            % copy the file if it doesn't exist
            copy_file(mailFilePathName, a_outputDir);
            %             fprintf('%s => copy\n', mailFileName);
         end
      end

   case 3902471
      % files: 5609_042_01_apmt#01.ini and 5609_042_02_apmt#01.ini should not
      % be kept
      delFile = dir([a_outputDir '/5609_042_01_apmt#*.ini']);
      for idF = 1:length(delFile)
         move_file([a_outputDir '/' delFile(idF).name], g_decArgo_unusedDirectory);
      end
end

return
