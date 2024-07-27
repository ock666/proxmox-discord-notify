<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPL License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/ock666/proxmox-discord-notify">
    <img src="images/proxmox.svg" alt="Logo" width=180 length=180>
  </a>

  <h3 align="center">Proxmox Task Discord Notifier</h3>

  <p align="center">
    A Bash Script to keep you informed of tasks running in your cluster.
    <br />
    <a href="https://github.com/ock666/proxmox-discord-notify"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    ·
    <a href="https://github.com/ock666/proxmox-discord-notify/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/ock666/proxmox-discord-notify/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Proxmox Task Discord Notifier Screenshot][product-screenshot]](https://example.com)

The Proxmox Task Discord Notifier is designed to streamline task monitoring in Proxmox by providing real-time notifications directly to a Discord channel. It addresses the need for immediate alerts about task events, allowing you to stay updated on important actions within your Proxmox environment without constantly checking the web interface.

Here's why this project is valuable:
* **Real-time Notifications**: Keep track of task events as they happen, ensuring you don't miss critical updates.
* **Easy Integration**: Seamlessly integrates with Proxmox and Discord with minimal configuration.
* **Automation**: Automate notifications and reduce manual monitoring efforts, saving time and improving efficiency.

We aim to make task monitoring in Proxmox more effective and less cumbersome by bringing essential updates directly to your communication platform. You can enhance this project by forking the repo and submitting pull requests or by opening issues for suggestions.

For detailed setup and usage instructions, please refer to the [Documentation](https://github.com/your_username/proxmox-task-notifier/wiki).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Bash][Bash-logo]](https://www.gnu.org/software/bash/)
* [![jq][jq-logo]](https://stedolan.github.io/jq/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Please read the steps outlined below before setting up or submitting any issues to the repo.

### Prerequisites

* Bash
* Proxmox
* Discord
* jz
  ```sh
  apt install jz -y
  ```

### Installation

_Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services._

1. Clone the repo
   ```sh
   git clone https://github.com/ock666/proxmox-discord-notify
   ```
2. Edit the bash script variables to include your secrets, so the script can retrieve tasks. If you want tasks from a specific node in Proxmox, you need to use the following URL format for the Proxmox API:
   ```sh
    /nodes/{node}/tasks
   ```
   For example, if your node is named pve, the URL would look like this:
   ```sh
   /nodes/pve/tasks
   ```
   where {node} is the name your of node.
   
   If you have special characters in your password be sure to escape the special characters.
3. Run the script manually with
   ```sh
   ./proxmox-discord-bot.sh
   ```
   To see if you can call the Proxmox API successfully with your configuration.     
2. Copy sh file to usr/local/bin
   ```sh
   cp proxmox-discord-bot.sh /usr/local/bin/
   ```
3. Copy the service file
   ```sh
   cp proxmox-notifier.service /etc/systemd/system/
   ```
4. Reload Systemd: Inform systemd of the new service file.
   ```sh
   systemctl daemon-reload
   ```
5. Enable the Service: Configure the service to start on boot.
   ```sh
   systemctl enable proxmox-notifier.service
   ```
6. Start the Service: Start the service immediately.
   ```sh
   systemctl start proxmox-notifier.service
   ```
7. Check Service Status: Verify that the service is running correctly.
   ```sh
   systemctl status proxmox-notifier.service
   ```
8. Check your Discord Channel for task messages!

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

The Proxmox Task Discord Notifier is designed to monitor Proxmox tasks and notify a Discord channel of task events. Follow the instructions below to use the notifier.

### Configuration

1. **Set up the Discord webhook**: Obtain a Discord webhook URL from your Discord channel settings.

2. **Edit the script**: Fill in the script variables at the top of the script with your proxmox secrets.

3. Install the service file and enable it.
### Running the Notifier

To run the notifier manually, use the following command:

```bash
./proxmox_task_notifier.sh
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the GPLv3 License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Oskar Petersen - contact-me@oskarpetersen.addy.io

Project Link: [https://github.com/ock666/proxmox-discord-notify/](https://github.com/ock666/proxmox-discord-notify/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Choose an Open Source License](https://choosealicense.com)
* [Img Shields](https://shields.io)


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/ock666/proxmox-discord-notify.svg?style=for-the-badge
[contributors-url]: https://github.com/ock666/proxmox-discord-notify/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ock666/proxmox-discord-notify.svg?style=for-the-badge
[forks-url]: https://github.com/ock666/proxmox-discord-notify/network/members
[stars-shield]: https://img.shields.io/github/stars/ock666/proxmox-discord-notify.svg?style=for-the-badge
[stars-url]: https://github.com/ock666/proxmox-discord-notify/stargazers
[issues-shield]: https://img.shields.io/github/issues/ock666/proxmox-discord-notify.svg?style=for-the-badge
[issues-url]: https://github.com/ock666/proxmox-discord-notify/issues
[license-shield]: https://img.shields.io/github/license/ock666/proxmox-discord-notify.svg?style=for-the-badge
[license-url]: https://github.com/ock666/proxmox-discord-notify/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/oskar-petersen-39a849185/
[Bash-logo]: https://img.shields.io/badge/-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white
[jq-logo]: https://img.shields.io/badge/-jq-1E9A2D?style=for-the-badge&logo=jq&logoColor=white

