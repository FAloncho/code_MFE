function [SecDetAdj] = BegEndSpikeAdujstment(SecDet,Recording,NumDerivation,DetectionParameters)

% Adjust the start and the end of the differents spikes
%
%  INPUTS:	
%   SecDet                      struct with informations of size, shape and position?? of detected spikes, sorted (cf AddAndSortDetect)
%   Recording	                struct with recording's information  
%   DetectionParameters         struct with detection parameters defined in the main          
%
%  OUTPUT:	
%   SecDetAdj                   struct of spikes with adjusted start and end

Fs = DetectionParameters.Fs;
windowBegPlus = round(Fs*0);            % 0 ms
windowBegMinus = round(Fs*100/1000);    % 100 ms 
BegEndLength = round(Fs*125/1000);      % 125 ms 
windowEndPlus = round(Fs*50/1000);      % 50 ms 
windowEndMinus = round(Fs*50/1000);     % 50 ms

for Derivation = 1:NumDerivation
    for k=1:length(Recording.StartAnalysis)  
        [rawdata] = GetData(Recording,k,Derivation,DetectionParameters); 

        if isempty(SecDet(Derivation).Epoch(k).Det)
            SecDetAdj(Derivation).Epoch(k).Det = [];
        else
            for i=1:length(SecDet(Derivation).Epoch(k).Det(:,1))

                BegSpike = round((SecDet(Derivation).Epoch(k).Det(i,1)/1000-Recording.StartAnalysis(k))*Fs); 
                BegWinSbeg = BegSpike-windowBegMinus;
                if BegWinSbeg<1
                    BegWinSbeg = 1;
                end
                EndWinSbeg = BegSpike+windowBegPlus;
                if EndWinSbeg>length(rawdata)
                    EndWinSbeg = length(rawdata);
                end
                if BegWinSbeg<EndWinSbeg
                    [~, pos] = min(rawdata(BegWinSbeg:EndWinSbeg));
                    BegSpikeAdj = BegSpike+pos-windowBegMinus-1;
                else
                    BegSpikeAdj = BegSpike;
                end

                BegWinSend = BegSpikeAdj+BegEndLength-windowEndMinus;
                if BegWinSend<1
                    BegWinSend = 1;
                end
                EndWinSend = BegSpike+BegEndLength+windowEndPlus;
                if EndWinSend>length(rawdata)
                    EndWinSend = length(rawdata);
                end
                if BegWinSend<EndWinSend
                    [~, pos] = min(rawdata(BegWinSend:EndWinSend));
                    EndSpikeAdj = BegSpikeAdj+BegEndLength+pos-windowEndMinus-1;
                else
                    EndSpikeAdj = EndWinSend;
                end

                SecDetAdj(Derivation).Epoch(k).Det(i,1) = (BegSpikeAdj/Fs+Recording.StartAnalysis(k))*1000;
                SecDetAdj(Derivation).Epoch(k).Det(i,2) = (EndSpikeAdj/Fs+Recording.StartAnalysis(k))*1000;
            end
        end
    end
end
            