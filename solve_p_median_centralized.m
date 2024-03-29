function [Y, clusterHead] = solve_p_median_centralized(Sn_Energy,Sn,Lm,p,D,Packet_Transmission_Cost, Packet_Size, Amplification_Energy_SensorNode, Amplification_Energy_ClusterHead, Min_Energy, t, BS)
   % t = 1; %Initially Lagrangean Multiplier assumed to be 1 --> solving Lagrangian and not Surrogate here.%
    bestLB = 0;
    bestUB = inf ;
    currentLB=0;
    currentUB=inf ;
    Sn_length = length(Sn);
    iterations(1,:)=[0 currentLB bestLB currentUB bestUB];
    pi = 2 ;
        %                   INITIALIZATION         %
    B = zeros(Sn_length,2);           
   
    Y = zeros(length(Sn),length(Sn)); % Sensor Node - Cluster Head Position Matrix. n*m %
    it_count = 0;
 
  while(~stoppingCondition(it_count,bestLB,bestUB)) 
    it_count = it_count + 1;
    InverseCost = getInverseCost(Sn_Energy,D,Sn_length, Packet_Transmission_Cost, Packet_Size, Amplification_Energy_SensorNode);
    % Step II Of The Code %
    for j = 1:Sn_length
      for i = 1 : Sn_length
         if (i == j)
             continue
         end
        if(Sn_Energy(i)> Min_Energy && Sn_Energy(j) > Min_Energy)
          x1 = InverseCost(i,j) - (t*Lm(i));       % Costij  � t* lambdai  %
          B(j,2) = B(j,2) +  min([0,x1]); % B stores (index, value), Summation(Bi) being done %      
          if(x1<0)
            Y(i,j) = 1;
          else 
            Y(i,j) = 0;
          end                    
        end
      end
      B(j,2) = B(j,2) + getInverseCostFromBaseStation(Sn_Energy,BS,Sn,j,Packet_Transmission_Cost, Packet_Size, Amplification_Energy_ClusterHead);
      B(j,1) = j;
    end
    %  STEP III %
    B = sortrows(B,2); % sorting the rows on 2nd column to get the first p solutions %
    
    % Allocating The Cluster Head Positions Cluster Heads %
   % X = allocateClusterHeadPositions(B,Ch,p);  
     % Lower Bound Is The Sum Over 'p' smallest values of Bj.
    currentLB = sum(B(1:p,2));% sum(B((1:p),2))+ t*sum(Lm); %Calculating the Lower Bound = sum of first p and Lambda.%trace(D * transpose(Y));
    if(currentLB > bestLB)        % Current Lower Bound always has to be lesser than or equal to  Best Lower Bound %
      bestLB=currentLB;
    end
    % Calculating the Upper Bound %
    currentUB = findUB(D,Sn,Sn_Energy, Min_Energy, Y, B, p);
    if(currentUB < bestUB)
      bestUB = currentUB;
    end
    
    iterations(it_count+1,:)=[it_count currentLB bestLB currentUB bestUB];
    % STEP IV : MODIFICATION OF THE LAGRANGEAN MULTIPLIERS. USING
    % SUBGRADIENT OPTIMIZATION TECHNIQUE.http://www.hyuan.com/java/how.html
    Y2 = transpose(Y);
    norm = sum((1-sum(Y2)).^2);
    if(norm == 0) % hit the lower bound
     break
    end
    step = pi*(bestUB-currentLB)/norm; 
    x = Lm + step*(1-transpose(sum(Y2))); 
    Lm = max(0,x);
   %Lm = Lm/2;
  % disp(Lm);
    %if(~improvementsOccur(iterations,piUpdateTime))
     % pi=pi/2;
     % piUpdateTime = it_count;
    %end  
    
  end
 Y=zeros(Sn_length, Sn_length); 
 for i=1:p
 index = B(i,1);
 Y(index,index) = 1;
 end
 [Y, clusterHead] = assignClusterHead(Sn,D,Min_Energy,Sn_Energy,Y);


  
     



