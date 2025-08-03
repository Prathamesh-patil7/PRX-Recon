#!/bin/bash

# Banner
clear
echo -e "\e[31m"
echo "   ▄███████▄    ▄████████ ▀████    ▐████▀    ▄████████    ▄████████  ▄████████  ▄██████▄  ███▄▄▄▄   "
echo "  ███    ███   ███    ███   ███▌   ████▀    ███    ███   ███    ███ ███    ███ ███    ███ ███▀▀▀██▄ "
echo "  ███    ███   ███    ███    ███  ▐███      ███    ███   ███    █▀  ███    █▀  ███    ███ ███   ███ "
echo "  ███    ███  ▄███▄▄▄▄██▀    ▀███▄███▀     ▄███▄▄▄▄██▀  ▄███▄▄▄     ███        ███    ███ ███   ███ "
echo "▀█████████▀  ▀▀███▀▀▀▀▀      ████▀██▄     ▀▀███▀▀▀▀▀   ▀▀███▀▀▀     ███        ███    ███ ███   ███ "
echo "  ███        ▀███████████   ▐███  ▀███    ▀███████████   ███    █▄  ███    █▄  ███    ███ ███   ███ "
echo "  ███          ███    ███  ▄███     ███▄    ███    ███   ███    ███ ███    ███ ███    ███ ███   ███ "
echo " ▄████▀        ███    ███ ████       ███▄   ███    ███   ██████████ ████████▀   ▀██████▀   ▀█   █▀  "
echo "               ███    ███                   ███    ███                                          "
echo -e "\e[0m"
sleep 1

# Color Output
green="\e[32m"
red="\e[31m"
yellow="\e[33m"
nc="\e[0m"

# Check input
if [ -z "$1" ]; then
  echo -e "${red}Usage: $0 domain.com${nc}"
  exit 1
fi

domain=$1
outdir="recon-$domain"
mkdir -p $outdir

echo -e "${yellow}[*] Running Subfinder...${nc}"
subfinder -d $domain -silent -o $outdir/subdomains.txt

echo -e "${yellow}[*] Probing live domains with Httpx...${nc}"
httpx -silent -l $outdir/subdomains.txt -o $outdir/live.txt

if [ ! -s "$outdir/live.txt" ]; then
  echo -e "${red}[!] No live hosts found. Exiting...${nc}"
  exit 1
fi

echo -e "${yellow}[*] Running Naabu for port scanning...${nc}"
naabu -list $outdir/live.txt -silent -o $outdir/ports.txt

echo -e "${yellow}[*] Crawling with Katana...${nc}"
katana -list $outdir/live.txt -silent -o $outdir/crawl.txt

echo -e "${yellow}[*] Running DNSx for DNS info...${nc}"
dnsx -l $outdir/subdomains.txt -o $outdir/dns.txt

echo -e "${yellow}[*] Scanning vulnerabilities with Nuclei...${nc}"
nuclei -l $outdir/live.txt -silent -o $outdir/vulnerabilities.txt

# -----------------------------------------
# 🛡️ EXTRA BUG-FINDING MODULES
# -----------------------------------------

echo -e "${yellow}[*] Checking for open redirects...${nc}"
cat $outdir/crawl.txt | gf redirect | tee $outdir/redirects.txt

echo -e "${yellow}[*] Checking for potential XSS...${nc}"
cat $outdir/crawl.txt | gf xss | tee $outdir/xss.txt

echo -e "${yellow}[*] Checking for potential SSRF...${nc}"
cat $outdir/crawl.txt | gf ssrf | tee $outdir/ssrf.txt

echo -e "${yellow}[*] Checking for LFI/RFI...${nc}"
cat $outdir/crawl.txt | gf lfi | tee $outdir/lfi.txt

echo -e "${yellow}[*] Running Wayback URLs...${nc}"
cat $outdir/subdomains.txt | waybackurls > $outdir/wayback.txt

echo -e "${yellow}[*] Filtering for parameters...${nc}"
cat $outdir/wayback.txt | grep "=" | anew $outdir/params.txt

echo -e "${yellow}[*] Running Dalfox on potential XSS...${nc}"
dalfox file $outdir/xss.txt --skip-bav -o $outdir/dalfox_xss.txt

echo -e "${yellow}[*] Checking vulnerable JS files...${nc}"
cat $outdir/wayback.txt | grep "\.js$" | grep -vE "\.json$" | httpx -mc 200 -silent | tee $outdir/js_files.txt

echo -e "${green}[+] Recon completed and saved in '${outdir}'${nc}"
