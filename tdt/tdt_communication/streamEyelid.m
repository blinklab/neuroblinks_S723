function streamEyelid(hObject, handles)
% updaterate=0.033;   % 30 Hz
updaterate=0.020;   % 50 Hz
% updaterate=0.1;   % 10 Hz

% Load objects from root app data
TDT=getappdata(0,'tdt');
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');

try
    while get(handles.togglebutton_stream,'Value') == 1
        tic
        wholeframe=getsnapshot(vidobj);
        % roi=wholeframe(handles.y1:handles.y2,handles.x1:handles.x2);
        % Had to revise this to work with elliptical ROI
        roi=wholeframe.*uint8(metadata.cam.mask);
        eyelidpos=sum(roi(:)>=256*metadata.cam.thresh);
        TDT.SetTargetVal('ustim.EyeVid',(eyelidpos-metadata.cam.calib_offset)/metadata.cam.calib_scale);
        %     TDT.SetTargetVal('Stim.EyeVid',sum(sum(im2bw(roi,metadata.cam.thresh))));
        
        % --- check Trigger from TDT (if OK, this sends trigger to TDT) ----
        if get(handles.toggle_continuous,'Value') == 1
            if TDT.GetTargetVal('ustim.EyeReady'),
                TriggerStim(hObject, handles)
            end
        end
        
        t=toc;
        % -- pause in the left time -----
        d=updaterate-t;
        if d>0
            pause(d)        %   java.lang.Thread.sleep(d*1000);     %     drawnow
        else
            disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
        end
    end
    while get(handles.togglebutton_stream,'Value') == 1
            try % If it's a dropped frame, see if we can recover
                %         handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
                metadata=getappdata(0,'metadata');
                imx=metadata.cam.vidobj_ROIposition(1)+[1:metadata.cam.vidobj_ROIposition(3)];
                imy=metadata.cam.vidobj_ROIposition(2)+[1:metadata.cam.vidobj_ROIposition(4)];
                handles.pwin=image(imx,imy,zeros(metadata.cam.vidobj_ROIposition([4 3])), 'Parent',handles.cameraAx);
                
                pause(0.5)
                closepreview(vidobj);
                pause(0.2)
                preview(vidobj,handles.pwin);
                guidata(hObject,handles)
                streamEyelid(hObject, handles)
                disp('Caught camera error')
            catch
                disp('Aborted eye streaming.')
                set(handles.togglebutton_stream,'Value',0);
                return
            end
    end
end





% function streameyelid(handles)
% 
% updaterate=0.01;   % ~100 Hz
% 
% % Load objects from root app data
% TDT=getappdata(0,'tdt');
% src=getappdata(0,'src');
% vidobj=getappdata(0,'vidobj');
% metadata=getappdata(0,'metadata');
% 
% % d=1./500; % 2 ms timer
% d=updaterate;
% 
% try
% while get(handles.togglebutton_stream,'Value') == 1
%     
%     tic
%     wholeframe=getsnapshot(vidobj);
%     roi=wholeframe(handles.y1:handles.y2,handles.x1:handles.x2);
% %     binframe=im2bw(roi,metadata.thresh);
% %     eyelidpos=sum(sum(im2bw(roi,metadata.thresh)));
%     
% %     TDT.SetTargetVal('Stim.EyeVid',eyelidpos);
%     TDT.SetTargetVal('Stim.EyeVid',sum(sum(im2bw(roi,metadata.cam.thresh))));
%     t=toc;
%     
%     java.lang.Thread.sleep(d*1000);  % Note: sleep() accepts [mSecs] duration
%     drawnow
%     
%     if t>d
%         disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
%     end
%     
% %     d=updaterate-t;
% %     if d>0
% %         java.lang.Thread.sleep(d*1000);  % Note: sleep() accepts [mSecs] duration
% %         drawnow
% %     else
% %         disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
% %     end
% end
% catch
%     disp('Aborted eye streaming.')
%     return
% end

%-------- From Selmaan's program ---------%

% function streameyelid(handles)
% 
% global TDT metadata src vidobj
% 
% frames_per_trial=metadata.FPS.*metadata.T_length;
% TDT.SetTargetVal('ustim.FramePulse',1e3/(2*metadata.FPS));
% TDT.SetTargetVal('ustim.NumFrames',frames_per_trial);
% 
% vidobj.StopFcn=@AdvanceTrial;
% PauseDur=1/metadata.FPS+.0005;
% frame=1; updateFrame=metadata.FPS/str2double(get(handles.edit_UpdateRate,'String'));
% % try
%     while get(handles.togglebutton_stream,'Value') == 1
%         
%         wholeframe=getsnapshot(vidobj);
%         TDT.SetTargetVal('ustim.EyeVid',sum(sum(im2bw(wholeframe(handles.y1:handles.y2,handles.x1:handles.x2),metadata.thresh))));
%         if TDT.GetTargetVal('ustim.MatOK')==1
%             start(vidobj),TDT.SetTargetVal('ustim.ForceStart',1);
%         end
%         Pauser(PauseDur);
%         
%         if frame>updateFrame
%             drawnow
%             frame=1;
%         else
%             frame=frame+1;
%         end
%     end
