function [Recordings] = GetRecordings(DBPath,SliceRecording,SliceDuration,Recordinglist,StartOfAnalysis,AnalysisDuration,PositiveElectrodes,NegativeElectrodes)

% Collects the recording's information
%
%  INPUTS:	
%   DBPath	                path to Data
%	SliceRecording		    yes or no depending on whether the analysis has been cut into slice in parallel or not 
%	SliceDuration		    duration of each slice
%	Recordinglist		    name of the file to analyze
%   StartOfAnalysis         start time of the analysis in seconds
%   AnalysisDuration        duration of the analysis in seconds 
%   PositiveElectrodes      list of positive electrodes depending on the montage choice
%   NegativeElectrodes      list of negative electrodes depending on the montage choice      
%
%  OUTPUTS:	
%   Recordings                          struct for each recording with informations:
%
%             .name                     list of names of all recordings
%             .fname                    file name
%             .NegativeElectrodes       list of negative electrodes depending on the montage choice
%             .PositiveElectrodes       list of positive electrodes depending on the montage choice
%             .EletrodesDictionary      dictionary of all electrodes
%             .Data                     cell array with signal in colomn vector
%             .AnalysisDuration         duration of the analysis in seconds
%             .Fs                       sampling frequency
%             .Cal                      ?
%             .Off                      ?
%             .StartTime                start time of the analysis in datetime format (dd.MM.yyyy HH:mm:ss)
%             .EndTime                  end time of the analysis in datetime format (dd.MM.yyyy HH:mm:ss)
%             .Epochs                   number of epochs if signal sliced

Recordings(size(Recordinglist,1)) = struct();
for NumRec = 1:size(Recordinglist,1)
    % Electrodes
    Recordings(NumRec).NegativeElectrodes = NegativeElectrodes;
    Recordings(NumRec).PositiveElectrodes = PositiveElectrodes;
    
    Electrodes = [PositiveElectrodes; NegativeElectrodes];
    Recordings(NumRec).Electrodes = unique(Electrodes, 'rows');
    Values = 1:size(Recordings(NumRec).Electrodes,1);
    Recordings(NumRec).ElectrodesDictionary = dictionary(Recordings(NumRec).Electrodes,Values');

    % Note that electrodes and electrode montage are assigned on an 
    % individual basis (for each recording). Please add specific code here 
    % if willing to individualise the electrodes and electrode montage.
    Recordinglist(NumRec,:)
    % File information
    if endsWith('\', DBPath)
        %previousline Recordings(NumRec).fname = [DBPath Recordinglist(NumRec) '.EDF'];
        Recordings(NumRec).fname = [DBPath Recordinglist(NumRec,:)]; %(NumRec,:) for filename: all columns but one line
    else 
        %previousline Recordings(NumRec).fname = [DBPath '\' Recordinglist(NumRec) '.EDF'];
        Recordings(NumRec).fname = [DBPath '\' Recordinglist(NumRec,:)];
        
    end
    Recordings(NumRec).fname
    Recordings(NumRec).name = Recordinglist(NumRec,:);
    
    % Data
    if ~(mod(AnalysisDuration,20) == 0)
        AnalysisDuration = AnalysisDuration + (20 - mod(AnalysisDuration,20));
    end
    EndOfAnalysis = StartOfAnalysis+AnalysisDuration;
    for Elec = 1:length(Recordings(NumRec).Electrodes)
        [x,Fs,S_date,S_time,~,~,Cal,Off,~,N] = Readedf(Recordings(NumRec).fname,Recordings(NumRec).Electrodes(Elec),StartOfAnalysis,EndOfAnalysis);
        Recordings(NumRec).Data(Elec,:) = num2cell(x);
    end

    if EndOfAnalysis > N
        AnalysisDuration = N-StartOfAnalysis;
    end
    Recordings(NumRec).AnalysisDuration = AnalysisDuration;
    Recordings(NumRec).Fs = Fs;
    Recordings(NumRec).Cal = Cal;
    Recordings(NumRec).Off = Off;

    % Times
    Start_date_rec = [S_date(1:6) '20' S_date(7:8)];
    Start_time_rec = [S_time(1:2) ':' S_time(4:5) ':' S_time(7:8)];
    Full_start_time_rec = [Start_date_rec ' ' Start_time_rec];
    Recordings(NumRec).Start_time = datetime(Full_start_time_rec,'InputFormat','dd.MM.yyyy HH:mm:ss') + seconds(StartOfAnalysis);
    Recordings(NumRec).End_time = Recordings(NumRec).Start_time + seconds(AnalysisDuration);

    if (AnalysisDuration > SliceDuration*60) && strcmp(SliceRecording,'Yes') 
        for i = 1:floor(AnalysisDuration/(SliceDuration*60))
            Recordings(NumRec).StartAnalysis(i) = (i-1)*SliceDuration*60;
            Recordings(NumRec).EndAnalysis(i) = i*SliceDuration*60;
        end
        if (AnalysisDuration/(SliceDuration*60) > floor(AnalysisDuration/(SliceDuration*60)))
            Recordings(NumRec).EndAnalysis(length(Recordings(NumRec).EndAnalysis)+1) = AnalysisDuration;
            Recordings(NumRec).StartAnalysis(length(Recordings(NumRec).StartAnalysis)+1) = Recordings(NumRec).EndAnalysis(length(Recordings(NumRec).EndAnalysis)-1);
        end
    else
        Recordings(NumRec).StartAnalysis = 0;
        Recordings(NumRec).EndAnalysis = AnalysisDuration;
    end
    Recordings(NumRec).Epochs = length(Recordings(NumRec).StartAnalysis);
end
