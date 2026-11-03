function el_add(els,r2,msize)

elcol='k';
% x=[1:0.5:100];
% y=x(100:199)/max(x);
y=[1:100]/100;
cm=[y;y;y]';
cm(:,1)=0;
cm(:,3)=0;
cm(1,:)=[0 0 0];
% the more green, higher r2
%cm=flipud(cm); 
%if ~exist('msize','var')
%msize=30; %marker size
%end

if exist('elcol')==0, 
    elcol='r'; %default color if none input
end
hold on
% black circle around electrode:
% plot3(els(:,1),els(:,2),els(:,3),'.','Color', elcol,'MarkerSize',msize+5)
% electrode with r2:
for k=1:length(els)
    if round(r2(k)*100)>0
        elcol_r2=cm(round(r2(k)*100),:);
        plot3(els(k,1),els(k,2),els(k,3),'.','Color', elcol_r2,'MarkerSize',msize)
    end
end
% white dot within circle (size msize)
plot3(els(:,1),els(:,2),els(:,3),'.','Color', 'w','MarkerSize',msize/5)






