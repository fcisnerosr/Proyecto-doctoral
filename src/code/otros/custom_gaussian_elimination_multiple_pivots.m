function reduced_matrix = custom_gaussian_elimination_multiple_pivots(matrix, pivot_indices)
    [rows, cols] = size(matrix);
    
    for pivot_index = pivot_indices
        if pivot_index < 1 || pivot_index > rows || pivot_index > cols
            error('Invalid pivot index');
        end
        
        % Convert the chosen pivot element to 1
        pivot = matrix(pivot_index, pivot_index);
        matrix(pivot_index, :) = matrix(pivot_index, :) / pivot;
        
        % Eliminate other elements in the column
        for i = 1:rows
            if i ~= pivot_index
                factor = matrix(i, pivot_index);
                matrix(i, :) = matrix(i, :) - factor * matrix(pivot_index, :);
            end
        end
    end
    
    reduced_matrix = matrix;
end
