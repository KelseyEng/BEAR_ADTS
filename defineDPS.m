%Kelsey Snapp
%Kab Lab
%3/9/22
% Defines Decision Policy settings that are used for the rest of the active
% learning loop

function DPS = defineDPS(DP,testT)
    switch DP

        case 2 % MV on toughness/mass
            DPS.tModeList = 2;
            DPS.xMode = 1;
            DPS.yModeList = 2; %Toughness/mass
            DPS.DPMode = 1; % MV
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 1;
            DPS.FocusRad = 0;
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 0;
            DPS.RestrictGP = 0;
            
        case 3 % EI on toughness/mass
            DPS.tModeList = 1;
            DPS.xMode = 1;
            DPS.yModeList = 2; %Toughness/mass
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 1;
            DPS.FocusRad = 0;
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 0;
            DPS.RestrictGP = 0;
            
        case 4 %EI on acceleration model
            DPS.tModeList = 1;
            DPS.xMode = 1;
            DPS.yModeList = 3; %Acceleration Model
            DPS.DPMode = 3; % EI Min
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 1;
            DPS.FocusRad = 0;
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 0;
            DPS.RestrictGP = 0;
      
        case 8 % EI to move up comp line
            DPS.tModeList = [1,1];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 1;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5];
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 1;
            

        case 10 %EI for parts only printable on this printer
            DPS.tModeList = [1,1];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 1;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5];         
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 1;
            
        case 11 %MV on EAE/Critical Stress for Cylinders
            DPS.tModeList = [2,2];
            DPS.xMode = 2;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 1; % MV
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 1;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 0;
            
        case 12 %EI on max of compline
            DPS.tModeList = [1,1];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 1;
            DPS.BoundaryCompLine = 1;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 2;
            DPS.FocusRad = 0.5; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0;0];
            DPS.RestrictGP = 1;
            
        case 13 % EI on KS/Critcal Stress for cylinders
            DPS.tModeList = [2,2];
            DPS.xMode = 2;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 1;
            
        case 14 % Pareto Front Random on max stress 20 vs. a model
            DPS.tModeList = [5,5];
            DPS.xMode = 1;
            DPS.yModeList = [6,3]; % Stress at 20 / acceleration model
            DPS.DPMode = 3; % EI Min
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 0;
            
        case 15 % Pareto Front Random on max stress 20 vs. a model
            DPS.tModeList = [5,0];
            DPS.xMode = 1;
            DPS.yModeList = [6,0]; % Stress at 20 / saved GP acceleration model
            DPS.DPMode = 4; % random
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 0;
            
        case 16 % Capped Part
            DPS.tModeList = [7,7];
            DPS.xMode = 3;
            DPS.yModeList = [7,5]; % Critical Force/EAE Model
            DPS.DPMode = 5; % UCB
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;0,0];
            DPS.RestrictGP = 0;
            
        case 17 % Search near best point for loaded material
            DPS.tModeList = [9,9];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 1;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 2;
            DPS.FocusRad = 0.5;  
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [1,1];
            DPS.RestrictGP = 1;
            
        case 18 %Search near best point
            DPS.tModeList = [1,1];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 1;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 2;
            DPS.FocusRad = 0.5; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [1,1];
            DPS.RestrictGP = 1;
            
        case 19 %Search near best point UCB
            DPS.tModeList = [1,1];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 5; % UCB Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 1;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = 2;
            DPS.FocusRad = 0.5; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0];
            DPS.RestrictGP = 1;
            
        case 20 %UCB on max comp line with Restricted Relative Density
            DPS.tModeList = [1,1];
            DPS.xMode = 1;
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 5; % UCB Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 1;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 1;
            
        case 21 % Pareto Front Random on max stress 20 vs. Ft*Ks
            DPS.tModeList = [7,7,7];
            DPS.xMode = 3;
            DPS.yModeList = [7,5,6]; % Critical Force/EAE Model/Stress at 20
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [1];
            DPS.FocusRad = [0]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = [0,0,0];
            DPS.RestrictGP = 0;
            
        case 22 %EI on Critical Stress/EAE for Extrudable Parts
            DPS.tModeList = [1,1];
            DPS.xMode = 4; %Extrudable 
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 1;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 1;
            
        case 23 %EI on Critical Stress/EAE for Extrudable Parts w/ Linear Twist
            DPS.tModeList = [1,1];
            DPS.xMode = 5; %Extrudable w/ twist
            DPS.yModeList = [4,5]; % Critical Stress/EAE Model
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 1;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 1;
            DPS.numIterLHS = 2;
            DPS.LHSMethod = [1,2];
            DPS.FocusRad = [0,0.5]; 
            DPS.FocusIdx = 2;
            DPS.RetrainGP = [0,0;1,1];
            DPS.RestrictGP = 1;
            
        case 24 % KSA: efficiency adjustment for 2 parallel parts (Adedire)
            DPS.tModeList = 9;
            DPS.xMode = 1; %General GCS
            DPS.yModeList = 8; % KS adjusted for parallel part
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [1];
            DPS.FocusRad = [0]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 0;
            DPS.RestrictGP = 0;

        case 25 % KSA: efficiency adjustment for 2 parallel parts with zoomed in GP (Adedire)
            DPS.tModeList = 9;
            DPS.xMode = 1; %General GCS
            DPS.yModeList = 8; % KS adjusted for parallel part
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [2];
            DPS.FocusRad = [0.5]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 1;
            DPS.RestrictGP = 1;
            
        case 26 % KSA: efficiency adjustment for 2 parallel parts with zoomed in GP (Adedire)
            DPS.tModeList = 9;
            DPS.xMode = 1; %General GCS
            DPS.yModeList = 8; % KS adjusted for parallel part
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [1];
            DPS.FocusRad = [0.1]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 1;
            DPS.RestrictGP = 1;
            
        case 27 % KSA: efficiency adjustment for 2 parallel parts with zoomed in GP (Adedire)
            DPS.tModeList = 9;
            DPS.xMode = 1; %General GCS
            DPS.yModeList = 8; % KS adjusted for parallel part
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [2];
            DPS.FocusRad = [0.1]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 1;
            DPS.RestrictGP = 1;
            
        case 28 % KSA: efficiency adjustment for 2 parallel parts with zoomed in GP (Adedire) (Fixed Hypersphere boundary)
            DPS.tModeList = 9;
            DPS.xMode = 1; %General GCS
            DPS.yModeList = 8; % KS adjusted for parallel part
            DPS.DPMode = 2; % EI Max
            DPS.campaignMode = 1;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [2];
            DPS.FocusRad = [0.9]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 1;
            DPS.RestrictGP = 1;
            
        case 301 % Squiggly Print Modulus
            DPS.tModeList = 301;
            DPS.xMode = 301; %General Squiggly
            DPS.yModeList = 301; % Modulus
            DPS.DPMode = 1; % MV
            DPS.campaignMode = 3;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [1];
            DPS.FocusRad = [0]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 1;
            DPS.RestrictGP = 0;
            
        case 302 % Squiggly Print dZ error
            DPS.tModeList = 301;
            DPS.xMode = 301; %General Squiggly
            DPS.yModeList = 302; % Modulus
            DPS.DPMode = 1; % MV
            DPS.campaignMode = 3;
            DPS.CompLine = 0;
            DPS.MaxCompLine = 0;
            DPS.BoundaryCompLine = 0;
            DPS.numIterLHS = 1;
            DPS.LHSMethod = [1];
            DPS.FocusRad = [0]; 
            DPS.FocusIdx = 1;
            DPS.RetrainGP = 1;
            DPS.RestrictGP = 0;
            
    end
            
    if testT.Printability
        if DPS.tModeList(1) == 1 || DPS.tModeList(1) == 9
            DPS.tModeList(end+1) = 3;
            DPS.yModeList(end+1) = 1;
        elseif DPS.tModeList(1) == 2
            DPS.tModeList(end+1) = 4;
            DPS.yModeList(end+1) = 1;
        elseif DPS.tModeList(1) == 5
            DPS.tModeList(end+1) = 6;
            DPS.yModeList(end+1) = 1;
        elseif DPS.tModeList(1) == 7
            DPS.tModeList(end+1) = 8;
            DPS.yModeList(end+1) = 1;
        elseif DPS.tModeList(1) == 301
            DPS.tModeList(end+1) = 300;
            DPS.yModeList(end+1) = 300;
        end 
        
        DPS.RetrainGP = [DPS.RetrainGP,zeros(size(DPS.RetrainGP,1),1)];
    end
    
end