function [ProcessedData] = Filter(RawData,DetectionParameters)

% Filters the EEG data

Fc_LP = 35;     % low-pass 
Fc_HP = 0.16;   % high-pass 

Wn = Fc_LP/(DetectionParameters.Fs/2); 
[Blp,Alp] = butter(5,Wn); 
RawData = filtfilt(Blp,Alp,RawData); 

Wn = Fc_HP/(DetectionParameters.Fs/2); 
[Bhp,Ahp] = butter(5,Wn,'high'); 
ProcessedData = filtfilt(Bhp,Ahp,RawData); 
