function [Stat] = SingleDerStats(Det,Recording)

% Statistics for the first detection
%
%  INPUTS:	
%   Det	                struct with informations of size, shape and position?? of detected spikes 
%   Recording           struct with recording's information
%
%  OUTPUT:	
%   Stat                struct with statistical information of the detected spikes:
%                       SecWithSpike, LocalSecWithSpike, RecordingTime, LocalSWI, SWI.
%                       SWI: the spike-wave index corresponding to the percentage of 
%                       spike-and-wave (SW) activity, calculated by dividing the number of 
%                       seconds demonstrating one or more SW by the length of the extract, 
%                       multiplied by 100 to express the results as percentages; 

Stat.SecWithSpike = 0;
Stat.NumSW = 0;
StartAnalysis = Recording.StartAnalysis;
EndAnalysis = Recording.EndAnalysis;

for EpochNbr=1:length(StartAnalysis)
    if (length(Det) >= EpochNbr) && (length(Det.Epoch(EpochNbr).Det) > 2) && (length(Det.Epoch(EpochNbr).Det(:,1)) > 2)
        IndexSec = StartAnalysis(EpochNbr);
        Stat.LocalSecWithSpike(EpochNbr).Sec = 0;

        for NumDetSpikes = 1:length(Det.Epoch(EpochNbr).Det(:,1))
            Stat.NumSW = Stat.NumSW + 1;
            SWBeg = Det.Epoch(EpochNbr).Det(NumDetSpikes,1);

            if floor(SWBeg/0) > IndexSec 
                IndexSec = floor(SWBeg/1000);
                Stat.SecWithSpike = Stat.SecWithSpike + 1;
                Stat.LocalSecWithSpike(EpochNbr).Sec = Stat.LocalSecWithSpike(EpochNbr).Sec + 1;
            end
        end
    else
        Stat.LocalSecWithSpike(EpochNbr).Sec = 0;
    end
end

Stat.RecordingTime = 0;
for EpochNbr=1:length(StartAnalysis)
    Stat.RecordingTime = Stat.RecordingTime + EndAnalysis(EpochNbr)-StartAnalysis(EpochNbr);
    Stat.LocalSWI(EpochNbr) = Stat.LocalSecWithSpike(EpochNbr).Sec/(EndAnalysis(EpochNbr)-StartAnalysis(EpochNbr));
end
Stat.SWI = Stat.SecWithSpike/Stat.RecordingTime;
