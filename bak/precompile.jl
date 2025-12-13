@setup_workload begin
    a = rand(3, 3)
    @compile_workload begin
        quiet() do
           #b = np.array(a)
        end
    end
end