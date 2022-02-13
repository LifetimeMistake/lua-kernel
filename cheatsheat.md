### kernel/protect.lua
```lua 
-- Creates unprivileged or privileged lua environment.
protect.createUnprivilegedContext(parent_env)
protect.createPrivilegedContext(parent_env)
```
```lua
-- Executes a given function within the specified context.
-- Can only be ran from a privileged context.
protect.executeSandbox(func, context, ...)

--Executes a given string within the specified context
-- Can only be ran from a privileged context. 
protect.loadstringSandbox(string, context)

-- Protect tables from unprivilagd edition
protect.setreadonly(table)
```
### kernel/assert.lua
```lua
-- Compares type of the object with given one and throws error when object type is invalid
assert.type(object, objectType, errorMessage)

-- Helper for dependency check
assert.dependency(object, dependency)
```

### kernel/modules/modulemanager.lua
```lua
-- Checks if module is correct and loads it into given context, modules should be Unprivilaged
mm.loadModule(moduleLoader, loaderContext)

-- Waiting for LM to describe
mm.loadstringModule(moduleString, moduleContext) 

-- Triggers module destroy function, if force == true then simply wipes module out.
mm.unloadModule(moduleName, force)

-- Returns module if loaded
mm.getModule(moduleName)

-- Returns loaded module names in table
mm.getLoadedModuleNames()

-- Returns loaded modules
mm.getLoadedModules()
```

### kernel/devices/devicemanager.lua
```lua
-- Returns bool
dm.isDeviceRegistered(majorNumber, minorNumber)

-- Creates device with given parameters
dm.createDevice(majorNumber, minorNumber, name, ownerModule)

-- Returns device
dm.getDevice(majorNumber, minorNumber)

-- Initializes character device with given arguments
dm.initCharDevice(majorNumber, minorNumber, charOperations)

-- Initializes filesystem device with given arguments
dm.initFsDevice(majorNumber, minorNumber, fsOperations)

-- Deletes device with given MjN and MiN
dm.deleteDevice(majorNumber, minorNumber)

-- Returns devices
dm.getDevices

-- Returns devices with given MjN
dm.getDevicesByClass(majorNumber)
```

### kernel/vfs.lua
```lua
-- Returns node with given path
vfs.getNode(path)

-- Returns bool based on existance of file descriptor
vfs.isFileInUse(path)

-- Returns bool based on existance of exclusive file descriptor for given path
vfs.isFileLocked(path)

-- Basicaly a helper function to get fileDescriptor id's in table for given path.
-- { id = path }
vfs.getDescriptorId(path)

-- Creates file descriptor, returns error if exclusive file descriptor for file exists, or you want to generate a exclusive file descriptor for already busy file.
-- path = file
-- mode = vfs.fileModes
-- exclusive = bool
vfs.createFileDescriptor(path, mode, exclusive)

-- Creates a node, only one node for given path can exist.
-- type c - character | type fs - filesystem | Path - String | DMJN, DMIN - int
vfs.createNode(path, type, device_majorNumber, device_minorNumber)

-- If file exists and is not in use, dispose of it
vfs.deleteNode = function(path)

-- No further explanation
vfs.deleteDescriptor(id)

-- returns a bool based on existance of node with given path
vfs.fileExists(path)
```

Thats all for now.