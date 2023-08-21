function [GenericTemplate] =  GenerateGenericTemplate(DetectionParameters)

% Creates the generic template to identify the spikes (first detection)
%
%  INPUT:	 
%   DetectionParameters         struct with detection parameters defined in the Main        
%
%  OUTPUT:	
%   GenericTemplate             struct with informations of the template size and shape                   

EndWindow = round(DetectionParameters.Fs*DetectionParameters.WindowLength/1000);
MidSpike = round(DetectionParameters.Fs*30/1000); % 30ms
EndSpike = round(DetectionParameters.Fs*60/1000); % 60ms

V(round(1.33*EndWindow))=0;
for i = 1:1:MidSpike
    V(i) = round(i*DetectionParameters.GenericTemplateAmplitude/MidSpike);
end
for i = MidSpike:1:EndSpike
    V(i) = round(DetectionParameters.GenericTemplateAmplitude-(i-MidSpike)*DetectionParameters.GenericTemplateAmplitude/MidSpike);
end

ProcessedData = PreProcessing(V',DetectionParameters);
ProcessedData = ProcessedData(1:EndWindow);

GenericTemplate.Exists = 1;
GenericTemplate.Template = ProcessedData;
GenericTemplate.TemplateLength = length(ProcessedData);
GenericTemplate.TemplateNorm = norm(ProcessedData);
[GenericTemplate.RisingSlope, PositionRisingSlope] = max(ProcessedData);
GenericTemplate.RisingSlope = sqrt(abs(GenericTemplate.RisingSlope));
[GenericTemplate.FallingSlope, PositionFallingSlope] = min(ProcessedData);
GenericTemplate.FallingSlope = -sqrt(abs(GenericTemplate.FallingSlope));
GenericTemplate.Curvature = abs((GenericTemplate.RisingSlope - GenericTemplate.FallingSlope)/(PositionRisingSlope - PositionFallingSlope)); 

GenericTemplate.RisingSlopeThreshold = GenericTemplate.RisingSlope*DetectionParameters.GenericFeaturesThresh; 
GenericTemplate.FallingSlopeThreshold = GenericTemplate.FallingSlope*DetectionParameters.GenericFeaturesThresh; 
GenericTemplate.CurvatureThreshold = GenericTemplate.Curvature*DetectionParameters.GenericFeaturesThresh; 
GenericTemplate.CorrelationThreshold = DetectionParameters.GenericCrossCorrelationThresh;
