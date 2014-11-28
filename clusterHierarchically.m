function [Y, clusterHead] = clusterHierarchically (Sn_length, Y, oneHopNeighborInfo, isAliveMatrix, Sn, BS, Packet_Size, Packet_Transmission_Cost, Amplification_Energy_ClusterHead, clusterHead, Sn_Energy)
receivedClusterHeadAnnouncement =  updateReceivedClusterHeadAnnouncement (Sn_length, Y, oneHopNeighborInfo);
           for i = 1 : Sn_length                
                if ((isAliveMatrix (i) ~= 1) || (Y(i,i) ~= 1))
                    continue 
                end
                transmissionCost = getTransmissionCost (Sn(i,1), Sn(i,2), BS(1), BS(2), Packet_Size, Packet_Transmission_Cost, Amplification_Energy_ClusterHead);
                minCost = 1 / (Sn_Energy (i) - transmissionCost);
                minCostIndex = i;
                for j = 1 : Sn_length
                    if ((isAliveMatrix (j) ~= 1) || (i == j))
                        continue 
                    end
                    if (receivedClusterHeadAnnouncement (i,j) == 1)
                        transmissionCost = getTransmissionCost (Sn(j,1), Sn(j,2), BS(1), BS(2), Packet_Size, Packet_Transmission_Cost, Amplification_Energy_ClusterHead);
                        cost2 = 1 / (Sn_Energy (j) - transmissionCost );
                        if (cost2 < minCost)
                            minCost = cost2 ;
                            minCostIndex = j;
                        end
                    end
                end
                if (minCostIndex ~= i)
                    clusterHead (i) = j;                   
                end
                
            end
            
end