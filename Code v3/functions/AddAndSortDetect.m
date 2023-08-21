function [SecDet] = AddAndSortDetect(SecDetCluster,EcartMax,StartAnalysis)

% Add the detections to the list
for k=1:length(StartAnalysis)
    AddDet = [];
    for CurrentCluster = 1:length(SecDetCluster)
        if (~isempty(SecDetCluster(CurrentCluster).Det)) && (~isempty(SecDetCluster(CurrentCluster).Det.Epoch(k).Det))
            AddDet = [AddDet' SecDetCluster(CurrentCluster).Det.Epoch(k).Det']';
        end
    end
    
    if isempty(AddDet)
        SecDet(k).Det = [];
    else
        % sort the detections in the list 
        SortDet = sortrows(AddDet,1);
        i = 1;
        while i < length(SortDet(:,1))
            if SortDet(i+1,1)-SortDet(i,1)<EcartMax
                SortDet(i,1) = min([SortDet(i,1) SortDet(i+1,1)]);
                SortDet(i,2) = max([SortDet(i,2) SortDet(i+1,2)]);
                SortDet(i+1,:) = [];
            else
                i=i+1;
            end
        end
        SecDet(k).Det = SortDet;
    end
    
end
    