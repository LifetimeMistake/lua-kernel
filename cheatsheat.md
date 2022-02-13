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

-- Protects tables from unauthorized modifications
-- This action can not be undone for kernel memory safety
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
-- Executes the specified module loader function inside of the specified context
-- or creates a default one, then registers the module with the kernel
mm.loadModule(moduleLoader, loaderContext)

-- Compiles the specified string into Lua bytecode using the default loadstring funtion
-- inside the specified context or creates a default one, then registers the module with the kernel
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

-- Returns all open file descriptors for the given path
vfs.getOpenPathDescriptors(path)

-- Returns the next free file descriptor ID
vfs.getNextFreeDescriptorId()

-- Creates file descriptor, returns error if exclusive file descriptor for file exists,
-- or if you want to generate a exclusive file descriptor for already busy file.
-- path = file
-- mode = vfs.fileModes
-- exclusive = bool
vfs.createFileDescriptor(path, mode, exclusive)

-- Creates a node, only one node for given path can exist.
-- type c - character | type fs - filesystem | Path - String | DMJN, DMIN - int
vfs.createNode(path, type, device_majorNumber, device_minorNumber)

-- If file exists and is not in use, dispose of it
vfs.deleteNode(path)

-- No further explanation
vfs.deleteDescriptor(id)

-- returns a bool based on existance of node with given path
vfs.fileExists(path)
```

Thats all for now.