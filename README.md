# Blocklist for `dnscrypt-proxy`

## Purpose

This repository automatically maintains an up-to-date `blocklists/mybase.txt` file by regularly synchronizing it from [jedisct1's](https://github.com/jedisct1) [file server](https://download.dnscrypt.info/blacklists/domains/).

By using this repo as a flake input, you can easily integrate the latest DNS blocklist into your NixOS or home-manager configuration for use with `dnscrypt-proxy`.

## How It Works

A GitHub Actions workflow periodically fetches the latest blocklist from the FTP server and commits any updates to this repository. This ensures the blocklist stays current without manual intervention.

## Usage

Add this repository as a flake input:

