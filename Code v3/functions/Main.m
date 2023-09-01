function [] = Main()

% This code is for reseach purpose only. 

% This EEG Spike detection code allows to detect spikes in an EEG record
% by using a fully automated method described in [Nonclercq2012] and based
% on [Nonclercq2009]:
% We propose a fully automated method of interictal spike detection that
% adapts to interpatient and intrapatient variation in spike morphology.
% The algorithm works in five steps. (1) Spikes are detected using
% parameters suitable for highly sensitive detection. (2) Detected spikes
% are separated into clusters. (3) The number of clusters is automatically
% adjusted. (4) Centroids are used as templates for more specific spike
% detections, therefore adapting to the types of spike morphology. (5)
% Detected spikes are summed.       
% Detected spikes are marked as spike event with a value corresponding to
% the electrode name where the spike has been detected. 

% At the end of the detection process, it also computes and exports in an
% excel file various statistics [VanHecke2022]: 
% (1) the spike-wave index (SWI) corresponding to the percentage of 
% spike-and-wave (SW) activity, calculated by dividing the number of 
% seconds demonstrating one or more SW by the length of the extract, 
% multiplied by 100 to express the results as percentages; 
% (2) the spike-wave frequency (SWF) corresponding to the number of SW 
% events in the first 100 s of the EEG (0 if the duration of the analysis
% is less than 100 s); and finally 
% (3) the SWI restricted only to SW that spread to >80% of the electrodes

% This code has two interfaces:
% - a batch, which can be run directly from the editor and in which the 
%   parameters related to spike detection must be entered manually.
% - a GUI, allowing the parameters selection in a dedicated environment.

% If you use this toolbox for a publication (in a journal, in a conference,
% etc.), please cite both related publications: [Nonclercq2012] and
% [Nonclercq2009]. 
% As SPM, the license attached to this toolbox is GPL v2, see
% https://www.gnu.org/licenses/gpl-2.0.txt. From
% https://www.gnu.org/licenses/gpl-2.0.html, it implies:   
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.   

% References:
% [Nonclercq2009] Nonclercq, A., Foulon, M., Verheulpen, D., De Cock, C.,
% Buzatu, M., Mathys, P., & Van Bogaert, P. (2009). Spike detection
% algorithm automatically adapted to individual patients applied to spike
% and wave percentage quantification. Neurophysiologie Clinique, 39,
% 123–131. doi:10.1016/j.neucli.2008.12.001    
% [Nonclercq2012] Nonclercq, A., Foulon, M., Verheulpen, D., De Cock, C.,
% Buzatu, M., Mathys, P., & Van Bogaert, P. (2012). Cluster-based spike
% detection algorithm adapts to interpatient and intrapatient variation in
% spike morphology. Journal of Neuroscience Methods, 210(2), 259–265.
% doi:10.1016/j.jneumeth.2012.07.015  
% [VanHecke2022] Van Hecke A, Nebbioso A, Santalucia R, Vermeiren J, De 
% Tiège X, Nonclercq A, Van Bogaert P, Aeby A. The EEG score is diagnostic 
% of continuous spike and waves during sleep (CSWS) syndrome. Clin 
% Neurophysiol. 2022 Jun;138:132-133. doi: 10.1016/j.clinph.2022.03.013. 
% Epub 2022 Mar 25.PMID: 35390761.  

% **********************
% Files and parameters *
% **********************

