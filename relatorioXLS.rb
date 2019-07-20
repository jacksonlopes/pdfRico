libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
# = Gerar informação manipulável a partir do PDF de extrato da corretora Rico.
# Author: Jackson Lopes <jacksonlopes@gmail.com>
# URL: https://jslabs.cc
# src: https://github.com/jacksonlopes/pdfRico
require "relatorio"
require "write_xlsx"

class RelatorioXLS < Relatorio
    
    def initialize(info)
        super(info)        
        @workbook  = WriteXLSX.new(obter_nome_relatorio() + ".xlsx")
        @worksheetEstatistica = @workbook.add_worksheet
        @worksheetRelatorio = @workbook.add_worksheet
        @bold = @workbook.add_format(:bold => 1)
        @nobold = @workbook.add_format(:bold => 0)
    end

    # Gera o relatório.
    def relatorio()
        setarTitulo()
        setarEstatisticas()
        setarRelatorio()
        @workbook.close
    end

    # Define titulo a partir de dados do pdf.
    def setarTitulo()
        @worksheetEstatistica.set_column("A:A", 60, @bold)
        @worksheetEstatistica.set_row(0, 15)
        heading = @workbook.add_format(
            :bold  => 1,
            :color => 'blue',
            :size  => 10,
            :merge => 1,
            :align => 'vleft'
        )
        hyperlink_format = @workbook.add_format(
            :color => 'blue',
            :underline => 1
        )
        cab = @info.nome.split(" ")[0] + " - Ag.: " + @info.agencia + " | Conta: " + @info.conta 
        cab += " | Período: " + @info.periodo_de + " - " + @info.periodo_ate
        headings = [cab, '']
        @worksheetEstatistica.write_row('A1', headings, heading)
    end

    # Seta algumas informações no relatório gerado.
    def setarRelatorio()
        @worksheetRelatorio.write("A1",@cabecalho,@bold)
        @worksheetRelatorio.autofilter("A1:E1")
        c = 2
        @info.linha.each do |i|
            @worksheetRelatorio.write("A"+c.to_s, i["liquidacao"],@nobold)
            @worksheetRelatorio.write("B"+c.to_s, i["lancamento"],@nobold)
            @worksheetRelatorio.write("C"+c.to_s, i["transacao"],@nobold)
            @worksheetRelatorio.write("D"+c.to_s, i["valor"],@nobold)
            @worksheetRelatorio.write("E"+c.to_s, i["saldo"],@nobold)
            c += 1
        end
    end

    # Seta as estatísticas e gráfico.
    def setarEstatisticas()
        total_depositado = @info.estatistica.obter_valor_investido()
        total_repasse_custodia = @info.estatistica.obter_valor_repasse_custodia()
        total_valor_irrf = @info.estatistica.obter_valor_irrf()
        # estatísticas
        @worksheetEstatistica.write("A2","Total depositado",@bold)
        @worksheetEstatistica.write("B2",total_depositado,@nobold)
        @worksheetEstatistica.write("A3","Total de Repasse de Cust.",@bold)
        @worksheetEstatistica.write("B3",total_repasse_custodia,@nobold)        
        @worksheetEstatistica.write("A4","Total de IRRF",@bold)
        @worksheetEstatistica.write("B4",total_valor_irrf,@nobold)        
        # gráficos
        graf_pie = @workbook.add_chart(:type => "pie", :embedded => 1)
        graf_pie.add_series(
            :name       => "Valores por tipo",
            :categories => "=Sheet1!$A$2:$A$4",
            :values     => "=Sheet1!$B$2:$B$4",
        )        
        graf_pie.set_title(:name => "Valores por tipo")
        graf_pie.set_style(10)
        @worksheetEstatistica.insert_chart("D1", graf_pie, 25, 15)
    end

end
