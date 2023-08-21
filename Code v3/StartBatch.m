% BATCH

% Choose your parameters

Purpose = 'Both'; % 'Display', 'Statistics', or 'Both'
% - 'Statistics' exports statistics in an excel sheet
% - 'Display' exports EEG displays in jpg files
% - 'Both' does the two above

Recordinglist = 1;

StartOfAnalysis = 0;    % in seconds
AnalysisDuration = 60;  % in seconds, or Inf for the whole recording
SliceRecording = 'No';  %'Yes' to slice the recording in windows for faster performances
SliceDuration = 5;      % in minutes (can't go below 2 minutes)

MontageChoice = 1; % 1, 2 or 3
% - 1 Longitudinal montage
% - 2 Transversal montage
% - 3 Referential montage

Main()