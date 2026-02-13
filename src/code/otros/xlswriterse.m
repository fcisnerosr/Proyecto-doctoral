% xlswriteRSE user


function xlswriterse(file,data,sheet,range)

%file = 'D:\Applications\MATLAB701\work\example.xls'; % This must be full path name
% Open Excel Automation server
Excel = actxserver('Excel.Application');
Workbooks = Excel.Workbooks;
% Make Excel no visible
Excel.Visible=0;
% Open Excel file
Workbook=Workbooks.Open(file);
% Specify sheet number, data, and range to write to 
sheetnum=sheet;
%data=rand(4);  % use a cell array if you want both numeric and text data
%range = 'F10:I13';
% Make the first sheet active
Sheets = Excel.ActiveWorkBook.Sheets;
sheet1 = get(Sheets, 'Item', sheetnum);
invoke(sheet1, 'Activate');
Activesheet = Excel.Activesheet;
% Put MATLAB data into Excel
ActivesheetRange = get(Activesheet,'Range',range);
set(ActivesheetRange, 'Value', data);
% Here you might manipulate the data in Excel
% Now read the data from the sheet; you could specify a new range here
%Range = get(Activesheet,'Range',range);
%out = Range.value;
% Save file
invoke(Workbook,'Save')
% Close Excel and clean up
invoke(Excel,'Quit');
delete(Excel);
clear Excel;