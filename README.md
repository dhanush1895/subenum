# subenum
Subdomain enumeration tool based on All open source Tool, this is a Bash file which performs Domain as a target in all Described tools & resources and passes out the domains, found-ports and live domains into individual files.

[![LinkedIn][linkedin-shield]][linkedin-url] ![Twitter Follow](https://img.shields.io/twitter/follow/dhanush1895?style=social)



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="Logo.png">
    <img src="Logo.png" alt="Logo" width="600" height="200">
  </a>
  </p>
</p>




<!-- ABOUT THE PROJECT -->
## About The Project
<br />
<p align="center">
  <a href="subenum_work.pngg">
    <img src="subenum_work.png" alt="img" width="600" height="200">
  </a>
  </p>
</p>

There are many great scripts available on GitHub, however, I want to make myself an own script.

Here's why:
* Your time should be focused on creating something amazing. A project that solves a problem, helps others and understand's what's the code does in easy way.
* You shouldn't be doing the same tasks over and over like creating a folder or searching for if the same folder is existed or not.
* You should have clear path of discovering & gathering sub-domains. 
* Some of the tools fail's to discover the unique sub-domain's, So in the discovering phase while pen-testing or Bug Hunting, we should gather all the related stuff's to that organization.

Of course, no one tool/script will serve all the needs since your needs may be different. So I'll be adding more in the near future. You may also suggest changes by forking this repo and creating a pull request or opening an issue.

A list of commonly used resources that I find helpful are listed in the acknowledgements.

### Built With

- Dnsvalidator
- Amass
- assetfinder
- subfinder
- sublist3r
- github-subdomains
- crt.sh
- dns.bufferover.run
- sonar.omisint.io
- web.archive
- knockpy
- GOBUSTER
- knockknock
- httpx
- nuclei
- notify


### Prerequisites
- A Stable Internet Connection with high speed
 
- [X] This script runs in linux environment (linux & ubuntu) 


### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/dhanush1895/subenum.git
   ```
2. Install the script --> subenum-install.sh
   ```sh
   chmod +x subenum-install.sh
   ```
   ```sh
   ./subenum-install.sh
   ```
3. Enter your API-key's in `config.yaml`- subfinder config file,`config.ini`- amass config file.
4. Keep alias for subenum in your .profile/.bash_profile/.bash_aliases 
   ```sh
   alias subenum="bash path_to_script"
   ```



<!-- USAGE EXAMPLES -->
## Usage
1. ```
      Usage: subenum -d google.com
      Usage: subenum -f PATH/TO/FILE
      Usage: subenum -d google.com -c [1|2]
      Usage: subenum -f PATH/TO/domains.txt -c [1|2]
      Flags:
      -h, -help                      Show's usage
      -d, -domain                    Add your domain
      -f, -file                      List of Domains as file.txt should be line separated file
      -c, -config                      config file for amass
      Example Usage
      ./subenum.sh -d google.com
      ./subenum.sh -f domains.txt
   ```

<!-- ROADMAP -->
## Roadmap
- [X] To get massive amount of sub-domains using all the open-source tools
- [X] To filter & resolve out the live sub-domains 
- [X] To Run sub-domain takeover scan using nuclei templates

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.


<!-- CONTACT -->
## Contact

Daniel goes by `dhanush1895` on Internet  - [@dhanush1895](https://twitter.com/dhanush1895) 

dhanushkalimeli@gmail.com



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/danielthotapalli
[product-screenshot]: images/screenshot.png
