# Simple Jupyter lab viewer

An example electron wrapper for Jupyter lab.

## Developer instruction

- Clone the repository.  
    If using on Linux,  
        - Run `sh ./linux-runme.sh` for a slightly automated experience.  
            - Current script is able to install, give alternatives, and uninstall/clean npm files.  
        - Follow on-screen prompts.

- Run `npm install` to install dependencies, alternatively see below.
    * `npm install electron --save-dev` to save to dev dependencies.
    * `npm install electron-packager --save-dev` to save to dev dependencies.

- Run `npm start` to start the application.
- Run `npm run package-mac` to build the arm64 version for m-series macs.
- Run `npm run package-win` to build the windows version.
- Run `npm run package-linux` to build the linux version.
