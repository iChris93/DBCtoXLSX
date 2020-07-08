%Program to convert DBC file to xlsx
%Chris Allemang July 7 2020
%Requires comFramework, dbcParserForOctave.stg, dbcParser.m, hexID.m

clear
list = dbcParser('Model3CAN.dbc', 'CAN') %input DBC file name is defined
listLength = length (list.frameAry); %get number of messages
VehicleBusData = cell(listLength,9); %initialize cell for storing data
ChassisBusData = cell(listLength,9);
jj=1; %start a counter
jj2=1;
kk=1;
kk2=1;
for i = 1:listLength %for every message
  messageName = list.frameAry(i).name; %get the message name
  messageID = hexID(list.frameAry(i).id); %get the messsage ID
  messageStartBit = 0; %reset message starting bit to 0
  if(list.frameAry(i).bus == 'VehicleBus') %if this is a Vehicle Bus message
  for k = 1:length(list.frameAry(i).signalAry); %for every signal in a message
    messageStartBit(k)=list.frameAry(i).signalAry(k).startBit; %get the signal starting bit
    messageLength(k)=list.frameAry(i).signalAry(k).length; %get the signal bit length
    VehicleBusData(jj,1) = messageName; %set column 1 to the message name
    VehicleBusData(jj,2) = messageID; %set column 2 to the message  ID
    VehicleBusData(jj,4) = list.frameAry(i).signalAry(k).name; %set column 4 to the signal name
    VehicleBusData(jj,5) = messageStartBit(k); %set column 5 to the signal starting bit
    VehicleBusData(jj,6) = messageLength(k); %set column 6 to the signal  length
    VehicleBusData(jj,7) = list.frameAry(i).signalAry(k).factor; %set column 7 to the signal factor
    VehicleBusData(jj,8) = list.frameAry(i).signalAry(k).offset; %set column 8 to the signal offst
    VehicleBusData(jj,9) = list.frameAry(i).signalAry(k).unit; %set column 9 to the signal unit
    jj=jj+1; %count
  endfor
  [maxStartBit, maxStartBitLoc] = max(messageStartBit); %extract maximum start bit value and location
  messageLength = round((maxStartBit+messageLength(maxStartBitLoc))/8); %add maximum start bit and length of that signal and round to nearest byte to find message length
  for k = 1:length(list.frameAry(i).signalAry); %for every signal
    VehicleBusData(kk,3)=messageLength; %set the message length 
    kk=kk+1; %count
  endfor
  elseif(list.frameAry(i).bus == 'ChassisBus') %do the same for the ChassisBus
  for k = 1:length(list.frameAry(i).signalAry);
    messageStartBit(k)=list.frameAry(i).signalAry(k).startBit;
    messageLength(k)=list.frameAry(i).signalAry(k).length;
    ChassisBusData(jj2,1) = messageName;
    ChassisBusData(jj2,2) = messageID;
    ChassisBusData(jj2,4) = list.frameAry(i).signalAry(k).name;
    ChassisBusData(jj2,5) = messageStartBit(k);
    ChassisBusData(jj2,6) = messageLength(k);
    ChassisBusData(jj2,7) = list.frameAry(i).signalAry(k).factor;
    ChassisBusData(jj2,8) = list.frameAry(i).signalAry(k).offset;
    ChassisBusData(jj2,9) = list.frameAry(i).signalAry(k).unit;
    jj2=jj2+1;
  endfor
  [maxStartBit, maxStartBitLoc] = max(messageStartBit);
  messageLength = round((maxStartBit+messageLength(maxStartBitLoc))/8);
  for k = 1:length(list.frameAry(i).signalAry);
    ChassisBusData(kk2,3)=messageLength;
    kk2=kk2+1;
  endfor
endif
end.%load packages needed for output file
pkg load io
pkg load windows
file_name='DBCtoCSV2.xlsx'; %set output file name
xls=xlsopen(file_name,1);  %open file
[xls, status] = oct2xls (VehicleBusData,  xls, 'VehicleBus'); %save the Vehicle Bus data to the Vechile Bus sheet
[xls, status] = oct2xls (ChassisBusData,  xls, 'ChassisBus'); %now do that for the Chassis Bus
xls = xlsclose (xls); %close file 
