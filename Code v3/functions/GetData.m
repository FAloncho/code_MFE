function [data] = GetData(Recording,Epoch,Derivation,DetectionParameters)

% Collects the data from the whole data matrix

PositiveElectrode = Recording.PositiveElectrodes(Derivation,:);
NegativeElectrode = Recording.NegativeElectrodes(Derivation,:);
StartAnalysis = Recording.StartAnalysis(Epoch);
EndAnalysis = Recording.EndAnalysis(Epoch);

if strcmp(NegativeElectrode,'')
    data = cell2mat(Recording.Data(Recording.ElectrodesDictionary(PositiveElectrode),1+StartAnalysis*Recording.Fs:EndAnalysis*Recording.Fs)); 
else
    xL = cell2mat(Recording.Data(Recording.ElectrodesDictionary(PositiveElectrode),1+StartAnalysis*Recording.Fs:EndAnalysis*Recording.Fs)); 
    xR = cell2mat(Recording.Data(Recording.ElectrodesDictionary(NegativeElectrode),1+StartAnalysis*Recording.Fs:EndAnalysis*Recording.Fs)); 
    data = xL-xR;
end

data = data' * Recording.Cal + Recording.Off;

if Recording.Fs ~= DetectionParameters.Fs
    data = resample(data,DetectionParameters.Fs,Recording.Fs);
end
