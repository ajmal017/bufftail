require 'nokogiri'
require 'open-uri'
require 'YAML'

today = Time.now.to_s.gsub(/\D/, '')[0...8]
`scp -Cr 'kmcd@10.211.55.3:/cygdrive/c/Program*/Amibroker/Reports/*Out-of-Sample*#{today}*' tmp`
todays_reports =  `ls -tr ./tmp/*ample*/trades.html | grep '#{today}'`

trades = todays_reports.split("\n").uniq {|_| _[/[A-Z]+_[A-Z]+_*[A-Z]*/] }.sort.map do |report|
  strategy = report[/[A-Z]+_[A-Z]+_*[A-Z]*/]
  doc = Nokogiri::HTML open(report)
  trades = doc.css('table tr td:nth-child(6)').map {|_| _.to_s[/-*\d+\.\d+/].to_f }
  
  [strategy, trades]
end

File.open('./data/wfa_trades.yml','w') {|_| _.puts Hash[ trades ].to_yaml }
