%% SET UP
% written by Zack Guido January 2024 to visualize SWE at the NRCS stations
% closest to the desired ski mountains around the West
clearvars
close all

% Title locations
x1 = 0.125;
y1 = 0.9;
w = 0.5;
h = 0.1;

% Create a custom date vector to account for Data beginning Oct1
Datevec = horzcat(274:365,1:273)';

% Current time
dNow   = datetime('now');
YY     = dNow.Year;
MM     = dNow.Month;
DD     = dNow.Day;

% DATA

% --- UTAH ---
% (1) Snowbird (Snowbird Station)
Bird = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/UT/Snowbird.csv');
SBelev = 9710; %fasl

% (2) Alta (Brighton Station)
Alta = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/UT/Brighton.csv');
Aelev = 8790; %fasl

% (3) Powder Mtn (Little Bear station)
Powder = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/UT/Little%20Bear.csv');
PMelev = 6540; %fasl

% (4) Solitude (Mill-D North station)
Solitude = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/UT/Mill-D%20North.csv');
Selev = 8940; %fasl

% --- WYOMING ---
% (1) Jackson (Phillips Bench station)
Jackson = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/WY/Phillips%20Bench.csv');
Jelev = 8160; %fasl

% (2) Grand Targee (Grand Targhee station)
Targee = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/WY/Grand%20Targhee.csv');
GTelev = 9260; %fasl

% --- MONTANTA ---
% (1) Big Sky (Lone Mountain station)
BigSky = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/MT/Lone%20Mountain.csv');
BSelev = 8810; %fasl

% (2) Bridger (Sacajawea station)
Bridger = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/MT/Sacajawea.csv');
Belev = 6610; %fasl

% --- OREGON ---
% (1) Mount Bachelor 4-site componse
Mck = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/OR/Mckenzie.csv');
Mckelev = 4470; %fasl

TCr = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/OR/Three%20Creeks%20Meadow.csv');
TCrelev = 5680; %fasl;

RR = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/OR/Roaring%20River.csv');
RRelev = 4690; %fasl

IrT = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/OR/Irish%20Taylor.csv');
IrTelev = 5540; %fasl

% --- CALIFORNIA ---
% (1) Mammoth Pass
MaPa = 'https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customMultiTimeSeriesGroupByStationReport/daily/start_of_period/MHP:CA:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false';
MaPa = readmatrix(MaPa, 'OutputType', 'string');
MPelev = 9400; %fasl

% (2) Kirkwood (Carson Pass)
Kirk= readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CA/Carson%20Pass.csv');
Kelev = 8360; %fasl

% (3) Heavenly
Heav = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CA/Heavenly%20Valley.csv');
Helev = 8540; %fasl

% (4) Palisades
Pal = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CA/Palisades%20Tahoe.csv');
Palelev = 8010; %fasl

% --- BRITTISH COLUMBIA/WASHINGTON ---
% (1) Whistler 1 (Tenquille Lake)
url = 'https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/start_of_period/1D06P:BC:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false';

% Crystal Mountain
Crystal = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/WA/Morse%20Lake.csv');
Crystalelev = 5400;

% Stevans Pass
Stevens = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/WA/Stevens%20Pass.csv');
Stevenselev = 3940;


% Mount Baker 
Baker = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/WA/Wells%20Creek.csv');
Bakerelev = 4040;

% --- Colorado ---
% (1) Steamboat
SteamB = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Dry%20Lake.csv');
SteamBelev = 8240;

% (2) A-Basin
ABasin = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Grizzly%20Peak.csv');
ABasinelev = 11110;

% (3) Vail
Vail = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Vail%20Mountain.csv');
Vailelev = 10290;

% (4) Aspen
Aspen = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Independence%20Pass.csv');
Aspenelev = 10570;

% (5) Crested Butte
Crested = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Butte.csv');
Crestedelev = 10190;

