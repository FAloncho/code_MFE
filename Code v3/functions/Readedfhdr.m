function [Nmb_chans,Label,Dim,Coef,S_date,S_time,Nmb_blck,Blck_size,Hdr_size,Pat_id,Rec_id,Transd,Prefilt,Nmb_samps] = Readedfhdr(fid)

%	[Nmb_chans,Label,Dim,Coef,S_date,S_time,Nmb_blck,Blck_size,Hdr_size,Pat_id,Rec_id,Transd,Prefilt,Nmb_samps] = Readedfhdr(fname)
%
%	Reads EDF file header
%
%  INPUTS:	
%   fname		file name
%
%  OUTPUTS:	
%   Nmb_chans	number of channels
%	Label		signal label, string matrix
%	Dim		    signal dimension, string matrix
%	Coef		scaling coefficients, matrix [PhysMin PhysMax DigMin DigMax]
%	S_date		date of the starting time of the recording [dd:mm:yy]
%	St_time		time of the beginning of the recording [hh:mm:ss]
%   Nmb_blck    number of data blocks
%	Blck_size	data block size
%   Hdr_size    header size
%	Pat_id		patient identification
%	Rec_id		record identification
%	Transd		transducer type
%	Prefilt		prefiltering
%   Nmb_samps   number of samples per data block

%	(c) Ilkka Korhonen 14.04.1997 
%	    03.10.2000 IKo fname may be file handle

fseek(fid,0,'bof');
Version = char(fread(fid,8,'char')');
Pat_id = char(fread(fid,80,'char')');
Rec_id = char(fread(fid,80,'char')');
S_date = char(fread(fid,8,'char')');
S_time = char(fread(fid,8,'char')');
Hdr_size = sscanf(char(fread(fid,8,'char')'),'%d');

fseek(fid,44,'cof');
Nmb_blck = sscanf(char(fread(fid,8,'char')'),'%d');
Blck_size  = sscanf(char(fread(fid,8,'char')'),'%d');
Nmb_chans  = sscanf(char(fread(fid,4,'char')'),'%d');

Label = ones(Nmb_chans,20)*' ';
Dim = ones(Nmb_chans,8)*' ';
Coef = zeros(Nmb_chans,4);
Transd = ones(Nmb_chans,80)*' ';
Prefilt = ones(Nmb_chans,80)*' ';
Nmb_samps = zeros(Nmb_chans,1);

% Labels are not standardized: 'EEG label' or 'label' formats
for i=1:Nmb_chans
    lab = char(fread(fid,16,'char')');
    if contains(lab,'EDF') || contains(lab,'ECG') || contains(lab,'EMG') || contains(lab,'EOG') 
        continue
    end
    if not(contains(lab,'EEG'))
	    Label(i,:) = ['EEG',' ',lab];
    else
        Label(i,:) = [lab,'    '];
    end
end
%char(Label)
for i=1:Nmb_chans
	Transd(i,:) = char(fread(fid,80,'char')');
end
for i=1:Nmb_chans
	Dim(i,:) = char(fread(fid,8,'char')');
end
for i=1:Nmb_chans
	Coef(i,1) = sscanf(char(fread(fid,8,'char')'),'%f');
end
for i=1:Nmb_chans
	Coef(i,2) = sscanf(char(fread(fid,8,'char')'),'%f');
end
for i=1:Nmb_chans
	Coef(i,3) = sscanf(char(fread(fid,8,'char')'),'%f');
end
for i=1:Nmb_chans
	Coef(i,4) = sscanf(char(fread(fid,8,'char')'),'%f');
end
for i=1:Nmb_chans
	Prefilt(i,:) = char(fread(fid,80,'char')');
end
for i=1:Nmb_chans
	Nmb_samps(i)  = sscanf(char(fread(fid,8,'char')'),'%d');
end
