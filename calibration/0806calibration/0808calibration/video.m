


vid = videoinput('gige',1)
vid.SelectedSourceName = 'input1';
scr_obj = getselectedsource(vid);

get(scr_obj)

vid.TriggerRepeat = Inf;
src_obj.Exposure = 100000;
figure;
start(vid)
frame = getsnapshot(vid);
image(frame);



preview(vid)