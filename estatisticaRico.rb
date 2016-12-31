libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
# = Gera estatísticas a partir do arquivo de PDF.
# Autor: Jackson Lopes <jacksonlopes@gmail.com>
# Site:  https://jacksonlopes.github.io
require "infoRico"
require "utilRico"

class EstatisticaRico

    # info - InfoRico
    def initialize(info)
        @info = info
        @util = UtilRico.new
    end

    # Obtém o somatório dos valores das transações por tipo.
    def obter_valor(stransacao)
        valor = 0.00
        @info.linha.each do |v|
            if v["transacao"].start_with? stransacao
                valor += @util.converter_valor(v["valor"])
            end
        end
        return valor        
    end

    # Obtém o total de valor investido.
    def obter_valor_investido()
        return obter_valor("TED - CREDITO EM C/C")
    end    

    # Obtém o total de valor de repasse de custódia.
    def obter_valor_repasse_custodia()
        return obter_valor("ESTORNO REPASSE TX.CUSTÓDIA")
    end

    # Obtém o valor de I.R.R.F
    def obter_valor_irrf()
        return obter_valor("I.R.R.F. S/ OPERAÇÕES PR.") * -1
    end

end