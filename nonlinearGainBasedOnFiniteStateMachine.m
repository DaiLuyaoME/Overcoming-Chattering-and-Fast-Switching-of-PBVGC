function [sys,x0,str,ts,simStateCompliance] = nonlinearGainBasedOnFiniteStateMachine(t,x,u,flag)
%SFUNTMPL General MATLAB S-Function Template
%   With MATLAB S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an MATLAB S-function syntax is:
%       [SYS,X0,STR,TS,SIMSTATECOMPLIANCE] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying more than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].
%
%      SIMSTATECOMPLIANCE = Specifices how to handle this block when saving and
%                           restoring the complete simulation state of the
%                           model. The allowed values are: 'DefaultSimState',
%                           'HasNoSimState' or 'DisallowSimState'. If this value
%                           is not speficified, then the block's compliance with
%                           simState feature is set to 'UknownSimState'.


%   Copyright 1990-2010 The MathWorks, Inc.

%
% The following outlines the general structure of an S-function.
%
switch flag
    
    %%%%%%%%%%%%%%%%%%
    % Initialization %
    %%%%%%%%%%%%%%%%%%
    case 0
        [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;
        
        %%%%%%%%%%%%%%%
        % Derivatives %
        %%%%%%%%%%%%%%%
    case 1
        sys=mdlDerivatives(t,x,u);
        
        %%%%%%%%%%
        % Update %
        %%%%%%%%%%
    case 2
        sys=mdlUpdate(t,x,u);
        
        %%%%%%%%%%%
        % Outputs %
        %%%%%%%%%%%
    case 3
        sys=mdlOutputs(t,x,u);
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % GetTimeOfNextVarHit %
        %%%%%%%%%%%%%%%%%%%%%%%
    case 4
        sys=mdlGetTimeOfNextVarHit(t,x,u);
        
        %%%%%%%%%%%%%
        % Terminate %
        %%%%%%%%%%%%%
    case 9
        sys=mdlTerminate(t,x,u);
        
        %%%%%%%%%%%%%%%%%%%%
        % Unexpected flags %
        %%%%%%%%%%%%%%%%%%%%
    otherwise
        DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
        
end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 3;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-1 0];
ts  = [1/5000 0];
% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';
global alphaCount;
alphaCount = 0;
global errorBuffer;
errorBuffer = zeros(30,1);

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)
global currentErrorState;
global delta;
global currentMin;
global currentMax;
global alpha;
global alphaCount;
global alphaBuffer;
global deDeltaUpperBound;
global deDeltaLowerBound;
global errorBuffer;



e = u(1);
de = u(2);

%% switching based on finite state machine
% switch currentErrorState
%     case ErrorStates.PositiveErrorDown
%         if e < currentMin + delta && e > 0
%             currentMin = min(e,currentMin);
%         elseif e < currentMin + delta && e <= 0
%             currentMin = min(e,currentMin);
%             currentErrorState = ErrorStates.NegativeErrorDown;
%         else
%             currentMax = e;
%             currentErrorState = ErrorStates.PositiveErrorUp;
%         end
%
%
%     case ErrorStates.NegativeErrorDown
%         if e < currentMin - delta && e <= 0
%             currentMin = min(e,currentMin);
%         elseif e >= currentMin - delta && e <= 0
%             currentMax = e;
%             currentErrorState = ErrorStates.NegativeErrorUp;
%         else
%             currentMax = e;
%             currentErrorState = ErrorStates.PositiveErrorUp;
%         end
%
%
%     case ErrorStates.NegativeErrorUp
%         if e > currentMax - delta && e < 0
%             currentMax = max(e,currentMax);
%         elseif e > currentMax - delta && e >= 0
%             currentMax = max(e,currentMax);
%             currentErrorState = ErrorStates.PositiveErrorUp;
%         else
%             currentMin = e;
%             currentErrorState = ErrorStates.NegativeErrorDown;
%         end
%
%
%     case ErrorStates.PositiveErrorUp
%         if e > currentMax + delta && e >= 0
%             currentMax = max(e,currentMax);
%         elseif e <= currentMax + delta && e >=0
%             currentMin = e;
%             currentErrorState = ErrorStates.PositiveErrorDown;
%         else
%             currentMin = e;
%             currentErrorState = ErrorStates.NegativeErrorDown;
%         end
%
%
% end


% if currentErrorState == ErrorStates.NegativeErrorDown || currentErrorState == ErrorStates.PositiveErrorUp
%     y = alpha * e;
% %     num = numel(alphaBuffer);
% %     if alphaCount < num
% %         y = alpha * e * alphaBuffer(alphaCount+1);
% %         alphaCount = alphaCount + 1;
% %     else
% %         y = alpha * e;
% %     end
%     alphaCount = numel(alphaBuffer);
% else
%     if alphaCount > 0
%         y = alpha * e * alphaBuffer(alphaCount);
%         alphaCount = alphaCount - 1;
%     else
%         y = 0;
%     end
% %     y = 0;
%
% end

%% method based on online zero phase error filtering
errorBuffer = circshift(errorBuffer,-1);
errorBuffer(end) = e;
global errorFilter;
% filteredError = filtfilt(errorFilter,errorBuffer);
filteredError = filtfilt(errorFilter,errorBuffer);
filteredError = errorBuffer;
tempE = filteredError(end);
tempDe = filteredError(end) - filteredError(end-1);
% errorBuffer(end) = tempE;



transitionType = 1; % 1 for step + dwell time; 2 for sigmoid like function

switch transitionType
    case 1
        
        if tempE * tempDe > 0
            y = e * alpha;
            alphaCount = numel(alphaBuffer);
        else
            if alphaCount > 0
                y = alpha * e * alphaBuffer(alphaCount);
                alphaCount = alphaCount - 1;
            else
                y = 0;
            end
%             y = 0;
        end
        gain = 0;
    case 2
        global f;
        if tempE * tempDe >0
            x = tempE * tempDe * 5000;
            x = x / (3e-9) * 10;
            gain = f(x);
            y =  gain * tempE;
        else
            y = 0;
            gain = 0;
        end
        %         y = 0;
end

%%




% sys = [y,tempE * tempDe * 5000,gain];
sys = [y,tempE,gain];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
