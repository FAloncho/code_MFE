function [x,Fs,Start_date,Start_time,Label,Dimension,Cal,Off,Nmb_chans,N] = Readedf(fname,ch,t1,t2)

%	[x,Fs,Start_date,Start_time,Label,Dimension,Cal,Off,Nmb_chans,N] = readedf(fname,channel,t1,t2)
% 
%	Reads one channel from EDF-file in given time scale. Time scale may be given as seconds from
%	the beginning of the file or in hh:mm:ss format. In hh:mm:ss format, the hours of the next days
%	are accessed by adding 24h to the true time (e.g. 25:00:00 means 01:00:00 of the day following
%	the starting date of the recording).
%
%  INPUTS:	
%   fname	file name OR file handle (empty -> file name is asked for)
%	ch		channel number, 1st channel being 0, or channel label (default 0)
%	t1		start time (seconds from the beginning of file OR hh:mm:ss) (default 0)
%	t2		end time (seconds from the beginning of file OR hh:mm:ss) (default all)
%
%  OUTPUTS:	
%   x		    signal in column vector
%	Fs		    sampling frequency
%	Start_date	date of the starting time of the recording [dd:mm:yy]
%	Start_time	time of the beginning of the recording [hh:mm:ss]
%	Label		signal label
%	Dimension	signal dimension
%   Cal
%   Off
%	Nmb_chans	number of channels in the file
%	N		    data length in seconds

%	(c) Ilkka Korhonen 13.2.1996 (20.2.1996 IKo) (16.10.1997 IKo) (22.10.1997 IKo fid/fname)
%	    Juha Pärkkä 10.7.1997, IKO 11.08.1998, IKo 26.11.1998, IKo 25.01.1999, IKo 21.07.1999
%	    IKo 05.10.1999, IKo 20.10.1999 (t2 inf), IKo 03.10.2000 (ch may be string)

% *****************
% Arguments check *
% *****************

if nargin<1
    fname='';
    ch = 0;
    t1 = 0;
end
if nargin<2
    ch = 0;
    t1 = 0;
end
if nargin<3;t1 = 0;end

% ************
%  Open file *
% ************

if isempty(fname)
	[fname,pname]=uigetfile('*.rec','Select European Data Format file');
	fname = [pname fname];
end

fid = fopen(fname,'r');
if fid == -1
	disp('Cannot open file !');
	return;
end

% **********************
%  Header informations *
% **********************

[Nmb_chans,Label,Dimension,Coef,Start_date,Start_time,Nmb_blck,Blck_size,Hdr_size,~,~,~,~,Nmb_samps] = Readedfhdr(fid);

% Channels check - If the label of the channel is given
if isstring(ch)

    match_ch = [];
    for i=1:Nmb_chans
        if strncmpi(convertStringsToChars(ch),char(Label(i,:)), length(convertStringsToChars(ch)))
            %convertStringsToChars(ch)
            char(Label(i,:));
            match_ch = [match_ch i-1];
        end
    end
    if length(match_ch)>1
        fprintf('Matching channels in the given EDF file:\n');
        for i=1:length(match_ch)
            fprintf('Channel %d:\t%s\n',match_ch(i),char(Label(match_ch(i)+1,:)));
        end
        error('Only one channel should be given!');
    elseif isempty(match_ch)
        error('No such channel!');
    else
        ch = match_ch;
    end
end


% Data length & frequency
N = Nmb_blck*Blck_size;
Fs = Nmb_samps(ch+1)/Blck_size;

% Time conversions (transforms start and end times to seconds if necessary)
HH = str2double(Start_time(1:2));
MM = str2double(Start_time(4:5));
SS = str2double(Start_time(7:8));
Start_time_sec = HH*60*60+MM*60+SS;

if max(size(t1))>1
    HH = str2double(t1(1:2));
    MM = str2double(t1(4:5));
    SS = str2double(t1(7:8));
    t1 = (HH*60*60+MM*60+SS) - Start_time_sec;
end
if max(size(t2))>1
    HH = str2double(t2(1:2));
    MM = str2double(t2(4:5));
    SS = str2double(t2(7:8));
    t2 = (HH*60*60+MM*60+SS) - Start_time_sec;
elseif isempty(t2)
    t2 = N;
end
if t2>N || isinf(t2);t2=N;end

% Scaling informations
Phys_min = Coef(ch+1,1);
Phys_max = Coef(ch+1,2);
Dig_min = Coef(ch+1,3);
Dig_max = Coef(ch+1,4);
Cal = (Phys_max-Phys_min)./ (Dig_max-Dig_min);
Off = Phys_min - Cal .* Dig_min;

% ****************
%  Read edf file *
% ****************

Data_rec = sum(Nmb_samps)*2;

x  = zeros(min([ceil(Fs*(t2-t1)) ceil(N*Fs)]),1);
Skip = Data_rec-Nmb_samps(ch+1)*2;
Blck_1 = fix(t1/Blck_size);		% 1st data block number
block1 = Data_rec*Blck_1;
Blck_N = fix(t2/Blck_size);		% Last data block number	

% 1st data block
if (fseek(fid,Hdr_size+block1,-1)<0)
	x=[];return;
end
Blck_cnt = Blck_1;
if ch~=0
	Skip_1 = sum(Nmb_samps(1:ch))*2;
else
	Skip_1 = 0;
end
offset = round(rem(t1,Blck_size)*Fs)*2;
if (fseek(fid,offset + Skip_1,0)<0)
	x=[];return;
end
if Blck_1==Blck_N 		% Read only within one block
    n2 = round(rem(t2,Blck_size)*Fs) - offset/2;
else					% Read at least within two blocks
	n2 = Nmb_samps(ch+1) - offset/2;
end
x(1:n2) = fread(fid,n2,'int16');

% Next data blocks
while (Blck_cnt<Blck_N-1)
	Blck_cnt = Blck_cnt+1;
	n1 = n2+1;
	n2 = n1+Nmb_samps(ch+1)-1;
    if (fseek(fid,Skip,0)==0)
        x_tmp = fread(fid,Nmb_samps(ch+1),'int16');
        if ~isempty(x_tmp);x(n1:n2) = x_tmp;end
    else
	    break;
    end
end

% Final data block
if Blck_1 ~= Blck_N
    fseek(fid,Skip,0);
    pos0=ftell(fid);
    fseek(fid,pos0,'bof');
    n1 = n2+1;
    offset = round(rem(t2,Blck_size)*Fs);
    if offset>0
        n2 = n1 + offset -1;
        x_tmp = fread(fid,offset,'int16');
        if length(x_tmp)==offset;x(n1:n2) = x_tmp;end
    end
end
	
% Finally, scale the signal
a = polyfit([Dig_min Dig_max],[Phys_min Phys_max],1);
x = x*a(1)+a(2);

fclose(fid);
