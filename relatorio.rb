libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
# = Classe pai dos Relatórios.
# Author: Jackson Lopes <jacksonlopes@gmail.com>
# URL: https://jslabs.cc
# src: https://github.com/jacksonlopes/pdfRico
require "relatorioXLS"
require "utilRico"

class Relatorio

    def initialize(info)
        @util = UtilRico.new
        @info = info
        @cabecalho = cabecalho()
    end

    # Gerar o relatório
    # :tipo - Tipo do relatório a se gerar.
    def gerar(tipo)
        tipo.relatorio()
    end

    # Define o cabeçalho do relatório.
    def cabecalho()
        return ["Liquidação","Lançamento","Transação","Valor","Saldo"]
    end

    # Cria o nome do relatório a ser gerado.
    def obter_nome_relatorio()
        de = @info.periodo_de.to_s.gsub("/","")
        ate = @info.periodo_ate.to_s.gsub("/","")
        return "REL_RICO_per__" + de + "-" + ate + "__" + Time.new.strftime("%d%m%Y").to_s
    end

end