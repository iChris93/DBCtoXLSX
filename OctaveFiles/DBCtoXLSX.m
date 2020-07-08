%Program to convert DBC file to xlsx
%Chris Allemang July 7 2020
%Requires comFramework, dbcParserForOctave.stg, dbcParser.m, hexID.m

clear
list = dbcParser('Model3CAN.dbc', 'CAN') %input DBC file name is defined
listLength = length (list.frameAry); %get number of messages
VehicleBusData = cell(listLength,9);
ChassisBusData = cell(listLength,9);
jj=1;
jj2=1;
kk=1;
kk2=1;
for i = 1:listLength
  messageName = list.frameAry(i).name;
  messageID = hexID(list.frameAry(i).id);
  messageStartBit = 0;
  if(list.frameAry(i).bus == 'VehicleBus')
  for k = 1:length(list.frameAry(i).signalAry);
    messageStartBit(k)=list.frameAry(i).signalAry(k).startBit;
    messageLength(k)=list.frameAry(i).signalAry(k).length;
    VehicleBusData(jj,1) = messageName;
    VehicleBusData(jj,2) = messageID;
    VehicleBusData(jj,4) = list.frameAry(i).signalAry(k).name;
    VehicleBusData(jj,5) = messageStartBit(k);
    VehicleBusData(jj,6) = messageLength(k);
    VehicleBusData(jj,7) = list.frameAry(i).signalAry(k).factor;
    VehicleBusData(jj,8) = list.frameAry(i).signalAry(k).offset;
    VehicleBusData(jj,9) = list.frameAry(i).signalAry(k).unit;
    jj=jj+1;
  endfor
  [maxStartBit, maxStartBitLoc] = max(messageStartBit);
  messageLength = round((maxStartBit+messageLength(maxStartBitLoc))/8);
  for k = 1:length(list.frameAry(i).signalAry);
    VehicleBusData(kk,3)=messageLength;
    kk=kk+1;
  endfor
  elseif(list.frameAry(i).bus == 'ChassisBus')
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
end
pkg load io
pkg load windows
file_name='DBCtoCSV2.xlsx'; 
xls=xlsopen(file_name,1); 
[xls, status] = oct2xls (VehicleBusData,  xls, 'VehicleBus');
[xls, status] = oct2xls (ChassisBusData,  xls, 'ChassisBus');
xls = xlsclose (xls); %close file 
