# reconnaissance scripts
A set of modular Bash scripts to automate common bug bounty recon tasks. This is a learning-driven project, and more features will be added over time. 

## Features

- [x] Modular Bash workflow
- [x] Passive and active subdomain enumeration
- [x] Live host detection with HTTP status code filtering
- [x] JavaScript scraping and secret detection (multiple versions)
- [x] Tech stack fingerprinting
- [ ] Wrapper system to chain all tools (WIP)

## Usage

Clone the repo:
```
git clone https://github.com/yeetbix529/BountyForge.git
cd project-name
```

Run the recon flow:
```
./00_dependency_check.sh           # Check dependencies
./01_get_scope.sh "target.com"    # Pull scope from platform
./02_enum_subs.sh "target.com"    # Subdomain enumeration
./03_dns_resolution.sh "target.com"  # DNS resolving
./04_live_check.sh "target.com"   # Filter for live hosts
./05_js_analysis.sh "target.com"  # Scrape JS files
./06_secret_finder.sh "target.com"    # SecretFinder original
./06_secretfinder_v2.sh "target.com" # Alternate version
./07_tech_detect.sh "target.com"  # Tech stack detection
# Add or remove based on your setup
```
## Directory Structure
```
bugBounty_v2/
├── bounty-targets-data/           # Scopes or target lists
├── recon/                         # (Optional) results/output
├── secretfinder/                  # Cloned SecretFinder repo
├── 00_dependency_check.sh
├── 01_get_scope.sh
├── 02_enum_subs.sh
├── 03_dns_resolution.sh
├── 04_live_check.sh
├── 05_js_analysis.sh
├── 06_secret_finder.sh
├── 06_secretfinder_v2.sh
├── 07_tech_detect.sh
└── README.md
```

## Dependencies
- https://github.com/projectdiscovery/subfinder
- https://github.com/projectdiscovery/dnsx
- https://github.com/projectdiscovery/httpx
- https://github.com/m4ll0k/SecretFinder
- https://github.com/projectdiscovery/subfinder
  
Install via:
`go install github.com/projectdiscovery/subfinder/v2@latest`
repeat for others...

## Roadmap
- [ ] Add wrapper script for one-click recon
- [ ] Create depenecy checker script
- [ ] Improve output logging and timestamping

Made by @yeetbix529
