close all;
x=randi([0 7],[1,1024]);
y = pskmod(x,8,pi/8,'bin')
y_n=awgn(y,-3); 
y1=y_n./max(y_n);
scatterplot(y1)
z=pskdemod(y1,8,pi/8,'bin');
b=z-x;
