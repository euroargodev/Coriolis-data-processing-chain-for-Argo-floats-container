% ------------------------------------------------------------------------------
% Compute DOXY from C1PHASE_DOXY and C2PHASE_DOXY for a AANDERAA 4330 optode.
% The method used is the Stern-Volmer equation.
%
% SYNTAX :
%  [o_DOXY] = compute_DOXY_1121_to_28_1322_1323( ...
%    a_C1PHASE_DOXY, a_C2PHASE_DOXY, a_TEMP_DOXY, ...
%    a_C1PHASE_DOXY_fillValue, a_C2PHASE_DOXY_fillValue, a_TEMP_DOXY_fillValue, ...
%    a_PRES, a_TEMP, a_PSAL, ...
%    a_PRES_fillValue, a_TEMP_fillValue, a_PSAL_fillValue, ...
%    a_DOXY_fillValue)
%
% INPUT PARAMETERS :
%   a_C1PHASE_DOXY           : input a_C1PHASE_DOXY data
%   a_C2PHASE_DOXY           : input a_C2PHASE_DOXY data
%   a_TEMP_DOXY              : input TEMP_DOXY data
%   a_C1PHASE_DOXY_fillValue : a_C1PHASE_DOXY_fillValue fill value
%   a_C2PHASE_DOXY_fillValue : a_C2PHASE_DOXY_fillValue fill value
%   a_TEMP_DOXY_fillValue    : TEMP_DOXY fill value
%   a_PRES                   : input PRES data
%   a_TEMP                   : input TEMP data
%   a_PSAL                   : input PSAL data
%   a_PRES_fillValue         : PRES fill value
%   a_TEMP_fillValue         : TEMP fill value
%   a_PSAL_fillValue         : PSAL fill value
%   a_DOXY_fillValue         : DOXY fill value
%
% OUTPUT PARAMETERS :
%   o_DOXY : output DOXY data
%
% EXAMPLES :
%
% SEE ALSO :
% AUTHORS  : Jean-Philippe Rannou (Altran)(jean-philippe.rannou@altran.com)
% ------------------------------------------------------------------------------
% RELEASES :
%   07/10/2018 - RNU - creation
% ------------------------------------------------------------------------------
function [o_DOXY] = compute_DOXY_1121_to_28_1322_1323( ...
   a_C1PHASE_DOXY, a_C2PHASE_DOXY, a_TEMP_DOXY, ...
   a_C1PHASE_DOXY_fillValue, a_C2PHASE_DOXY_fillValue, a_TEMP_DOXY_fillValue, ...
   a_PRES, a_TEMP, a_PSAL, ...
   a_PRES_fillValue, a_TEMP_fillValue, a_PSAL_fillValue, ...
   a_DOXY_fillValue)

% output parameters initialization
o_DOXY = ones(length(a_C1PHASE_DOXY), 1)*a_DOXY_fillValue;

% current float WMO number
global g_decArgo_floatNum;

% current cycle number
global g_decArgo_cycleNum;

% arrays to store calibration information
global g_decArgo_calibInfo;

% retrieve global coefficient default values
global g_decArgo_doxy_202_205_304_d0;
global g_decArgo_doxy_202_205_304_d1;
global g_decArgo_doxy_202_205_304_d2;
global g_decArgo_doxy_202_205_304_d3;
global g_decArgo_doxy_202_205_304_sPreset;
global g_decArgo_doxy_202_205_304_b0;
global g_decArgo_doxy_202_205_304_b1;
global g_decArgo_doxy_202_205_304_b2;
global g_decArgo_doxy_202_205_304_b3;
global g_decArgo_doxy_202_205_304_c0;
global g_decArgo_doxy_202_205_304_pCoef1;
global g_decArgo_doxy_202_205_304_pCoef2;
global g_decArgo_doxy_202_205_304_pCoef3;


if (isempty(a_C1PHASE_DOXY) || isempty(a_C2PHASE_DOXY) || isempty(a_TEMP_DOXY))
   return
end

