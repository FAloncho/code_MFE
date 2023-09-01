function [FirstDet] = GenericDetection(Recording,DetectionParameters,Derivation)

% Primary function of SW detection by recording and derivation
%
%  INPUTS:	
%   Recording	                struct with recording's information  
%   DetectionParameters         struct with detection parameters defined in the main
%   Derivation                  number of the currently analyzed derivation           
%
%  OUTPUTS:	
%   FirstDet                   struct with informations of size, shape and position?? of detected spikes

        
% A generic template is used
[GenericTemplate] = GenerateGenericTemplate(DetectionParameters);

% First reading
FirstDet = SpikeDetection(GenericTemplate,DetectionParameters,Recording,Derivation);