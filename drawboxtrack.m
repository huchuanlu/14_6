function param = drawboxtrack(p)
% function drawbox(width,height, param, properties)
%                 ([width,height], param, properties)
%----------------------------------------------------------
% Draw the box.
%----------------------------------------------------------
w = p(4)-p(2); h=p(5)-p(3);
center(1) = (p(2)+p(4))/2;
center(2) = (p(3)+p(5))/2;
leftx = p(2);
lefty = p(3);
corners = [leftx leftx+w leftx+w leftx   leftx;
           lefty lefty   lefty+h lefty+h lefty];
line(corners(1,:), corners(2,:), 'Color','r', 'LineStyle','-', 'LineWidth',2);      %%画顶点连线
param = [w, h, center(1), center(2)];
hold_was_on = ishold; hold on;
% plot(center(1),center(2),'Color','r', 'LineWidth',2.5);              %%画中心点
% if (~hold_was_on) hold off; end
