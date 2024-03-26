<p align="center">
  <a href="https://seda.xyz/">
    <img width="90%" alt="seda-scripts" src="https://www.seda.xyz/images/footer/footer-image.png">
  </a>
</p>

<h1 align="center">
  seda-scripts
</h1>

<!-- The line below is for once the repo has CI to show build status. -->
<!-- [![Build Status][actions-badge]][actions-url] -->

<!-- [![GitHub Stars][github-stars-badge]](https://github.com/sedaprotocol/seda-scripts)
[![GitHub Contributors][github-contributors-badge]](https://github.com/sedaprotocol/seda-scripts/graphs/contributors) -->
<!-- [![Discord chat][discord-badge]][discord-url]
[![Twitter][twitter-badge]][twitter-url] -->

<!-- The line below is for once the repo has CI to show build status. -->
<!-- [actions-badge]: https://github.com/sedaprotocol/seda-scripts/actions/workflows/push.yml/badge.svg -->

[actions-url]: https://github.com/sedaprotocol/seda-scripts/actions/workflows/push.yml+branch%3Amain
[github-stars-badge]: https://img.shields.io/github/stars/sedaprotocol/seda-scripts.svg?style=flat-square&label=github%20stars
[github-contributors-badge]: https://img.shields.io/github/contributors/sedaprotocol/seda-scripts.svg?style=flat-square
[discord-badge]: https://img.shields.io/discord/500028886025895936.svg?logo=discord&style=flat-square
[discord-url]: https://discord.gg/seda
[twitter-badge]: https://img.shields.io/twitter/url/https/twitter.com/SedaProtocol.svg?style=social&label=Follow%20%40SedaProtocol
[twitter-url]: https://twitter.com/SedaProtocol

The home of scripts common for seda usage.

## Dependencies

A lot of the commands depend on:

- [Sedad](https://github.com/sedaprotocol/seda-chain)
- [jq](https://jqlang.github.io/jq/)

# Repo Breakdown

This repo is broken down into three sections:

- libs: Full of functions to be used from scripts. For example, transferring seda.
- exec: Scripts that will be executed to perform a non-trivial task. For example, a creating a proposal for uploading a WASM file.
- `common.sh`: sets up some commonly used functions and sets up error handling and etc.
