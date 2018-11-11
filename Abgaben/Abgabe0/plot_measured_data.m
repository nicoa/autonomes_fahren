addpath '~/git/Car_Pi_MUM/MATLAB/'
addpath '~/git/Car_Pi_MUM/MATLAB/Simulationsumgebung/'
addpath '~/git/Car_Pi_MUM/MATLAB/Steuerung/'

load('loc_data.mat')
load('pos_car_simulation.mat')
load('track.mat')

track_plot  % load median data
close(gcf)

set(0,'defaulttextInterpreter','Latex')

% location_data = simout;
y = median_y;
x = median_x;
xx = -y_pos_car.Data;
yy = x_pos_car.Data;
%xx = -location_data.Data(:, 2);
%yy = location_data.Data(:, 1);
x_interp = interp1(linspace(1,length(xx)*50,length(x)), x, 1:length(xx)*50+1, 'spline');
y_interp = interp1(linspace(1,length(yy)*50,length(y)), y, 1:length(yy)*50+1, 'spline');
time = y_pos_car.Time;
%time = location_data.Time;
errors = calculate_dists(xx, x_interp, yy, y_interp);



figure('Position', [5 5 1100 600])
subplot(2, 7,[1 2 8 9])
whitebg([0, 0, 0] + 0.85)
p1 = plot([x, x(1:10)], [y, y(1:10)], '-', 'Color', [0, 0, 0] + 0.8, 'Linewidth', 4);
hold on
p2 = plot(xx,yy,'-.', 'Linewidth', 1, 'Color', [0, 0, 0] + 0.1, 'Linewidth', 1, 'MarkerSize', 0.01);
xlabel('$x(t)$')
ylabel('$y(t)$')
axis('equal')
xlim(xlim + [-10 70])
ylim(ylim + [-10 10])

time_markers = 10;
for t=0:time_markers - 1
    i = t*floor(length(time)/time_markers);
    plot(xx(i+1), yy(i+1), 'ko-', 'MarkerSize', 6)
    tx = xx(i+1) +  10;
    ty = yy(i+1) - 10;% sign(yy(i+1))* 10;
    text(tx, ty, sprintf("$t\\approx %2.fs$", time(i+1)))
end
lgd = legend([p1, p2], {'Mittelline der Fahrspur (verbreitert)', 'Schwerpunktslage des Fahrzeugs'});
title(lgd, 'legend title')
lgd.Box = 'off';
title('Diagramm 1: Fahrtverlauf')
adjust_axis(gca);


subplot(2,7,[3 4 5 6 7])
plot(time, errors, 'k-')
title({'Diagramm 2: Fehler $\epsilon$ (der Schwerpunktlage $\hat{f}$ zur Mittellinie $f$):';...
    '$\epsilon(t) = \inf_{\bar{t}\in T} {\Vert \hat{f}(t) - f\left(\bar{t}\right)\Vert}_{\infty}$'})
xlabel('$t$')
ylabel('$\epsilon (t)$')
adjust_axis(gca);

subplot(2,7,[10 11 12 13 14])
plot(time, 1./errors, 'k-')
lgd.Box = 'off';
xlabel('$t$')
ylabel('$\frac{1}{\epsilon (t)}$')
title('Diagramm 3: Reziproker Fehler - groe\\ssere Werte sind besser')
adjust_axis(gca)

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,'ex01_measured_track.pdf','-dpdf')
close(fig)


function adjust_axis(ax)
    outerpos = ax.OuterPosition;
    ti = ax.TightInset*1.2;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    set(ax,'box','off')
end

function [errors] = calculate_dists(xvals_points, xvals_set, yvals_points, yvals_set)
    errors = zeros(1, length(xvals_points));
    for k=1:length(xvals_points)
        errors(k) = dist2set(xvals_points(k), yvals_points(k), xvals_set, yvals_set);
    end
end

function [epsilon] = dist2set(point_x, point_y, set_x, set_y)
    epsilon = min(sqrt((set_x-point_x).^2 + (set_y-point_y).^2));
end
