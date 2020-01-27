# updater-console

Console application to update and restart a Windows App or a Windows Service App.

Takes following command line params:

1: FileName of running instance to update

2: Filename of the new executable

3: Flags

# Flags

 -s = Target is a windows service (service will be stopped and restarted.  Requires admin privileges)

 -n = do not restart (just replaces the file)
 
 -sn:{name} = The Service Name to restart. E.g -sn:AquilaServer
 
 -p:{param} = Passthru, passes "param" to the restart of the new app.  E.g. -p:-u -p:/Z will pass "-u /Z" to the new app as the command line arguments


