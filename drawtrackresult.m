function drawopt = drawtrackresult(drawopt, fno, frame, param)

if (isempty(drawopt))      
  h = figure('Visible','off','position',[30 50 size(frame,2) size(frame,1)]); clf;   
%     figure('position',[30 50 80 100]); clf;          
  set(gcf,'DoubleBuffer','on','MenuBar','none');
  colormap('gray');

  drawopt.curaxis = [];
  drawopt.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end

curaxis = drawopt.curaxis;
axes(curaxis.frm);      
imagesc(frame, [0,1]); 
% imagesc(frame(param.est(1)-49:param.est(1)+50,param.est(2)-39:param.est(2)+40), [0,1]);
hold on;     

sz = size(param.wimg);  
p = drawbox(sz, param.est, 'Color','r', 'LineWidth',4);
% param = drawboxtrack(param);
% text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
text(30, 15, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',24);

hold off;
drawnow;      