% get calibration information
if (isempty(g_decArgo_calibInfo))
   fprintf('WARNING: Float #%d Cycle #%d: DOXY calibration coefficients are missing\n', ...
      g_decArgo_floatNum, ...
      g_decArgo_cycleNum);
   return
elseif ((isfield(g_decArgo_calibInfo, 'OPTODE')) && (isfield(g_decArgo_calibInfo.OPTODE, 'TabDoxyCoef')))
   tabDoxyCoef = g_decArgo_calibInfo.OPTODE.TabDoxyCoef;
   % the size of the tabDoxyCoef should be: size(tabDoxyCoef) = 2 7
   if (~isempty(find((size(tabDoxyCoef) == [2 7]) ~= 1, 1)))
      fprintf('ERROR: Float #%d Cycle #%d: DOXY calibration coefficients are inconsistent\n', ...
         g_decArgo_floatNum, ...
         g_decArgo_cycleNum);
      return
   end
else
   fprintf('ERROR: Float #%d Cycle #%d: inconsistent DOXY calibration coefficients\n', ...
      g_decArgo_floatNum, ...
      g_decArgo_cycleNum);
   return
end

idDef = find( ...
   (a_C1PHASE_DOXY == a_C1PHASE_DOXY_fillValue) | ...
   (a_C2PHASE_DOXY == a_C2PHASE_DOXY_fillValue) | ...
   (a_TEMP_DOXY == a_TEMP_DOXY_fillValue) | ...
   (a_PRES == a_PRES_fillValue) | ...
   (a_TEMP == a_TEMP_fillValue) | ...
   (a_PSAL == a_PSAL_fillValue));
idNoDef = setdiff(1:length(a_C1PHASE_DOXY), idDef);

if (~isempty(idNoDef))
   
   c1PaseDoxyValues = a_C1PHASE_DOXY(idNoDef);
   c2PaseDoxyValues = a_C2PHASE_DOXY(idNoDef);
   tempDoxyValues = a_TEMP_DOXY(idNoDef);
   presValues = a_PRES(idNoDef);
   tempValues = a_TEMP(idNoDef);
   psalValues = a_PSAL(idNoDef);
   
   tPhaseDoxyValues = c1PaseDoxyValues - c2PaseDoxyValues;

   % compute MOLAR_DOXY from TPHASE_DOXY using the Stern-Volmer equation
   molarDoxyValues = calcoxy_aanderaa4330_sternvolmer( ...
      tPhaseDoxyValues, presValues, tempDoxyValues, tabDoxyCoef, ...
      g_decArgo_doxy_202_205_304_pCoef1);
   
   % salinity effect correction
   sRef = 0; % not considered since a PHASE_DOXY is transmitted
   oxygenSalComp = calcoxy_salcomp(molarDoxyValues, tempValues, psalValues, sRef, ...
      g_decArgo_doxy_202_205_304_d0, ...
      g_decArgo_doxy_202_205_304_d1, ...
      g_decArgo_doxy_202_205_304_d2, ...
      g_decArgo_doxy_202_205_304_d3, ...
      g_decArgo_doxy_202_205_304_sPreset, ...
      g_decArgo_doxy_202_205_304_b0, ...
      g_decArgo_doxy_202_205_304_b1, ...
      g_decArgo_doxy_202_205_304_b2, ...
      g_decArgo_doxy_202_205_304_b3, ...
      g_decArgo_doxy_202_205_304_c0 ...
      );
   
   % pressure effect correction
   oxygenPresComp = calcoxy_prescomp(oxygenSalComp, presValues, tempValues, ...
      g_decArgo_doxy_202_205_304_pCoef2, ...
      g_decArgo_doxy_202_205_304_pCoef3 ...
      );
   
   % units convertion (micromol/L to micromol/kg)
   [measLon, measLat] = get_meas_location(g_decArgo_cycleNum, -1, '');
   rho = potential_density_gsw(presValues, tempValues, psalValues, 0, measLon, measLat);
   rho = rho/1000;

   oxyValues = oxygenPresComp ./ rho;
   idNoNan = find(~isnan(oxyValues));
   
   o_DOXY(idNoDef(idNoNan)) = oxyValues(idNoNan);
end

return
