grid = [
    ['1', '1', '0', '0'],
    ['1', '0', '0', '1'],
    ['0', '0', '1', '1'],
    ['0', '0', '0', '0']
]

function visit_island!(grid, row, column)
    if row < 1 || row > size(grid, 1) || column < 1 || column > size(grid, 2)
        return
    end
    if grid[row, column] == '0'
        return
    end

    grid[row, column] = '0'
    visit_island!(grid, row + 1, column)
    visit_island!(grid, row - 1, column)
    visit_island!(grid, row, column + 1)
    visit_island!(grid, row, column - 1)
end

islands = 0
for row in axes(grid, 1), column in axes(grid, 2)
    if grid[row, column] == '1'
        islands += 1
        visit_island!(grid, row, column)
    end
end

println("Островов: ", islands)
