#!/usr/bin/env ruby
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
# = Extrai e gera relatório do PDF.
# Autor: Jackson Lopes <jacksonlopes@gmail.com>
# Site:  https://jacksonlopes.github.io
require "optparse"
require "rico"
require "estatisticaRico"
require "relatorioXLS"
require "utilRico"

opcoes = {}

# ref: http://rubylearning.com/blog/2011/01/03/how-do-i-make-a-command-line-tool-in-ruby/
opt_parser = OptionParser.new do |opt|
  opt.banner = "Uso: ruby pdfRico.rb -f <ARQUIVO PDF>"
  opt.separator  ""

  opt.on("-p","--pdf ARQUIVO","Arquivo PDF") do |arquivo|
    opcoes[:arquivo] = arquivo
  end

  opt.on("-a","--ajuda","ajuda") do
    puts opt_parser
  end
end
opt_parser.parse!

if (opcoes[:arquivo] == "" or opcoes[:arquivo].nil?) \
  or (not opcoes[:arquivo].nil? and not File.exist?(opcoes[:arquivo]))
   puts "Execute: ruby pdfRico.rb -h"
   exit(1)
end

util = UtilRico.new
info = RicoExtratoPdf.new(opcoes[:arquivo]).obterInformacoes()
puts "Nome: " + info.nome
puts "Agencia: " + info.agencia
puts "Conta: " + info.conta
puts "Período de: " + info.periodo_de
puts "Período até: " + info.periodo_ate
puts "---"
info.estatistica = EstatisticaRico.new(info)
puts "Valor depositado: " + util.converter_valor_BRL(info.estatistica.obter_valor_investido()).to_s
  
relatorio = RelatorioXLS.new(info)
relatorio.gerar(relatorio)
