# = Objeto para mapear as informações do extrato.
# Author: Jackson Lopes <jacksonlopes@gmail.com>
# URL: https://jslabs.cc
# src: https://github.com/jacksonlopes/pdfRico
class InfoRico
    attr_accessor :nome, :agencia, :conta, :periodo_de, :periodo_ate
    attr_accessor :linha, :estatistica
end