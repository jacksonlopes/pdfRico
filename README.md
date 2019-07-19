# pdfRico
Gera um relatório com informações estatísticas a partir do PDF de extrato da corretora Rico.

A única dependência é a gem 'pdf-reader', portanto execute:  

$ bundle install  

Para gerar o relatório, após baixar o PDF de extrato, execute:

$ ruby pdfRico.rb -p <RELATÓRIO>

Exemplo:  
$ ruby pdfRico -p rico.pdf  
Nome: JACKSON LOPES  
Agencia: XXXX  
Conta: XXX  
Período de: 01/01/2016  
Período até: 31/12/2016  
Valor depositado: XXX  

E irá gerar o relatório 'REL_RICO_per__01012016-31122016__31122016.xlsx'

![Sheet1:](https://i.pstorage.space/i/Pw2a9QkV7/original_01.png) 

![Sheet2:](https://i.pstorage.space/i/LDRW03klo/original_02.png) 
