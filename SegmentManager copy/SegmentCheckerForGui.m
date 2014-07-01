function SegmentCheckerForGui(S, h)
[S.lon1, S.lat1, S.lon2, S.lat2] = order_lon_lat_pairs(S.lon1, S.lat1, S.lon2, S.lat2);
h = flipud(h);

% delete previous legend objects
%delete(
leg = zeros(5, 1); leginc = 1; legflag = leg;
leglab = {'Horiz./Vert.', 'Same coords. (reg.)', 'Same coords. (rev.)', 'Intersection', 'Hanging point'};

% Check the lengths and azimuths of segments 
rvec = zeros(numel(S.lat1), 1);
avec = rvec;
for i = 1:numel(S.lon1)
   [rng az] = distance(S.lat1(i), S.lon1(i), S.lat2(i), S.lon2(i), 'degrees');
   avec(i) = az;
   rvec(i) = 6371*deg2rad(rng);
   
   if (avec(i) == 180)
      sprintf('%d is horizontal, ', i, avec(i));
   end
   if (rvec(i) == 0)
      sprintf('%d has %f length, ', i, rvec(i));
   end
end

% Show vertical segments
hvec = union(find(avec == 0), find(avec == 180));
set(h(hvec), 'color', 'r');

% Show horizontal segments
hvec = union(find(avec == 90), find(avec == 270));
set(h(hvec), 'color', 'r');

hv = findobj('color', 'r', 'marker', 'none');
if ~isempty(hv)
	hv = line(0, 0, 'color', 'r', 'visible', 'off');
	leg(leginc) = hv(1);
	legflag(1) = 1;
	leginc = leginc+1;
end

% Check for duplicates with same ordering
for i = 1:numel(S.lon1)-1
	j = i+1:numel(S.lon1);
	lonMatch1 = repmat(S.lon1(i), numel(j), 1) - S.lon1(j)';
	lonMatch2 = repmat(S.lon2(i), numel(j), 1) - S.lon2(j)';
	latMatch1 = repmat(S.lat1(i), numel(j), 1) - S.lat1(j)';
	latMatch2 = repmat(S.lat2(i), numel(j), 1) - S.lat2(j)';

	j = j(intersect(find(lonMatch1 == 0), find(lonMatch2 == 0)));
	if ~isempty(j)
%		disp('same coords - longitude - same ordering')        
		set(h(i), 'marker', '>', 'color', [0.5 0 0.5]);
		set(h(j), 'marker', '>', 'color', [0.5 0 0.5]);
	end
	
	j = j(intersect(find(latMatch1 == 0), find(latMatch2 == 0)));
	if ~isempty(j)
%		disp('same coords - latitude - same ordering')        
		set(h(i), 'marker', '^', 'color', [0.5 0 0.5]);
		set(h(j), 'marker', '^', 'color', [0.5 0 0.5]);
	end
end

sor = setdiff(findobj('color', [0.5 0 0.5]), leg);
if ~isempty(sor)
	sor = line(0, 0, 'color', [0.5 0 0.5], 'visible', 'off');
	leg(leginc) = sor(1);
	legflag(2) = 1;
	leginc = leginc+1;
end

% Check for duplicates with opposite ordering
for i = 1:numel(S.lon1)-1
	j = i+1:numel(S.lon1);
	lonMatch1 = repmat(S.lon1(i), numel(j), 1) - S.lon2(j)';
	lonMatch2 = repmat(S.lon2(i), numel(j), 1) - S.lon1(j)';
	latMatch1 = repmat(S.lat1(i), numel(j), 1) - S.lat2(j)';
	latMatch2 = repmat(S.lat2(i), numel(j), 1) - S.lat1(j)';

	j = j(intersect(find(lonMatch1 == 0), find(lonMatch2 == 0)));
	if ~isempty(j)
%		disp('same coords - longitude - opposite ordering')        
		set(h(i), 'marker', '<', 'color', 'c');
		set(h(j), 'marker', '<', 'color', 'c');
	end
	
	if ~isempty(j)
		j = j(intersect(find(latMatch1 == 0), find(latMatch2 == 0)));
%		disp('same coords - latitude - opposite ordering')        
		set(h(i), 'marker', 'v', 'color', 'c');
		set(h(j), 'marker', 'v', 'color', 'c');
	end
end

ror = setdiff(findobj('color', 'c'), leg);
if ~isempty(ror)
	ror = line(0, 0, 'color', 'c', 'visible', 'off');
	leg(leginc) = ror(1);
	legflag(3) = 1;
	leginc = leginc+1;
end

%% Check for overlaps that are not intersections
for i = 1:numel(S.lon1)-1;
   j = i+1:numel(S.lon1);
	p1 = repmat([S.lon1(i) S.lat1(i)], numel(j), 1);
	p2 = repmat([S.lon2(i) S.lat2(i)], numel(j), 1);
	p3 = [S.lon1(j)' S.lat1(j)'];
	p4 = [S.lon2(j)' S.lat2(j)'];
	[xi,yi] = pbisect(p1, p2, p3, p4);
	
	ci = [xi, yi]; % intesection coordinate array
	realc = find(sum(isnan(ci), 2) == 0);
	[isect, reali] = setdiff(ci(realc, :), [p1(1, :); p2(1, :)], 'rows');
	if ~isempty(reali) % if there's a real intersection...
		j = j(realc(reali)); % identify its index
         set(h(i), 'marker', 'x', 'color', 'm');
         set(h(j), 'marker', 'x', 'color', 'm');
	end
end

ise = setdiff(findobj('color', 'm'), leg);
if ~isempty(ise)
	ise = line(0, 0, 'color', 'm', 'visible', 'off');
	leg(leginc) = ise(1);
	legflag(4) = 1;
	leginc = leginc+1;
end

% Find unique points
lonVec = [S.lon1'; S.lon2'];
latVec = [S.lat1'; S.lat2'];
[uCoord1 uIdx1] = unique([lonVec latVec], 'rows', 'first');
[uCoord2 uIdx2] = unique([lonVec latVec], 'rows', 'last');
nOccur = uIdx2-uIdx1 + 1;

hang = plot(uCoord1(find(nOccur == 1), 1), uCoord1(find(nOccur == 1), 2), '.r', 'tag', 'hang');
if ~isempty(hang)
	hangm = line(0, 0, 'marker', '.', 'color', 'r', 'linestyle', 'none', 'visible', 'off');
	leg(leginc) = hangm(1);
	legflag(5) = 1;
end

% Place legend
if sum(find(leg)) > 0;
	legs = legend(leg(find(leg)), leglab(find(legflag)), 'location', 'southeast');
	setappdata(gcf, 'checklegend', legs);
	delete(leg(find(leg)));
else
	msgbox('All segments are okay.')
end

function [xi,yi] = pbisect(p1,p2,p3,p4);
%
% [XI,YI] = PBISECT(P1,P2,P3,P4) gives (XI,YI) coordinates of the intersection
% between line segments described by the (X,Y) pairs contained in P1, P2, P3,
% and P4.  P1-P4 should be of the form [x y], of size n-by-2.  The function 
% returns NaN values for xi and yi if the two segments do not intersect.  The
% outputs XI and YI are each n-by-1.
%
% The solution is as described by Paul Bourke.
%

ua = ((p4(:, 1)-p3(:, 1)).*(p1(:, 2)-p3(:, 2)) - (p4(:, 2)-p3(:, 2)).*(p1(:, 1)-p3(:, 1)))./ ...
     ((p4(:, 2)-p3(:, 2)).*(p2(:, 1)-p1(:, 1)) - (p4(:, 1)-p3(:, 1)).*(p2(:, 2)-p1(:, 2)));
ub = ((p2(:, 1)-p1(:, 1)).*(p1(:, 2)-p3(:, 2)) - (p2(:, 2)-p1(:, 2)).*(p1(:, 1)-p3(:, 1)))./ ...
	  ((p4(:, 2)-p3(:, 2)).*(p2(:, 1)-p1(:, 1)) - (p4(:, 1)-p3(:, 1)).*(p2(:, 2)-p1(:, 2)));

xi = nan(size(p1, 1), 1); % assign NaNs by default
yi = xi;
is = find(ub >= 0 & ub <= 1 & ua >=0 & ua <= 1); % check for intersections
if ~isempty(is) % if there are any intersections, calculate them here.
	xi(is) = p3(is, 1) + ub(is).*(p4(is, 1)-p3(is, 1));
	yi(is) = p3(is, 2) + ub(is).*(p4(is, 2)-p3(is, 2));
end

% check to see whether or not the calculated intersection is actually an endpoint 
% (but potentially different by machine precision)
d1 = find(sum(p1 - p3, 2) == 0);
d2 = find(sum(p1 - p4, 2) == 0);
endpoints = unique([d1; d2]);
if ~isempty(endpoints)
	xi(endpoints) = p1(endpoints, 1);
	yi(endpoints) = p1(endpoints, 2);
end
d1 = find(sum(p2 - p3, 2) == 0); 
d2 = find(sum(p2 - p4, 2) == 0);
endpoints = unique([d1; d2]);
if ~isempty(endpoints)
	xi(endpoints) = p2(endpoints, 1);
	yi(endpoints) = p2(endpoints, 2);
end