%==========================================================================
%
% ode  Fixed-step ODE solvers.
%
%   [t,y] = ode(f,[t0,tf],y0,h)
%   [t,y] = ode(f,{t0,C},y0,h)
%   [t,y] = ode(__,method)
%   [t,y] = ode(__,method,wb)
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
%   I       - defines interval over which to solve the ODE, 2 options:
%               --> [t0,tf] - (1×2 double) initial and final times
%               --> {t0,C}  - (1×2 cell) initial time, t₀, and function 
%                             handle for condition function, C(t,y) 
%                             (C : ℝ×ℝᵖ → 𝔹)
%   y0      - (p×1 double) initial condition, y₀ = y(t₀)
%   h       - (1×1 double) step size
%   method  - (char) (OPTIONAL) Runge-Kutta method --> 'Euler', 'RK2', 
%             'RK2 Heun', 'RK2 Ralston', 'RK3', 'RK3 Heun', 'RK3 Ralston', 
%             'SSPRK3', 'RK4', 'RK4 Ralston', 'RK4 3/8' (defaults to 'RK4')
%   wb      - (1×1 logical or char) (OPTIONAL) waitbar parameters
%               --> input as "true" if you want waitbar with default 
%                   message displayed
%               --> input as a char array storing a message if you want a
%                   custom message displayed on the waitbar
%
% -------
% OUTPUT:
% -------
%   t       - ((N+1)×1 double) time vector
%   y       - ((N+1)×p double) matrix storing time history of state vector
%
% -----
% NOTE:
% -----
%   --> p = dimension of state vector (for the scalar case, p = 1)
%   --> N+1 = length of time vector
%   --> The ith row of "y" is the TRANSPOSE of the state vector (i.e. the
%       solution corresponding to the ith time in "t"). This convention is
%       chosen to match the convention used by MATLAB's ODE suite.
%
%==========================================================================
function [t,y] = ode(f,I,y0,h,method,wb)
    
    % --------------------
    % Time detection mode.
    % --------------------
    
    if ~iscell(I)
        
        % extracts initial and final times
        t0 = I(1);
        tf = I(2);
        
        % makes step size negative if t0 > tf
        if (t0 > tf)
            h = -h;
        end
        
        % defines condition function
        C = @(t,y) t <= tf;
        
        % indicates that final time is known
        final_time_known = true;
        
        % number of subintervals between sample times
        N = ceil((tf-t0)/h);
        
        % turns waitbar on with custom message
        if (nargin == 6) && ischar(wb)
            display_waitbar = true;
            [wb,prop] = initialize_waitbar(msg);
            
        % turns waitbar on with default message
        elseif (nargin == 6) && wb
            display_waitbar = true;
            [wb,prop] = initialize_waitbar('Solving ODE...');
            
        % turns waitbar off otherwise
        else
            display_waitbar = false;
            
        end
        
    % ---------------------
    % Event detection mode.
    % ---------------------
    
    else
        
        % extracts initial time and condition function
        t0 = I{1};
        C = I{2};
        
        % indicates that final time is unknown
        final_time_known = false;
        
    end
    
    % -------------------
    % Integration method.
    % -------------------
    
    % defaults integration method to RK4
    if (nargin < 5) || isempty(method)
        method = 'RK4';
    end
    
    % sets propagation function for single-step methods
    if strcmpi(method,'RK1_euler')
        propagate = @(t,y) RK1_euler(f,t,y,h);
    elseif strcmpi(method,'RK2')
        propagate = @(t,y) RK2(f,t,y,h);
    elseif strcmpi(method,'RK2_heun')
        propagate = @(t,y) RK2_heun(f,t,y,h);
    elseif strcmpi(method,'RK2_ralston')
        propagate = @(t,y) RK2_ralston(f,t,y,h);
    elseif strcmpi(method,'RK3')
        propagate = @(t,y) RK3(f,t,y,h);
    elseif strcmpi(method,'RK3_heun')
        propagate = @(t,y) RK3_heun(f,t,y,h);
    elseif strcmpi(method,'RK3_ralston')
        propagate = @(t,y) RK3_ralston(f,t,y,h);
    elseif strcmpi(method,'SSPRK3')
        propagate = @(t,y) SSPRK3(f,t,y,h);
    elseif strcmpi(method,'RK4')
        propagate = @(t,y) RK4(f,t,y,h);
    elseif strcmpi(method,'RK4_38')
        propagate = @(t,y) RK4_38(f,t,y,h);
    elseif strcmpi(method,'RK4_ralston')
        propagate = @(t,y) RK4_ralston(f,t,y,h);
    end
    
    % sets propagation function for multi-step predictor methods
    if strcmpi(method,'AB2')
        propagate = @(t,F) AB2(f,t,F,h);
    elseif strcmpi(method,'AB3')
        propagate = @(t,F) AB3(f,t,F,h);
    elseif strcmpi(method,'AB4')
        propagate = @(t,F) AB4(f,t,F,h);
    elseif strcmpi(method,'AB5')
        propagate = @(t,F) AB5(f,t,F,h);
    elseif strcmpi(method,'AB6')
        propagate = @(t,F) AB6(f,t,F,h);
    elseif strcmpi(method,'AB7')
        propagate = @(t,F) AB7(f,t,F,h);
    elseif strcmpi(method,'AB8')
        propagate = @(t,F) AB8(f,t,F,h);
    end
    
    % sets propagation function for multi-step predictor-corrector methods
    if strcmpi(method,'ABM2')
        propagate = @(t,F) ABM2(f,t,F,h);
    elseif strcmpi(method,'ABM3')
        propagate = @(t,F) ABM3(f,t,F,h);
    elseif strcmpi(method,'ABM4')
        propagate = @(t,F) ABM4(f,t,F,h);
    elseif strcmpi(method,'ABM5')
        propagate = @(t,F) ABM5(f,t,F,h);
    elseif strcmpi(method,'ABM6')
        propagate = @(t,F) ABM6(f,t,F,h);
    elseif strcmpi(method,'ABM7')
        propagate = @(t,F) ABM7(f,t,F,h);
    elseif strcmpi(method,'ABM8')
        propagate = @(t,F) ABM8(f,t,F,h);
    end
    
    % determines if the method is a single-step method
    if strcmpi(method(1:2),'RK')
        single_step = true;
    else
        single_step = false;
    end
    
    % determines order for multistep methods
    if ~single_step
        m = str2double(method(end));
    end
    
    % --------------------------------------------------
    % Preallocates arrays and stores initial conditions.
    % --------------------------------------------------
    
    % preallocates time vector and solution matrix
    t = zeros(10000,1);
    y = zeros(length(y0),length(t));
    
    % stores initial conditions
    t(1) = t0;
    y(:,1) = y0;
    
    % ---------------------------------------
    % Solves ODE (using single-step methods).
    % ---------------------------------------
    
    if single_step
        
        % state vector propagation while condition is satisfied
        n = 1;
        while C(t(n),y(:,n))
            
            % expands t and y if needed
            if (n+1) > length(t)
                [t,y] = expand_solution_arrays(t,y);
            end
            
            % state vector propagated to next sample time
            y(:,n+1) = propagate(t(n),y(:,n));
            
            % increments time and loop index
            t(n+1) = t(n)+h;
            n = n+1;
            
            % updates waitbar
            if final_time_known && display_waitbar
                prop = update_waitbar(n,N,wb,prop);
            end
            
        end
        
    % --------------------------------------
    % Solves ODE (using multi-step methods).
    % --------------------------------------
    
    else
        
        % time vector for first m sample times
        t(1:m) = (t0:h:(t0+(m-1)*h))';
        
        % propagating state vector using RK4 for first "m" sample times
        for n = 1:m
            y(:,n+1) = RK4(f,t(n),y(:,n),h);
        end
        
        % initializes F matrix (stores function evaluations for first m 
        % sample times in first m columns, state vector at (m+1)th sample
        % time in (m+1)th column)
        F = zeros(length(y0),m+1);
        for n = 1:m
            F(:,n) = f(t(n),y(:,n));
        end
        F(:,n+1) = y(:,m+1);
        
        % state vector propagation while condition is satisfied
        n = 1;
        while C(t(n),y(:,n))
            
            % expands t and y if needed
            if (n+1) > length(t)
                [t,y] = expand_solution_arrays(t,y);
            end
            
            % updates F matrix
            F = propagate(t(n),F);
            
            % extracts/stores state vector propagated to next sample time
            y(:,n+1) = F(:,m+1);
            
            % increments time and loop index
            t(n+1) = t(n)+h;
            n = n+1;
            
        end
        
    end
    
    % -----------------
    % Final formatting.
    % -----------------
    
    % trims arrays
    y = y(:,1:(n-1));
    t = t(1:(n-1));
    
    % transposes solution matrix so it is returned in "standard form"
    y = y';
    
    % closes waitbar
    if final_time_known && display_waitbar
        close(wb);
    end
    
end