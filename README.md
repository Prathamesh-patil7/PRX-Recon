# PRX-Recon

> 🔍 Automated Recon Toolkit for Ethical Hacking and Bug Bounty Hunting.

## 🚀 Features

- Subdomain enumeration (Subfinder)
- Live host detection (Httpx)
- Port scanning (Naabu)
- Web crawling (Katana)
- DNS resolution (DNSx)
- Vulnerability scanning (Nuclei)
- Wayback URL extraction
- XSS, LFI, SSRF, Redirect detection (GF)
- Dalfox for XSS testing
- JS file discovery

## 🛠️ Requirements

Install the tools:

```bash
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install github.com/tomnomnom/gf@latest
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/hahwul/dalfox/v2@latest



 Usage
./prx-recon.sh domain.com

 Output Structure

recon-domain.com/
├── subdomains.txt
├── live.txt
├── ports.txt
├── crawl.txt
├── dns.txt
├── vulnerabilities.txt
├── wayback.txt
├── params.txt
├── xss.txt
├── dalfox_xss.txt
├── ssrf.txt
├── lfi.txt
├── redirects.txt
├── js_files.txt

