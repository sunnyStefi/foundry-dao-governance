# Forge Base Project

### Do not repeat yourself

Minimalistic initialization project that sets up a simple forge project. 
It comes with a makefile, toml and .env that are always shared among simple learning projects (e.g. foundry full course, ..).

## What's used for

1. to be consistent: `make push` every morning after your first glass of water
2. have a reference (makefile) for libs used in the past
3. do not repeat coding patterns (deploy contract, network configuration..)

## Usage

1. Remove unused libraries in makefile and `make install`
2. Remove unused remappings on `toml` file

## Todos
1. order makefile per command name and add comments
2. add options in toml

## General setup:

1. `forge init`
2. added a deploy script to basic contract `InitMe`
3. added general makefile
4. added general .env
