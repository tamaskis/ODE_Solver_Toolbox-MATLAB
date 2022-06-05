%==========================================================================
%
% RK2  Propagates the state vector forward one time step using the
% midpoint method (Runge-Kutta second-order method).
%
%   y_next = RK2(f,t,y,h)
%
% See also RK1_euler, RK2_heun, RK2_ralston, RK3, RK3_heun, RK3_ralston, 
% SSPRK3, RK4, RK4_ralston, RK4_38.
%
% Copyright © 2021 Tamas Kis
% Last Update: 2022-06-04
% Website: https://tamaskis.github.io
% Contact: tamas.a.kis@outlook.com
%
% TOOLBOX DOCUMENTATION:
% https://tamaskis.github.io/ODE_Solver_Toolbox-MATLAB/
%
% TECHNICAL DOCUMENTATION:
% https://tamaskis.github.io/documentation/Fixed_Step_ODE_Solvers.pdf
%
%--------------------------------------------------------------------------
%
% ------
% INPUT:
% ------
%   f       - (1×1 function_handle) dy/dt = f(t,y) --> multivariate, 
%             vector-valued function (f : ℝ×ℝᵖ → ℝᵖ) defining ODE
%   t       - (1×1 double) current sample time
%   y       - (p×1 double) state (i.e. solution) at current sample time, t
%   h       - (1×1 double) step size
%
% -------
% OUTPUT:
% -------
%   y_next  - (p×1 double) state (i.e. solution) at next sample time, t+h
%
% -----
% NOTE:
% -----
%   --> p = dimension of state vector (for the scalar case, p = 1)
%   --> The documentation above is written specifically for the case of
%       vector-valued ODEs, but this function can also be used for matrix-
%       valued ODEs of the form dM/dt = F(t,M), where 
%       F : ℝ×ℝᵖˣʳ → ℝᵖˣʳ.
%
%==========================================================================
function y_next = RK2(f,t,y,h)
    
    % k terms
    k1 = f(t,y);
    k2 = f(t+h/2,y+h*k1/2);
    
    % state vector propogated to next sample time
    y_next = y+h*k2;
    
end