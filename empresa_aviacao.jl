#!/usr/bin/env  julia
using JuMP
using Gurobi

m = Model(with_optimizer(Gurobi.Optimizer))


# dados
tipos_avioes = collect(1:3)
tamanho_avioes = [1, 3/4, 5/3]

verba = 220
max_galpao = 40

custos = [5.1, 3.6, 6.8]
receitas = [330, 300, 420]
pilotos = [30, 20, 10]


# variaveis
@variable(m, quantidades[tipos_avioes] >= 0, Int)

# funcao objetivo
@objective(m, Max, sum(quantidades[i] * (receitas[i] - custos[i]) for i in tipos_avioes))

# resticoes
@constraints(m,
    begin
        sum(tamanho_avioes[i] * quantidades[i] for i in tipos_avioes) <= max_galpao
        sum(custos[i] * quantidades[i] for i in tipos_avioes) <= verba
        2 * quantidades[3] <= pilotos[3]
        2 * quantidades[1] + 2 * quantidades[3] <= pilotos[1] + pilotos[3]
        2 * quantidades[2] + 2 * quantidades[3] <= pilotos[2] + pilotos[3]
        2 * sum(quantidades[i] for i in tipos_avioes) <= sum(pilotos[i] for i in tipos_avioes)
    end
)

# imprime modelo
println(m)


start_time = time()
optimize!(m)
end_time = time()
println("Tempo: $(end_time - start_time) s")
println("Resultado função: ", JuMP.objective_value(m))

custo_total = 0
for i in tipos_avioes
    if (JuMP.value(quantidades[i]) > 0)
        println("quantidades[", i, "]: ", JuMP.value(quantidades[i]))
        println("Custo: ", JuMP.value(quantidades[i]) * custos[i])
        global custo_total += JuMP.value(quantidades[i]) * custos[i]
    elseif (JuMP.value(quantidades[i]) == 0)
        println("quantidades[", i, "]: ", 0.0)
    end
end
println("Custo total: ", custo_total)

println()



