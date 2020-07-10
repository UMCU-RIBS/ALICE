function handle=tripatch(struct, nofigure,facealpha, varargin)
% TRIPATCH handle=tripatch(struct, nofigure)
%
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.


if nargin<2 | isempty(nofigure)
   figure
end% if
if nargin<3
   handle=trisurf(struct.tri, struct.vert(:, 1), struct.vert(:, 2), struct.vert(:, 3));
else
   if isnumeric(varargin{1})
      col=varargin{1};
      varargin(1)=[];
      if [1 3]==sort(size(col))
         col=repmat(col(:)', [size(struct.vert, 1) 1]);
      end% if
      handle=trisurf(struct.tri, struct.vert(:, 1), struct.vert(:, 2), struct.vert(:, 3), ...
         'FaceVertexCData', col,'FaceAlpha', facealpha, varargin{:});
      if length(col)==size(struct.vert, 1)
         set(handle, 'FaceColor', 'interp');
      end% if
   else
      handle=trisurf(struct.tri, struct.vert(:, 1), struct.vert(:, 2), struct.vert(:, 3), varargin{:});
   end% if
end% if
axis tight
axis equal
hold on
if version('-release')>=12
   cameratoolbar('setmode', 'orbit')
else
   rotate3d on
end% if
