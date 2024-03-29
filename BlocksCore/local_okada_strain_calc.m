function [nee, nnn, nuu, nen, neu, nnu] = local_okada_strain_calc(flong1, flat1, flong2, flat2, long, lat, z, fdip, fld, fss, fds, fts, nu, fbd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                  %%
%%  local_okada_calc.m                              %%
%%                                                  %%
%%  This function calculates surface displacements  %%
%%  from an a buried Volterra (Okada, 1985)         %%
%%  dislocation.  The Okada calculation is          %%
%%  traditional but really nice part is that this   %%
%%  set of functions does a map projection local    %%
%%  to the trace of the fault.  This minimized      %%
%%  distortion due to larger scale projections.     %%
%%  Approximate enu components of displacements     %%
%%  are returned.  This allows for speedy           %%
%%  comparisons with measured displacements.        %%
%%                                                  %%
%%  The Okada takes one additional parameter then   %%
%%  does the common implementation.  Poisson's      %%
%%  ratio is passed and converted to what I've      %%
%%  taken to calling the Okada ratio.               %%
%%                                                  %%
%%  The map projection stuff requires the MATLAB    %%
%%  mapping toolbox                                 %%
%%                                                  %%
%%  Arguments:                                      %%
%%    flong1:  Longitude of fault endpoint one      %%
%%             [degrees]                            %%
%%    flat1:   Latitude of fault endpoint one       %%
%%             [degrees]                            %%
%%    flong2:  Longtiude of fault endpoint two      %%
%%             [degrees]                            %%
%%    flat2:   Latitude of fault endpoint two       %%
%%             [degrees]                            %%
%%    long:    station longitudes                   %%
%%             [degrees]                            %%
%%    lat:     station latitudes                    %%
%%             [degrees]                            %%
%%    fdip:    fault dip                            %%
%%             [degrees]                            %%
%%    fld:     fault locking depth [km]             %%
%%    fss:     strike slip component of slip        %%
%%    fds:     dip slip component of slip           %%
%%    fts:     tensile slip component of slip       %%
%%    nu:      Poisson's ratio                      %%
%%    fbd:     fault burial depth                   %%
%%                                                  %%
%%  Returned variables:                             %%
%%    nue:  east displacement                       %%
%%    nun:  north displacement                      %%
%%    nuu:  up displacement                         %%
%%                                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Convert everything into radians  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flong1                        = deg_to_rad(flong1);
flat1                         = deg_to_rad(flat1);
flong2                        = deg_to_rad(flong2);
flat2                         = deg_to_rad(flat2);
long                          = deg_to_rad(long);
lat                           = deg_to_rad(lat);
fdip                          = deg_to_rad(fdip);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do a local projection to flat space using an oblique Mercator projection  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bx1, by1, bx2, by2, bx, by, baz]    = get_local_xy_coords_om_matlab(flong1, flat1, flong2, flat2, long, lat);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Get Okada style fault parameters  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[strike, L, W, ofx, ofy, ofxe, ofye, ...
               tfx, tfy, tfxe, tfye] = fault_params_to_okada_form(bx1, by1, bx2, by2, fdip, fld, fbd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do deformation calculation  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[xx, yy, zz, xy, xz, yz]             = okada_strain(ofx, ofy, strike, fld, fdip, L, W, fss, fds, fts, bx, by, z, nu);
%if fss == 1
%   [~, ~, ~, ~, e] = Okada1992(bx, by, z, [bx1 by1; bx2 by2], fdip, [fbd -fld], -1, 'S', 3e10, 0.25);
%end
%if fds == 1
%   [~, ~, ~, ~, e] = Okada1992(bx, by, z, [bx1 by1; bx2 by2], fdip, [fbd -fld], -1, 'D', 3e10, 0.25);
%end
%if fts == 1
%   [~, ~, ~, ~, e] = Okada1992(bx, by, z, [bx1 by1; bx2 by2], fdip, [fbd -fld], -1, 'T', 3e10, 0.25);
%end
%xx = e(:, 1, 1);
%yy = e(:, 2, 2);
%zz = e(:, 3, 3);
%xy = e(:, 1, 2);
%xz = e(:, 1, 3);
%yz = e(:, 2, 3);
%[nee, nnn, nuu, nen, neu, nnu]             = okada_strain(ofx, ofy, strike, fld, fdip, L, W, fss, fds, fts, bx, by, z, nu);
% [ux, uy, uz]                         = okada_disloc(ofx, ofy, strike, fld, fdip, L, W, fss, fds, fts, bx, by, nu);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Try a call to the function version of the angle correction routine  %%
%%%  This is not neccesary with a Mercator projection as it is           %%
%%%  conformal                                                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  [tux, tuy]                           =  unproject_vectors(flong1, flat1, flong2, flat2, long, lat, ux, uy);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convert fault azimuth to a more useful rotation system  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%baz                                  = rad_to_deg(baz);
%baz                                  = -baz + 90;
%baz                                  = deg_to_rad(baz);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Rotate vectors to correct for fault strike  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[nee, nnn, nzz, nen, neu, nnu]       = deal(zeros(size(xx)));
%for cnt = 1 : length(xx)
%   [te, tn]                          = rotate_xy_vec(xx(cnt), xy(cnt), baz);
%   nee(cnt) = te;
%   nen(cnt) = tn;
%   [te, tn]                          = rotate_xy_vec(xy(cnt), yy(cnt), baz);
%   nnn(cnt) = tn;
%   [te, tn]                          = rotate_xy_vec(xz(cnt), yz(cnt), baz);
%   neu(cnt) = te;
%   nnu(cnt) = tn;
%end
%nuu                                  = zz;
[nee, nnn, nuu, nen, neu, nnu]       = deal(zeros(size(xx)));
baz = baz + pi/2;
rot = [cos(baz) sin(baz) 0; -sin(baz) cos(baz) 0; 0 0 1];
for i = 1:length(xx)
   smat = [xx(i) xy(i) xz(i); xy(i) yy(i) yz(i); xz(i) yz(i) zz(i)];
   rmat = rot*smat*rot';
   nee(i) = rmat(1); nnn(i) = rmat(5); nuu(i) = rmat(9);
   nen(i) = rmat(2);
   neu(i) = rmat(3);
   nnu(i) = rmat(6);
end