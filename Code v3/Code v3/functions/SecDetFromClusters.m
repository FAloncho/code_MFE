function [PatientSpecificDetSpikes] = SecDetFromClusters(Clusters,Recording,DetectionParameters,Derivation)

% Second detection based on the clusters 
%
%  INPUTS:	
%   Clusters                    struct with informations about the clusters (cf ClustersFromDetect function)
%   Recording	                struct with recording's information  
%   DetectionParameters         struct with detection parameters defined in the main
%   Derivation                  number of the currently analyzed derivation           
%
%  OUTPUTS:	
%   PatientSpecificDetSpikes   struct with informations of size, shape and position?? of detected spikes, sorted (cf AddAndSortDetect)

PatientSpecificDetSpikesCluster(Clusters.NumClusters).Det = [];

for CurrentCluster = 1:Clusters.NumClusters
    Clusters.PatientSpecificDetSpikesResult(CurrentCluster).SpikeRawData = [];
    if sum(CurrentCluster == Clusters.RejectedClusters)==0
        PatientSpecificDetectionParameters.Template = Clusters.Centroids(CurrentCluster,:);
        PatientSpecificDetectionParameters.TemplateLength = length(PatientSpecificDetectionParameters.Template);
        PatientSpecificDetectionParameters.TemplateNorm = norm(PatientSpecificDetectionParameters.Template);

        PatientSpecificDetectionParameters.RisingSlopeThreshold = mean(Clusters.FeatureCluster(CurrentCluster).RisingSlope)*DetectionParameters.PatientSpecificFeaturesThresh;
        PatientSpecificDetectionParameters.FallingSlopeThreshold = mean(Clusters.FeatureCluster(CurrentCluster).FallingSlope)*DetectionParameters.PatientSpecificFeaturesThresh;
        PatientSpecificDetectionParameters.CurvatureThreshold = mean(Clusters.FeatureCluster(CurrentCluster).Curvature)*DetectionParameters.PatientSpecificFeaturesThresh;
        PatientSpecificDetectionParameters.CorrelationThreshold = DetectionParameters.PatientSpecificCrossCorrelationThresh;

        PatientSpecificDetSpikesCluster(CurrentCluster).Det = SpikeDetection(PatientSpecificDetectionParameters,DetectionParameters,Recording,Derivation);
    end
end

PatientSpecificDetSpikes = AddAndSortDetect(PatientSpecificDetSpikesCluster,round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs),Recording.StartAnalysis);
