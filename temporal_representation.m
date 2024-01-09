%Basic training of Temporal Representation Units from Alexander & Gershman
%2022
clear
clf

%set up training and model parameters
%# of Temporal Representation Units
numUnits=10;

%learning rates for TRU value, mean, and variance
alpha_v=.1;
alphapos=0.2;
alphasig=0.05;

%discount factor
gamma=.99;

%reward parameters
rtime=350; %timestep within trial that reward begins
rsig=.25; %we're modeling the reward as a gaussian, so the variance determines its 'spread' in time
rewmag=1;%magnitude of reward


%duration of a single trial in timesteps
trial_length=850;

%set up initial positions for TRUs - here we're going to assume TRUs are
%evenly spaced over the entire duration of the trial
interval=trial_length./numUnits;
initPos=interval-interval:interval:trial_length;

begPos=initPos;  %we want to keep track of where all the TRUs started for plotting later

%initialize sigmas
initSigs=15.5.*ones(size(initPos));
begSigs=initSigs;%and keep track of initial sigmas

%initialize value weights for each TRU at 0
vs=zeros(1,length(initPos));

%number of trials
numTrials=2500;

%stuff for storing data
vmat=zeros(numTrials,trial_length); %value history
dmat=nan(size(vmat)); %value prediction error history
dmat_mu=dmat; %mean position error history
dmat_sig=dmat; %sigma error history
thisrt=[]; 

%Finally, some book-keeping variables for TD Learning
lastact=zeros(1,length(initSigs));
lastSigs=initSigs;
lastPos=initPos;
tmpPos=initPos;

%Start outer trial loop
for i=1:numTrials
   

% trt=-40:1:40;
%     temprtime=randperm(length(trt));%randperm(41);
% %     rtime=350+trt(temprtime(1));
%     thisrt=[thisrt rtime];
%     rew=0;
    lastpred=0;
    lastact=0.*lastact;
    rcount=0;
%     isrew=rand<1;
    

   
    %Start Inner Trial Loop    
    for j=0:trial_length;

        %sometimes the TRUs collapse - this enforces a minimum variance
         initSigs(initSigs<1)=1;
        
         %this is the effective predictive cue onset for the trial.  That
         %is, the cue that actually predicts the ensuing reward occurs at
         %timestep 100 of the trial.  so tN is the time since the
         %reward-predicting cue is presented
        tN=j-100;

        %reward is calculated on every timestep, although its close to 0
        %most of the time.
        rew=exp((-(rtime-j).^2)/(2.*rsig));
        
        %get the current activation of each TRU
        curract=exp(-(initPos-j).^2./(2.*initSigs.^2));
        
        curr_act(tmpPos<100)=0;
            if tN>0 %has the reward-predicting cue actually been presented yet?  it doesn't make sense to predict anything if not
                    pred=sum(curract.*vs);
            else
                     pred=0.*lastpred;
            end

        %TD error
        delta=rew+gamma.*pred-lastpred;
        
        %track TD error
        dmat(i,j+1)=delta;  
        
        tmpPos=lastPos;
        tmpSigs=lastSigs;
        tmpAct=lastact;

        
        for k=1:10
            %here we update the position and variance of the sigmas.  
            %we're applying the update 10 times on each cycle - the idea
            %being to take 10 small steps to reduce error rather than 1
            %large step.  This can help with keeping everything stable -
            %since we're updating both the position of a TRU as well as the
            %value prediction, things can go severely non-linear if we try
            %to move both those values too far at the same time.
            
            %on each 'small' iteration, recalculate error, new predictions
            %and so on and use those to update sigma and mu
            delta=rew+gamma.*pred-lastpred; %new prediction error

            %update position and variance - error term is the partial
            %derivative w/r/t sigma and mu as derived in the paper
            tmpPos=tmpPos+alphapos.*delta.*lastact.*-(tmpPos-(j-1)) ./(tmpSigs.^2);
            tmpSigs=tmpSigs+alphasig.*(delta).*lastact.*4.*((tmpPos-(j-1)).^2)./(tmpSigs.^3);
               
            %recalculate activity and predictions after moving the TRUs a
            %small amount
            lastact=exp(-(tmpPos-(j-1)).^2./(2.*tmpSigs.^2));
            lastpred=sum(lastact.*vs);
            
            %prevent TRU collapse
            tmpSigs(tmpSigs<1)=1;
        end


        %keep track of variables
        dmat_mu(i,j+1)=max(abs(initPos-tmpPos));
        dmat_sig(i,j+1)=max(abs(initSigs-tmpSigs));
        vmat(i,j+1)=pred;
        %update book-keeping variables for TD learning
        initPos=tmpPos;
        initSigs=tmpSigs;
        lastPos=initPos;
        lastSigs=initSigs;
        vs=vs+alpha_v.*delta.*lastact;
        lastact=curract;
        curract=curract.*0;
        lastpred=pred;
        
        delta=rew+gamma.*pred-lastpred;
        
        



    end %End Innter Trial Loop
        
        %display figure - 
        if mod(i,50)==0
           disp(num2str(i))
           temporal_gaussians
           drawnow
        end
  
        
end
