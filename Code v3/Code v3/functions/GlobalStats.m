function [Stat, TimeLineSWI] = GlobalStats(DetectedSpikes,Recording,NumDerivation,DetectionParameters)

% Return the global statistics (SWI, SWIG, SWF) of the analysis
%
%  INPUTS:	
%   Reference Spike             struct with informations of the template size and shape
%   DetectionParameters         struct with detection parameters defined in the main
%   Recording	                struct with recording's information  
%   Derivation                  number of the currently analyzed derivation           
%
%  OUTPUT:	
%   Stat                        struct with statistical information of the detected spikes:
%                               SWI, SWIG
%                               SWI: the spike-wave index corresponding to the percentage of 
%                               spike-and-wave (SW) activity, calculated by dividing the number of 
%                               seconds demonstrating one or more SW by the length of the extract, 
%                               multiplied by 100 to express the results as percentages
%                               SWIG: the SWI restricted only to SW that spread to >80% of the electrodes
%
%   TimeLineSWI                 struct with location informations of spikes 

StartAnalysis = Recording.StartAnalysis;
EndAnalysis = Recording.EndAnalysis;
NumElectrodes = length(Recording.Electrodes);

for CurrentEpoch=1:Recording.Epochs
    % Build a SpikeLine (1 if a spike is present) for each derivation and
    % electrode
    EpochDuration = EndAnalysis(CurrentEpoch)-StartAnalysis(CurrentEpoch);
    SpikeLine = zeros(NumDerivation, EpochDuration*DetectionParameters.Fs);
    SpikeLineEl = zeros(NumElectrodes, EpochDuration*DetectionParameters.Fs);
    
    for Derivation = 1:NumDerivation
        Det = DetectedSpikes(Derivation).Epoch;
        NumElRight = Recording.ElectrodesDictionary(Recording.NegativeElectrodes(Derivation,:));
        NumElLeft = Recording.ElectrodesDictionary(Recording.PositiveElectrodes(Derivation,:));

        if (length(Det) >= CurrentEpoch) && (length(Det(CurrentEpoch).Det) > 2) && (length(Det(CurrentEpoch).Det(:,1)) > 2)
            for IndexDetSpikes = 1:length(Det(CurrentEpoch).Det(:,1))
                BegSk = round((Det(CurrentEpoch).Det(IndexDetSpikes,1)/1000-Recording.StartAnalysis(CurrentEpoch))*DetectionParameters.Fs);
                EndSk = round((Det(CurrentEpoch).Det(IndexDetSpikes,2)/1000-Recording.StartAnalysis(CurrentEpoch))*DetectionParameters.Fs);
                if BegSk >0 && EndSk < length(SpikeLine(Derivation,:))
                    SpikeLine(Derivation,BegSk:EndSk-1) = ones(1,EndSk-BegSk);
                    SpikeLineEl(NumElLeft,BegSk:EndSk-1) = ones(1,EndSk-BegSk); 
                    SpikeLineEl(NumElRight,BegSk:EndSk-1) = ones(1,EndSk-BegSk); 
                end
            end
        end
    end
    
    SumSpikeLine = sum(SpikeLine);
    SumSpikeLineEl = sum(SpikeLineEl);
    
    % Find spikes and how many spikes there are at the same time
    [~,locsSpikes] = findpeaks(SumSpikeLine,'MINPEAKDISTANCE',round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs));
    
    % Adjust location of the spike on the middle of flat peak
    for index = 1:length(locsSpikes)
        localpeak = locsSpikes(index);
        MaxVal = SumSpikeLine(localpeak);
        Offset = 1;
        while SumSpikeLine(localpeak+Offset) == MaxVal
            Offset = Offset + 1;
        end
        locsSpikes(index) = localpeak + round(Offset/2);
    end
    
    % Remove doublets again
    index = 1;
    while index < length(locsSpikes)
        localpeak = locsSpikes(index);
        localpeakNext = locsSpikes(index+1);
        if localpeakNext-localpeak<round(DetectionParameters.MinimumDistance2Spikes/1000*DetectionParameters.Fs)
            locsSpikes(index+1) = [];
        end
        index = index+1;
    end
    
    SpikesInSecLine = zeros(1,EpochDuration);
    SpikesInSecLineEl = zeros(1,EpochDuration);
    AtLeastOneSpikeInSecLine = zeros(1,EpochDuration);
    SpikeIn80PercInSecLineEl = zeros(1,EpochDuration);
    
    TimeLineSWI(CurrentEpoch).list = [];
    TimeLineSWI(CurrentEpoch).listSpikeIn80El = [];
    TimeLineSWI(CurrentEpoch).locsSpikes = locsSpikes;
    TimeLineSWI(CurrentEpoch).SumSpikeLineEl = SumSpikeLineEl;

    for NumSec = 1:EpochDuration
        SpikeInThisSec = SumSpikeLine((NumSec-1)*DetectionParameters.Fs+1:NumSec*DetectionParameters.Fs);
        SpikeInThisSecEl = SumSpikeLineEl((NumSec-1)*DetectionParameters.Fs+1:NumSec*DetectionParameters.Fs);
        SpikesInSecLine(NumSec) = max(SpikeInThisSec);
        SpikesInSecLineEl(NumSec) = max(SpikeInThisSecEl);
        if SpikesInSecLine(NumSec)>0
            AtLeastOneSpikeInSecLine(NumSec) = 1;
            TimeLineSWI(CurrentEpoch).list = [TimeLineSWI(CurrentEpoch).list NumSec-1];
        end
        if SpikesInSecLineEl(NumSec)>= 0.8*NumElectrodes
            SpikeIn80PercInSecLineEl(NumSec) = 1;
            TimeLineSWI(CurrentEpoch).listSpikeIn80El = [TimeLineSWI(CurrentEpoch).listSpikeIn80El NumSec-1];
        end
    end
    TimeLineSWI(CurrentEpoch).list;
    Stat.GlobalSWI = [];
    Stat.GlobalSWIG = []; 
    Stat.GlobalSWI = [Stat.GlobalSWI AtLeastOneSpikeInSecLine];
    Stat.GlobalSWIG = [Stat.GlobalSWIG SpikeIn80PercInSecLineEl];

    Stat.SWF = 0;
    ind = 0;
    if CurrentEpoch == 1 && Recording.AnalysisDuration >= 100
        index100 = 100*DetectionParameters.Fs;
        while ind < length(locsSpikes) && locsSpikes(ind+1) <= index100
            ind = ind + 1;
        end
    end
    Stat.SWF = ind;
end

Stat.GlobalSWI = mean(Stat.GlobalSWI)*100;
Stat.GlobalSWIG = mean(Stat.GlobalSWIG)*100;
