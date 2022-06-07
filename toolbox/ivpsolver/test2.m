%%
clear;clc;close all;
addpath(genpath('..'));
%%
f = @(t,y) y;
y20 = 50;
[t,y] = solve_ivp(f,[20,10],y20,0.001,'ABM8');
y10 = y(end)
[t,y] = solve_ivp(f,[10,20],y10,0.001,'ABM8');
y20 = y(end)
% %%
% f = @(t,y) y;
% y20 = 50;
% C = @(t,y) t > 10;
% %[t,y] = solve_ivp(f,{20,C},y20,-0.001,'ABM8');
% [t,y] = solve_ivp(f,[20,10],y20,0.001,'ABM8');
% y10 = y(end)