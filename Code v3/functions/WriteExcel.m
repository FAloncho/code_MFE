function [] = WriteExcel(Stat,Recordings)

% Writes an excel file with the results of indicators (SWI, SWF and SWIG)

% Initializations of the indicators
Nmb_recordings = length(Stat);
Recduration = zeros(Nmb_recordings,1);
SWF = zeros(Nmb_recordings,1);
SWI = zeros(Nmb_recordings,1);
SWIG = zeros(Nmb_recordings,1);
RowNames = strings(Nmb_recordings,1);

% Retrieves the indicator's values
for CurRecording = 1:Nmb_recordings 
    if ~isempty (Stat(CurRecording).Stat)
        SWF(CurRecording) = Stat(CurRecording).Stat.SWF;
        SWI(CurRecording) = Stat(CurRecording).Stat.GlobalSWI;
        SWIG(CurRecording) = Stat(CurRecording).Stat.GlobalSWIG;
    end
    Recduration(CurRecording) = Recordings(CurRecording).AnalysisDuration;
    %RowNames(CurRecording) = num2str(CurRecording);
    RowNames = {Recordings(CurRecording).name};
end

% Writes in the Excel table
name='Indicators.xlsx';
T = array2table([Recduration RowNames SWF SWI SWIG],'VariableNames', ...
    {'Analysis time (s)','Patients','SWF','SWI','SWIG'});
writetable(T,name,'Range','A2','WriteRowNames',true);
