const { app, BrowserWindow, ipcMain } = require('electron');
const { spawn } = require('child_process');
const net = require('net');
const path = require('path');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;
let jupyterProcess = null; // Keep a reference to the Jupyter process

function createWindow() {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      // It is important to preload a script for security purposes
      preload: path.join(__dirname, 'preload.js')
    }
  });

  // and load the index.html of the app.
  mainWindow.loadFile('index.html');

  mainWindow.on('closed', () => {
    // When the window is closed, kill the JupyterLab process if it exists
    if (jupyterProcess !== null) {
      jupyterProcess.kill();
      jupyterProcess = null;
    }
    mainWindow = null;
  });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(createWindow);


// Quit when all windows are closed.
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
      app.quit();
    }
});



app.on('activate', () => {
    if (mainWindow === null) {
      createWindow();
    }
  });


ipcMain.on('check-port', (event, port) => {
    console.log(`Checking port: ${port}`); // Log checking port
    checkPort(port, (isAvailable) => {
      console.log(`Port ${port} is available: ${isAvailable}`); // Log port status
      event.reply('port-status', isAvailable);
      if (isAvailable) {
        startJupyterLab(port);
      }
    });
  });


function checkPort(port, callback) {
    const server = net.createServer();
  
    server.once('error', (err) => {
      console.error(`Error listening on port ${port}: ${err.message}`); // Log error message
      callback(false);
    });
  
    server.once('listening', () => {
      server.close();
      callback(true);
    });
  
    server.listen(port);
}


function startJupyterLab(port) {
    console.log(`Starting JupyterLab on port ${port}`);
    jupyterProcess = spawn('jupyter', ['lab', '--no-browser', `--port=${port}`]);
  
    jupyterProcess.stdout.on('data', (data) => {
      const output = data.toString();
      console.log(`JupyterLab stdout: ${output}`);
    });
  
    jupyterProcess.stderr.on('data', (data) => {
      console.error(`JupyterLab stderr: ${data}`);

      const output = data.toString();
      // When JupyterLab is ready, it logs a message with the URL.
      // The exact log message can vary based on your JupyterLab version and configuration.
      const readyPattern = /http:\/\/localhost:\d+\/lab\?token=([\w]+)/;
      const match = output.match(readyPattern);
  
      if (match) {
        const url = match[0]; // This is your JupyterLab URL
        console.log(`JupyterLab is ready at ${url}`);
        mainWindow.loadURL(url); // Load the JupyterLab URL in the main window
      }
    });
  
    jupyterProcess.on('error', (err) => {
      console.error(`Failed to start JupyterLab: ${err}`);
    });
  
    jupyterProcess.on('close', (code) => {
        console.log(`JupyterLab process exited with code ${code}`);
        // Clear the reference to the process when it exits
        jupyterProcess = null;
        if (mainWindow && !mainWindow.isDestroyed()) {
            mainWindow.loadFile('index.html'); // Reload the initial screen or handle as needed
        }
    });
}