DBPath = [pwd '\Data\'];

Batch = false;
AmpValue = getappdata(gcf,'ampValue');
StartOfAnalysis = getappdata(gcf,'startValue');
AnalysisDuration = getappdata(gcf,'durationValue');
SliceRecording = getappdata(gcf,'sliceValue');
SliceDuration = getappdata(gcf,'durationSliceValue');
Recordinglist = getappdata(gcf, 'fileName');
MontageChoice = getappdata(gcf,'montageChoice');

% **********************
% Recordings retrieval *
% **********************

% Montage: positive electrodes are measured against their negative ones
% e.g. PositiveElectrodes[1]-NegativeElectrodes[1] 
if MontageChoice == 1
% longitudinal montage
    PositiveElectrodes =  ["EEG Fp1";"EEG F7";"EEG T3";"EEG T5";"EEG Fp1";"EEG F3";"EEG C3";"EEG P3";"EEG Fp2";"EEG F8";"EEG T4";"EEG T6";"EEG Fp2";"EEG F4";"EEG C4";"EEG P4"];
    NegativeElectrodes = ["EEG F7";"EEG T3";"EEG T5";"EEG O1";"EEG F3";"EEG C3";"EEG P3";"EEG O1";"EEG F8";"EEG T4";"EEG T6";"EEG O2";"EEG F4";"EEG C4";"EEG P4";"EEG O2"];

elseif MontageChoice == 2
% transversal montage
    PositiveElectrodes =  ["EEG Fp1";"EEG F7";"EEG F3";"EEG Fz";"EEG F4";"EEG T3";"EEG C3";"EEG Cz";"EEG C4";"EEG T5";"EEG P3";"EEG Pz";"EEG P4";"EEG O1"];
    NegativeElectrodes = ["EEG Fp2";"EEG F3";"EEG Fz";"EEG F4";"EEG F8";"EEG C3";"EEG Cz";"EEG C4";"EEG T4";"EEG P3";"EEG Pz";"EEG P4";"EEG T6";"EEG O2"];

elseif MontageChoice == 3
% monopolar or referential mountage
    PositiveElectrodes =  ["EEG Fp1";"EEG F3";"EEG C3";"EEG P3";"EEG O1";"EEG F7";"EEG T3";"EEG T5";"EEG Fz";"EEG Cz";"EEG Pz";"EEG Fp2";"EEG F4";"EEG C4";"EEG P4";"EEG O2";"EEG F8";"EEG T4";"EEG T6"];
    NegativeElectrodes = ["EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A1";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2";"EEG A2"];
end
NumDerivation = length(PositiveElectrodes(:,1));

[Recordings] = GetRecordings(DBPath,SliceRecording,SliceDuration,Recordinglist,StartOfAnalysis,AnalysisDuration,PositiveElectrodes,NegativeElectrodes);

% ***********************
%  Detection parameters *
% ***********************

% General parameters
DetectionParameters.Fs = 200; % EEG sampling frequency - Imposed: resampled
DetectionParameters.WindowLength = 300;             % ms   
DetectionParameters.MinimumDistance2Spikes = 80;    % ms
% MinimumDistance2Spikes can be increased (~125 ms) for recordings with few
% spikes and decreased (~50 ms) for recordings with many spikes

% Generic Spike Detection Parameters
DetectionParameters.GenericCrossCorrelationThresh = 0.6; % Cross-correlation threshold
DetectionParameters.GenericFeaturesThresh = 0.3; % Features threshold
DetectionParameters.GenericTemplateAmplitude = AmpValue; % uV

% Subject Specific spike detection parameters
DetectionParameters.PatientSpecificCrossCorrelationThresh = 0.7; % Cross-correlation threshold
DetectionParameters.PatientSpecificFeaturesThresh = 0.5; % Features threshold
DetectionParameters.PatientSpecificMinimumSWI = 0.1;
DetectionParameters.ClusterSelectionThresh = 0.05;

% ************
%  Detection *
% ************

for CurrentRecording = 1:length(Recordings)
    fprintf(['Recording: ' Recordings(CurrentRecording).name '\n']);

    parfor Derivation = 1:NumDerivation
        % FIRST STEP: Generic spike detection
        GenDetectedSpikes = GenericDetection(Recordings(CurrentRecording),DetectionParameters,Derivation);
        % Statistics and SWI for first detection
        StatGenDet = SingleDerStats(GenDetectedSpikes,Recordings(CurrentRecording));
        
        % SECOND STEP: Subject-specific detection
        if StatGenDet.SWI>DetectionParameters.PatientSpecificMinimumSWI
            [Clusters] = ClustersFromDetect(DetectionParameters.ClusterSelectionThresh,GenDetectedSpikes);
            SpecificSpikes(Derivation).Epoch = SecDetFromClusters(Clusters,Recordings(CurrentRecording),DetectionParameters,Derivation);
        else
            SpecificSpikes(Derivation).Epoch = GenDetectedSpikes.Epoch;
        end
    end 

    % Adjusting the beginning and the end of spikes
    [SpecificSpikesAdj]= BegEndSpikeAdujstment(SpecificSpikes,Recordings(CurrentRecording),NumDerivation,DetectionParameters);
    % Global SWI of Subject-specific detection
    [PatientSpecificStats(CurrentRecording).Stat, TimeLineSWI]= GlobalStats(SpecificSpikesAdj,Recordings(CurrentRecording),NumDerivation,DetectionParameters);
    % Display and save as jpg
    if ~Batch || strcmp(Purpose,'Display') || strcmp(Purpose,'Both')
        disp(Display,SpecificSpikesAdj,Recordings(CurrentRecording),TimeLineSWI,DetectionParameters, MontageChoice, PatientSpecificStats(CurrentRecording).Stat);
    end

end
WriteExcel(PatientSpecificStats,Recordings);
% Write in Excel
if Batch && (strcmp(Purpose,'Statistics') || strcmp(Purpose,'Both'))
    WriteExcel(PatientSpecificStats,Recordings);
end
save('AllData');
