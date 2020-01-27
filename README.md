# updater-console

Console application to update and restart a Windows App or a Windows Service App.

Takes following command line params:

1: FileName of running instance to update

2: Filename of the new executable

3: Flags

#Flags

-s = Target is a windows service (service will be stopped and restarted.  Requires admin privileges)

-n = do not restart (just replace the file)


