libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
# = Gerar informação manipulável a partir do PDF de extrato da corretora Rico
# Autor: Jackson Lopes <jacksonlopes@gmail.com>
# Site:  https://jacksonlopes.github.io

class UtilRico

    def converter_valor(valor)
        return valor.gsub(".","_").gsub(",",".").to_f
    end

    # Método original
    # http://www.misuse.org/science/2008/03/27/converting-numbers-or-currency-to-comma-delimited-format-with-ruby-regex/
    # alterado para meus propósitos
    def converter_valor_BRL(number, delimiter = '#')
        n = number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
        return n.gsub(".",",").gsub("#",".") + "0"
    end    

end