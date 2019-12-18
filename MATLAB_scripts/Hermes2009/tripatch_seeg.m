function [handleL]=tripatch_seeg(structL, structR, nofigure, varargin)
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
    handleL=trisurf(structL.tri, structL.vert(:, 1), structL.vert(:, 2), structL.vert(:, 3)); hold on;
    trisurf(structR.tri, structR.vert(:, 1), structR.vert(:, 2), structR.vert(:, 3)); hold off;
else
    if isnumeric(varargin{1})
        colL=varargin{1};
        colR=varargin{2};
        varargin(1:2)=[];
        
        if [1 3]==sort(size(colL))
            colL=repmat(colL(:)', [size(structL.vert, 1) 1]);
            
        end% if
        
        if [1 3]==sort(size(colR))
            colR=repmat(colR(:)', [size(structR.vert, 1) 1]);
            
        end% if
        
        handleL=trisurf(structL.tri, structL.vert(:, 1), structL.vert(:, 2), structL.vert(:, 3), ...
            'FaceVertexCData', colL, 'FaceAlpha', 0.3, varargin{:}); hold on;
        
        trisurf(structR.tri, structR.vert(:, 1), structR.vert(:, 2), structR.vert(:, 3), ...
            'FaceVertexCData', colR, 'FaceAlpha', 0.3, varargin{:}); hold off;
        
        if length(colL)==size(structL.vert, 1)
            set(handleL, 'FaceColor', 'interp');
        end% if
        
%         if length(colR)==size(structR.vert, 1)
%             set(handleR, 'FaceColor', 'interp');
%         end% if
    
    else
        handleL=trisurf(structL.tri, structL.vert(:, 1), structL.vert(:, 2), structL.vert(:, 3), varargin{:}); hold on;
        trisurf(structR.tri, structR.vert(:, 1), structR.vert(:, 2), structR.vert(:, 3), varargin{:}); hold off;
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