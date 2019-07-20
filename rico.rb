libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
# = Gerar informação manipulável a partir do PDF de extrato da corretora Rico
# Author: Jackson Lopes <jacksonlopes@gmail.com>
# URL: https://jslabs.cc
# src: https://github.com/jacksonlopes/pdfRico
require "pdf-reader"
require "infoRico"

##
# Classe responsável por extrair dados do pdf
class RicoExtratoPdf < Exception

    # Inicializa a Classe
    # :caminhoArquivo - path do arquivo de pdf
    def initialize(caminhoArquivoPdf)
        @caminhoArquivoPdf = caminhoArquivoPdf
        @regras = regras_processamento()
        @infoRico = InfoRico.new()
    end

    # Define as regras de processamento
    def regras_processamento()
        return {
            "nome" => 1 , "num_pg_nome" => 1, "agencia" => 2 , "num_pg_agencia" => 1,
            "periodo_de" => 2 , "num_pg_perde" => 2, "periodo_ate" => 2 , "num_pg_perate" => 2,
            "num_ini_linha" => 2
        }
    end

    # Inicia o processo de extração e filtragem
    def obterInformacoes()
        begin
            @reader = PDF::Reader.new(@caminhoArquivoPdf)
            extrairLinhas()
            return @infoRico
        rescue exception => e
            msg = "Erro ao manipular arquivo de PDF:\nException: + " + e.message + "\nBACKTRACE: " + e.backtrace.inspect
            raise RicoExtratoPdfException, "RicoExtratoPdfException::iniciarExtracao() - " + msg
        end
    end

    # Extrai as linhas do pdf
    def extrairLinhas()
        num_pagina = 1
        @infoRico.linha = []
        @reader.pages.each do |p|
            pos_linha  = 0            
            linhaScan = p.text.scan(/^.+/)
            linhaScan.each do |linha|
                filtrarLinha(linha,pos_linha,num_pagina)
                pos_linha += 1
            end
            num_pagina += 1
        end
    end

    # Efetua um parser na linha e seta no obj
    # :linha - linha a ser filtrada
    # :pos_linha  - posição que a linha ocupada no pdf
    # :num_pagina - número da página do pdf
    def filtrarLinha(linha,pos_linha,num_pagina)
        # Formato da linha
        # 14/04/2016        11/04        VALOR REF. LIQUIDO DA NOTA XXXX DO PREGÃO            R$ XX,XX    R$ X.XX,XX
        # 14/04/2016        11/04        VALOR REF. LIQUIDO DA NOTA XXXX DO PREGÃO           -R$ XX,XX    R$ X.XX,XX
        linha.strip!
        case
           # Nome
           when (num_pagina == @regras["num_pg_nome"] and pos_linha == @regras["nome"])
               @infoRico.nome = linha.strip
           # Agencia
           when (num_pagina == @regras["num_pg_agencia"] and pos_linha == @regras["agencia"])
               # Formato: Agência: XXXX  |  Conta: XXXXX , aproveito e seto a conta
               @infoRico.agencia = linha.split('|')[0].split(':')[1].strip
               @infoRico.conta = linha.split('|')[1].split(':')[1].strip
           # Período de ... até ..    
           when (num_pagina == @regras["num_pg_perde"] and pos_linha == @regras["periodo_de"])
               # Formato: Período de 01/01/2016  até 17/12/2016 , aproveito e seto período até
               l_tmp = linha["Período de".length,linha.length].strip
               @infoRico.periodo_de = l_tmp.split(' ')[0].strip
               @infoRico.periodo_ate = l_tmp.split(' ')[2].strip
           # Linha.. começa com data.. /^[0-9]/
           when (pos_linha >= @regras["num_ini_linha"] and linha =~ /^[0-9]/ )
               # Vai percorrendo os campos em sequencia...
               hs_linha = obter_hash_linha()
               hs_linha["liquidacao"] = linha[0,10]
               linha = linha[11,linha.length-11]               
               return if linha.nil?
               linha.strip!
               hs_linha["lancamento"] = linha[0,5]               
               linha = linha[6,linha.length-6]
               linha.strip!
               # Obtém o indice do valor.. para poder obter a descricao.. 0 até 1 pos antes 
               # do valor
               pos_1 = linha.index("R$")
               pos_2 = linha.index("-R$")               
               hs_linha["transacao"] = linha[0,pos_1 - 1].strip! if not pos_1.nil? # se positivo..
               hs_linha["transacao"] = linha[0,pos_2 - 1].strip! if not pos_2.nil? # se negativo..
               linha = linha[hs_linha["transacao"].length + 1 , linha.length - hs_linha["transacao"].length]
               # linha agora tem somente o valor e saldo.
               linha.delete!("R$").strip!
               # primeira posição após o valor.
               pos_1 = linha.index(",") + 2
               if linha[0] == "-"
                   # se valor negativo
                   hs_linha["valor"] = "-" + linha[2,pos_1].strip
               else
                   # se valor positivo
                   hs_linha["valor"] = linha[0,pos_1 + 1].strip
               end    
               # saldo começa após o valor
               hs_linha["saldo"] = linha[pos_1 + 1,linha.length - pos_1].strip
               # o parser corta essa informação.. acrescento novamente.
               if hs_linha["transacao"].start_with? "VALOR REF. LIQUIDO"
                   hs_linha["transacao"] = hs_linha["transacao"].strip + " " + hs_linha["lancamento"]
               end 
               @infoRico.linha.push(hs_linha)
        end

    end

    def obter_hash_linha()
        return {"liquidacao" => nil, "lancamento" => nil, "transacao" => nil, "valor" => nil, "saldo" => nil}
    end

end