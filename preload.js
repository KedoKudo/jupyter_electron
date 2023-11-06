const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    checkPort: (port) => ipcRenderer.send('check-port', port),
    onPortStatus: (callback) => ipcRenderer.on('port-status', callback)
});