% (6) Telluride (Red Moutain Pass)
Telluride = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Red%20Mountain%20Pass.csv');
Tellurideelev = 11060;

% (7) Silverton (Molas Lake
Silverton = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Molas%20Lake.csv');
Silvertonelev = 10610;

% (8) WolfCreek
Wolf = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Wolf%20Creek%20Summit.csv');
Wolfelev = 10930;

% Use webread to fetch the data
try
    % Read the CSV data from the URL
    data = webread(url);
    
    % Convert the data into a table for easy manipulation
    % Read the data using readtable after writing to a temporary file
    tempFile = [tempname, '.csv']; % Create a temporary file name
    fid = fopen(tempFile, 'w'); % Open the file for writing
    fwrite(fid, data); % Write the data
    fclose(fid); % Close the file

    % Read the data as a table
    WhistlerData_n = readtable(tempFile);

    % Delete the temporary file
    delete(tempFile);

catch ME
    % If there is an error, display it
    fprintf('An error occurred while fetching or processing the data:\n%s\n', ME.message);
end
WhistNelev = 5476; % fasl

% (2) Whisterler West (Squamish Upper)
url = 'https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customChartReport/daily/start_of_period/3A25P:BC:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false&useLogScale=false';
% Use webread to fetch the data
try
    % Read the CSV data from the URL
    data = webread(url);
    
    % Convert the data into a table for easy manipulation
    % Read the data using readtable after writing to a temporary file
    tempFile = [tempname, '.csv']; % Create a temporary file name
    fid = fopen(tempFile, 'w'); % Open the file for writing
    fwrite(fid, data); % Write the data
    fclose(fid); % Close the file

    % Read the data as a table
    WhistlerData_w = readtable(tempFile);

    % Delete the temporary file
    delete(tempFile);

catch ME
    % If there is an error, display it
    fprintf('An error occurred while fetching or processing the data:\n%s\n', ME.message);
end
WhistWelev = 4551; % fasl


% (3) Revelstoke
url = 'https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customMultiTimeSeriesGroupByStationReport/daily/start_of_period/2A06P:BC:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false';

% Use webread to fetch the data
try
    % Read the CSV data from the URL
    data = webread(url);
    
    % Convert the data into a table for easy manipulation
    % Read the data using readtable after writing to a temporary file
    tempFile = [tempname, '.csv']; % Create a temporary file name
    fid = fopen(tempFile, 'w'); % Open the file for writing
    fwrite(fid, data); % Write the data
    fclose(fid); % Close the file

    % Read the data as a table
    RevData = readtable(tempFile);

    % Delete the temporary file
    delete(tempFile);

catch ME
    % If there is an error, display it
    fprintf('An error occurred while fetching or processing the data:\n%s\n', ME.message);
end
Revelev = 5807; % fasl

% --- IDAHO ----
% (1) Schweitzer
Schweit = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/ID/Schweitzer%20Basin.csv');
Schelev = 6090; %fasl

% --- COLORADO ---
% (1) Crested Butte
CButte = readtable('https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/CO/Butte.csv');
CBelev = 10190; %fasl;


%% UTAH FIGURE
figure('Name', 'Utah','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','UTAH','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Snowbird

D = Bird{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,1)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(SBelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Snowbird',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%-----------------------
% 2) ALTA

D = Alta{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,2)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';

% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Aelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Alta',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 3) Powder Mtn (Little Bear)

D = Powder{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,3)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(PMelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Powder Mtn (Little Bear)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 4) Solitude
D = Solitude{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Selev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Solitude',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% WYMOMING AND MONTANA FIGURE
figure('Name', 'MY-WT','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','WYOMING & MONTANA','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Jackson

D = Jackson{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,1)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Jelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Jackson',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%-----------------------
% 2) Targee

D = Targee{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,2)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';

%Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(GTelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Targee',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 3) BigSky

D = BigSky{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,3)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(BSelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Big Sky',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 4) Bridger
D = Bridger{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Belev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Bridger',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% MOUNT BACHELOR. OR
figure('Name', 'MTBACH  ','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','MOUNT BACHELOR','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Mckensize

D = Mck{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,1)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Mckelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Mckensize (NNE)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%-----------------------
% 2) Three Creek (NE of Mt Bach)

D = TCr{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,2)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';

% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(TCrelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Three Creek (NE)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 3) Roaring River (SW of Mt Bach)

D = RR{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,3)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(RRelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Roaring River (NW)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 4) Irish Taylor (SSW)
D = IrT{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(IrTelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Irish Taylor (SSW)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% CALIFORNIA
clear vars D data SWE_CurrentYr
figure('Name', 'CALI  ','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','CALIFORNIA','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Mammonth Mountain
% has formate the requires creating a day x year matrix from a col vector
% Convert the first column to datetime
MaPaDates = datetime(MaPa(35:end, 1), 'InputFormat', 'yyyy-MM-dd', 'Format', 'yyyy-MM-dd');
data = str2double(MaPa(35:end, 2)); %  data omitting date column 
MaPa = table(MaPaDates, data, 'VariableNames', {'Date', 'Value'});

% separate year, month, day 
yr=year(MaPaDates);
mon = month(MaPaDates);
dd=day(MaPaDates);

styr = min(yr);
endyr = year(today)-1;

% --- create a date vector
% Define start and end dates
startDate = datetime(styr, 10, 1); % October 1, 1990
endDate = datetime(yr(end), mon(end), dd(end));   % September 30, 2024

% Generate vector for both dates and data (d)
dateVector = (startDate:endDate)';
z = find(MaPaDates==startDate);
data = data(z:end);

% create new month yr day that starts on oct 1
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% find indices of leap years and erase them!
leap = find(mon == 2 & dd == 29);
data(leap) = [];
dateVector(leap) = [];

% create new month yr day that starts on oct 1 but doesnt include leap
% years
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% create day x year matrix for water year for all years sans current year
j = 1;
x = 1;
y = 365;
yr1 = yr(1);
for i = 1:yr(end) - yr(1) -1
    D(1,j) = yr1+1;
    D(2:366,j) = data(x:y,1);
    Dates(:,j) = dateVector(x:y,1);
    x = x + 365;
    y = y + 365;
    j = j + 1;
    yr1 = yr1 + 1;  
end

%current year
% ID of current year
id1 = find(yr==YY-1 & mon>9);
id2 = find(yr==YY & mon<10);

% vector SWE data of current year
SWE_CurrentYr = vertcat(data(id1), data(id2));

% find value of last day data was updated
CalDay = dateVector(end);

% Format the date as MM-DD
CurrentDay = datestr(CalDay, 'mmm-dd');

% Period of Record Average
POR = D(1,end)-D(1,1) + 1;
j = 1;
for i = 2:length(D)
    AvgSnoD(j,1) = nanmedian(D(i,1:POR)); %omits current year
    j = j+1;
end

% find percent of average now
PresentAnom = SWE_CurrentYr(end)/AvgSnoD(length(SWE_CurrentYr))*100;

% plot
subplot(4,1,1)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:length(SWE_CurrentYr)),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(MPelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Mammoth Pass',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% ---- 2) Kirkwood (Carson Pass) ----

D = Kirk{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,2)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Kelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Kirkwood',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -----------------------
% 3) Heavenly

D = Heav{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,3)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Helev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Heavenly',FontSize=24,Color=[236,112,20]/255)
clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% -------
% 4) Palisades

D = Pal{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';

% write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Palelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Palisades',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% BC AND IDAHO

figure('Name', 'BC-IDAHO  ','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','BC & IDAHO','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Whistler Mountain (Tenquille Lake, west)
% has formate the requires creating a day x year matrix from a col vector
% Convert the first column to datetime
Whist_n_dates = WhistlerData_n{35:end,1};
Whist_n_data = WhistlerData_n{35:end,2};
Whistle_n = table(Whist_n_dates, Whist_n_data, 'VariableNames', {'Date', 'SWE'});

% separate year, month, day 
yr=year(Whist_n_dates);
mon = month(Whist_n_dates);
dd=day(Whist_n_dates);

styr = min(yr);
endyr = year(today)-1;

% --- create a date vector
% Define start and end dates
startDate = datetime(styr, 10, 1); % October 1, 1990
endDate = datetime(yr(end), mon(end), dd(end));   % September 30, 2024

% Generate vector for both dates and data (d)
dateVector = (startDate:endDate)';
z = find(Whist_n_dates==startDate);
Whist_n_data = Whist_n_data(z:end);

% create new month yr day that starts on oct 1
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% find indices of leap years and erase them!
leap = find(mon == 2 & dd == 29);
Whist_n_data(leap) = [];
dateVector(leap) = [];

% create new month yr day that starts on oct 1 but doesnt include leap
% years
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% create day x year matrix for water year for all years sans current year
j = 1;
x = 1;
y = 365;
yr1 = yr(1);
for i = 1:yr(end) - yr(1) -1
    D(1,j) = yr1+1;
    D(2:366,j) = Whist_n_data(x:y,1);
    Dates(:,j) = dateVector(x:y,1);
    x = x + 365;
    y = y + 365;
    j = j + 1;
    yr1 = yr1 + 1;  
end

%current year
% ID of current year
id1 = find(yr==YY-1 & mon>9);
id2 = find(yr==YY & mon<10);

% vector SWE data of current year
SWE_CurrentYr = vertcat(Whist_n_data(id1), Whist_n_data(id2));

% find value of last day data was updated
CalDay = dateVector(end);

% Format the date as MM-DD
CurrentDay = datestr(CalDay, 'mmm-dd');

% Period of Record Average
POR = D(1,end)-D(1,1) + 1;
j = 1;
for i = 2:length(D)
    AvgSnoD(j,1) = nanmedian(D(i,1:POR)); %omits current year
    j = j+1;
end

% find percent of average now
PresentAnom = round(SWE_CurrentYr(end)/AvgSnoD(length(SWE_CurrentYr))*100,1);

% plot
subplot(4,1,1)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:length(SWE_CurrentYr)),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(WhistNelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Whistler (North, Tenquille Lake)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 2) Whistler Mountain (Squamish Upper, North)
% has formate the requires creating a day x year matrix from a col vector
% Convert the first column to datetime
Whist_w_dates = WhistlerData_w{35:end,1};
Whist_w_data = WhistlerData_w{35:end,2};
Whistle_w = table(Whist_w_dates, Whist_w_data, 'VariableNames', {'Date', 'SWE'});

% separate year, month, day 
yr=year(Whist_w_dates);
mon = month(Whist_w_dates);
dd=day(Whist_w_dates);

styr = min(yr);
endyr = year(today)-1;

% --- create a date vector
% Define start and end dates
startDate = datetime(styr+1, 10, 1); % October 1, 1990
endDate = datetime(yr(end), mon(end), dd(end));   % September 30, 2024

% Generate vector for both dates and data (d)
dateVector = (startDate:endDate)';
z = find(Whist_w_dates==startDate);
Whist_w_data = Whist_w_data(z:end);

% create new month yr day that starts on oct 1
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% find indices of leap years and erase them!
leap = find(mon == 2 & dd == 29);
Whist_w_data(leap) = [];
dateVector(leap) = [];

% create new month yr day that starts on oct 1 but doesnt include leap
% years
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% create day x year matrix for water year for all years sans current year
j = 1;
x = 1;
y = 365;
yr1 = yr(1);
for i = 1:yr(end) - yr(1) -1
    D(1,j) = yr1+1;
    D(2:366,j) = Whist_w_data(x:y,1);
    Dates(:,j) = dateVector(x:y,1);
    x = x + 365;
    y = y + 365;
    j = j + 1;
    yr1 = yr1 + 1;  
end

%current year
% ID of current year
id1 = find(yr==YY-1 & mon>9);
id2 = find(yr==YY & mon<10);

% vector SWE data of current year
SWE_CurrentYr = vertcat(Whist_w_data(id1), Whist_w_data(id2));

% find value of last day data was updated
CalDay = dateVector(end);

% Format the date as MM-DD
CurrentDay = datestr(CalDay, 'mmm-dd');

% Period of Record Average
POR = D(1,end)-D(1,1) + 1;
j = 1;
for i = 2:length(D)
    AvgSnoD(j,1) = nanmedian(D(i,1:POR)); %omits current year
    j = j+1;
end

% find percent of average now
PresentAnom = round(SWE_CurrentYr(end)/AvgSnoD(length(SWE_CurrentYr))*100,1);

% plot
subplot(4,1,2)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:length(SWE_CurrentYr)),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(WhistWelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Whistler (West, Squamish Upper)',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 3) Revelstoke
% has formate the requires creating a day x year matrix from a col vector
% Convert the first column to datetime
RevDates = RevData{35:end,1};
RevData = RevData{35:end,2};
Revelstoke = table(RevDates, RevData, 'VariableNames', {'Date', 'SWE'});

% separate year, month, day 
yr=year(RevDates);
mon = month(RevDates);
dd=day(RevDates);

styr = min(yr);
endyr = year(today)-1;

% --- create a date vector
% Define start and end dates
startDate = datetime(styr+1, 10, 1); % October 1, 1990
endDate = datetime(yr(end), mon(end), dd(end));   % September 30, 2024

% Generate vector for both dates and data (d)
dateVector = (startDate:endDate)';
z = find(RevDates==startDate);
RevData = RevData(z:end);

% create new month yr day that starts on oct 1
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% find indices of leap years and erase them!
leap = find(mon == 2 & dd == 29);
RevData(leap) = [];
dateVector(leap) = [];

% create new month yr day that starts on oct 1 but doesnt include leap
% years
yr=year(dateVector);
mon = month(dateVector);
dd=day(dateVector);

% create day x year matrix for water year for all years sans current year
j = 1;
x = 1;
y = 365;
yr1 = yr(1);
for i = 1:yr(end) - yr(1) -1
    D(1,j) = yr1+1;
    D(2:366,j) = RevData(x:y,1);
    Dates(:,j) = dateVector(x:y,1);
    x = x + 365;
    y = y + 365;
    j = j + 1;
    yr1 = yr1 + 1;  
end

%current year
% ID of current year
id1 = find(yr==YY-1 & mon>9);
id2 = find(yr==YY & mon<10);

% vector SWE data of current year
SWE_CurrentYr = vertcat(RevData(id1), RevData(id2));

% find value of last day data was updated
CalDay = dateVector(end);

% Format the date as MM-DD
CurrentDay = datestr(CalDay, 'mmm-dd');

% Period of Record Average
POR = D(1,end)-D(1,1) + 1;
j = 1;
for i = 2:length(D)
    AvgSnoD(j,1) = nanmedian(D(i,1:POR)); %omits current year
    j = j+1;
end

% find percent of average now
PresentAnom = round(SWE_CurrentYr(end)/AvgSnoD(length(SWE_CurrentYr))*100,1);

% plot
subplot(4,1,3)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:length(SWE_CurrentYr)),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Revelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Revelstoke',FontSize=24,Color=[236,112,20]/255)
clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% --- (4) Schweitzer
% 1) Snowbird

D = Schweit{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    AvgSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./AvgSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(AvgSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
% write text on fig
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Schelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Schweitzer',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% Colorado (North-Central)
figure('Name', 'Colorado (north-central)','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','Colorado (north-central)','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Steamboat

D = SteamB{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,1)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(SteamBelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Steamboat',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 2) A-Basin

D = ABasin{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,2)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(ABasinelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('A-Basin',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 3) Vail

D = Vail{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,3)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Vailelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Vail',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 4) Aspen

D = Aspen{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Aspenelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Aspen',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% Colorado (South-Central)
figure('Name', 'Colorado (South-Central)','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','Colorado (South-Central)','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Crested Butte

D = Crested{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,1)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Crestedelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Crested Butte',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 2) Telluride

D = Telluride{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,2)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Tellurideelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Telluride',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 3) Silverton

D = Silverton{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,3)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Silvertonelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Silverton',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 4) Wolf Creek

D = Wolf{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(4,1,4)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Wolfelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Wolf Creek',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

%% Washington
figure('Name', 'Washington','position',[100 100 800 1000]);
clf
annotation('textbox',[x1 y1 w h],'String','Washington','EdgeColor','none','FontSize',24,'Color',[102,37,6]/255,'FontWeight','bold')

% ---------------------
% 1) Crystal Mountain

D = Crystal{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(3,1,1)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Crystalelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Crystal Mountain',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 2) Stevens Pass

D = Stevens{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(3,1,2)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Stevenselev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Stevens Pass',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly

% 3) Mount Baker

D = Baker{:,2:end};          % new matrix omitting date column               
styr =  min(D(1,:));        % first year of record
endyr = max(D(1,:));        % last year of record
POR = endyr - styr + 1;
id = D(1,:)==2025;

% ID of current year
id = D(1,:)==YY;

% vector SWE data of current year
SWE_CurrentYr = D(2:end,id);

% find value to report of last day data was updated
z = isnan(SWE_CurrentYr);
i_cd = find(z==1)-1; 
CalDay = Datevec(i_cd(1)); % Define variable representing calendar day of yr
CalDay = CalDay(end);

% Convert the day of the year to a datetime object
date = datetime(YY, 1, 1) + days(CalDay - 1); % Assuming the year is 2024

% Format the date as MM-DD
CurrentDay = datestr(date, 'mmm-dd');

if length(SWE_CurrentYr) == 365
    JulianDay = vertcat((274:365)',(1:273)'); % julian day vector starting Oct 1
else
    JulianDay = vertcat((274:366)',(1:273)'); % julian day vector starting Oct 1
end

% Period of Record Average
for i = 1:length(JulianDay)
    MedSnoD(i,1) = nanmedian(D(1+i,1:POR-1)); %omits current year
end

anomaly = SWE_CurrentYr./MedSnoD*100;

% find percent of average now
PresentAnom = round(anomaly(i_cd(1)),1);

% plot
subplot(3,1,3)
area(MedSnoD,'FaceColor',[222,235,247]/255)
hold on
plot((1:366),SWE_CurrentYr,'LineWidth',6,'Color',[33,113,181]/255)
ylabel('SWE (inches)','FontSize',14)
xlim([-5,371])

ax = gca;
p = ax.YLim(2);
ax.XGrid = 'on';
ax.YGrid = 'on';
% Write text on figure
text(10,p-.25*p,[num2str(PresentAnom) '%'],'FontSize',18)
text(10,p-.35*p,'of median SWE','FontSize',12)
text(310,p-.25*p,['POR = ' num2str(POR) ' yrs'],'FontSize',12)
text(310,p-.34*p,['Elev. = ' num2str(Bakerelev) ' ft'],'FontSize',12)
text(310,p-.44*p,['Updated: ' CurrentDay],'FontSize',12)

xticks([1,32,62,93,124,152,183,213,244,274,305,336,366])
xticklabels({'Oct1','Nov1','Dec1','Jan1','Feb1','Mar1','Apr1','May1','Jun1','Jul1','Aug1','Sep1','Sep30'})
title('Mount Baker',FontSize=24,Color=[236,112,20]/255)

clear vars D data date d i i_cd fid SWE_CurrentYr url z PresentAnom anomaly
