require 'open3'
require 'json'
require 'net/http'
require 'uri'

# bewarnaa biar ga burik ahk
NORMAL = "\033[0m"
BOLD = "\033[1m"
BLINK = "\033[5m"
LGREEN = "\033[92m"
DGRAY = "\033[90m"
RED = "\033[91m"
LBLUE = "\033[1;34m"
RESET = "\033[0m"

# mempercantik biar kek hamkerr wkwkw
def display_banner
  banner_text = <<~BANNER
    #{BOLD}#{LGREEN}
    ██╗  ██╗ ██████╗ ██╗  ██╗ ██████╗ ██╗  ██╗     ███████╗███████╗ ██████╗
    ██║ ██╔╝██╔═══██╗██║ ██╔╝██╔═══██╗██║ ██╔╝     ██╔════╝██╔════╝██╔════╝
    █████╔╝ ██║   ██║█████╔╝ ██║   ██║█████╔╝█████╗███████╗█████╗  ██║     
    ██╔═██╗ ██║   ██║██╔═██╗ ██║   ██║██╔═██╗╚════╝╚════██║██╔══╝  ██║     
    ██║  ██╗╚██████╔╝██║  ██╗╚██████╔╝██║  ██╗     ███████║███████╗╚██████╗
    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝     ╚══════╝╚══════╝ ╚═════╝                            
    #{RESET}
  BANNER

  extra_text = <<~EXTRA
    #{BOLD}#{RED}====================================================================
    **                  Instagram : @risky.manuel                       **
    **                  Website   : manuelky08.github.io                **
    **                  Email     : riskymanuel08@proton.me             **
    ====================================================================#{RESET}

    #{BOLD}#{RED}V 1.0 ~ Happy Hunting - Mr.kiy
      ̿̿ ̿̿ ̿̿ ̿'̿'\\̵͇̿̿\\з= ( ▀ ͜͞ʖ▀) =ε/̵͇̿̿/’̿’̿ ̿ ̿̿ ̿̿ ̿̿#{RESET}

    #{BLINK}#{LBLUE}🕱 @kikikokok9 #{DGRAY} | #{RED}Tools Private RR #{NORMAL}
  EXTRA

  puts banner_text
  puts extra_text
end

# fungsii dari crt.sh yee
def cari_subdomain(domain)
  url = URI("https://crt.sh/?q=%25.#{domain}&output=json")
  begin
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    subdomains = data.map { |entry| entry['name_value'] }.uniq
    puts "\n#{LGREEN}Subdomain ditemukan untuk #{domain}:#{RESET}"
    subdomains.each { |sub| puts sub }
  rescue => e
    puts "#{RED}Error saat mengakses crt.sh: #{e}#{RESET}"
  end
end

def run_command(command, success_message, error_message)
  stdout, stderr, status = Open3.capture3(*command)
  if status.success?
    puts "#{LGREEN}#{success_message}#{RESET}"
  else
    puts "#{RED}#{error_message}: #{stderr}#{RESET}"
  end
end

def subdomain_aktif(file)
  command = [
    "podman", "run", "--rm",
    "-v", "/home/rrsec/Gambar/coding lagi:/data",
    "projectdiscovery/httpx",
    "-l", "/data/#{file}",
    "-o", "/data/RR.txt"
  ]
  run_command(command, "Hasil disimpan di RR.txt", "Error menjalankan httpx")
end

def wayback_url(domain)
  command = ["waybackurls", domain, "-o", "wayback_urls.txt"]
  run_command(command, "Hasil disimpan di wayback_urls.txt", "Error menjalankan waybackurls")
end

def cari_direktori_sensitif(file)
  command = ["dirsearch", "-l", file, "-o", "direktori_sensitif.txt"]
  run_command(command, "Hasil disimpan di direktori_sensitif.txt", "Error menjalankan dirsearch")
end

def cari_kerentanan_nuclei(file)
  command = ["nuclei", "-l", file, "-o", "nuclei_results.txt"]
  run_command(command, "Hasil disimpan di nuclei_results.txt", "Error menjalankan Nuclei")
end

def scan_port(file)
  File.foreach(file) do |url|
    url.strip!
    next if url.empty?
    command = ["nmap", "-p-", url, "-oN", "#{url.gsub(%r{https?://|/}, '_')}_nmap_results.txt"]
    run_command(command, "Hasil disimpan di #{url.gsub(%r{https?://|/}, '_')}_nmap_results.txt", "Error pemindaian port")
  end
end

def cari_kerentanan_xss(file)
  command = ["dalfox", "file", file, "-b", "your.xss.domain", "-o", "xss_results.txt"]
  run_command(command, "Hasil disimpan di xss_results.txt", "Error mencari kerentanan XSS")
end

def cari_kerentanan_sqli(file)
  command = ["sqlmap", "-m", file, "--batch", "--risk=3", "-o", "sqli_results.txt"]
  run_command(command, "Hasil disimpan di sqli_results.txt", "Error mencari kerentanan SQLI")
end

def cari_informasi_website(file)
  command = ["whatweb", "-i", file]
  run_command(command, "Hasil disimpan di website_info.txt", "Error mencari informasi website")
end

def cari_kerentanan_nikto(target)
  command = ["nikto", "-h", target, "-o", "nikto_results.txt"]
  run_command(command, "Hasil pemindaian Nikto disimpan di nikto_results.txt", "Error menjalankan Nikto")
end

# Menu ku dongss uraaaa
def menu
  loop do
    puts "\n#{LGREEN}=== Menu ===#{RESET}"
    puts "1. sub <domain.com>:      Untuk mencari subdomain"
    puts "2. httpx <sub.txt>:       Untuk mencari subdomain yang aktif"
    puts "3. wayback <domain.com>:  Untuk mencari URL di satu domain"
    puts "4. dir <sub.txt>:         Untuk mencari direktori sensitif"
    puts "5. nuclei <sub.txt>:      Mencari kerentanan pada semua subdomain"
    puts "6. nmap <file>:           Melakukan pemindaian port"
    puts "7. dalfox <file>:         Mencari kerentanan XSS"
    puts "8. sqlmap <file>:         Mencari kerentanan SQL Injection"
    puts "9. whatweb <file>:        Mencari informasi dasar website"
    puts "10. nikto <target>:       Mencari kerentanan pada web"
    puts "0. Keluar"

    print "Pilih opsi: "
    choice = gets.chomp
    case choice
    when '1' then cari_subdomain(gets.chomp("Masukkan domain (tanpa http/https): "))
    when '2' then subdomain_aktif(gets.chomp("Masukkan nama file (sub.txt): "))
    when '3' then wayback_url(gets.chomp("Masukkan domain (tanpa http/https): "))
    when '4' then cari_direktori_sensitif(gets.chomp("Masukkan nama file (sub.txt): "))
    when '5' then cari_kerentanan_nuclei(gets.chomp("Masukkan nama file (sub.txt): "))
    when '6' then scan_port(gets.chomp("Masukkan nama file (URL list): "))
    when '7' then cari_kerentanan_xss(gets.chomp("Masukkan nama file: "))
    when '8' then cari_kerentanan_sqli(gets.chomp("Masukkan nama file: "))
    when '9' then cari_informasi_website(gets.chomp("Masukkan nama file: "))
    when '10' then cari_kerentanan_nikto(gets.chomp("Masukkan URL target: "))
    when '0'
      puts "#{LGREEN}Keluar dari program.#{RESET}"
      break
    else
      puts "#{RED}Opsi tidak valid. Silakan pilih lagi.#{RESET}"
    end
  end
end

if __FILE__ == $0
  display_banner
  menu
end
